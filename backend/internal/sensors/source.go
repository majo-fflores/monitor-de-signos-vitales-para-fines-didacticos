package sensors

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"strings"
	"time"

	"go.bug.st/serial"
)

const baudRate = 115200

type DataSource interface {
	ReadPacket() (ArduinoPacket, error)
	Close() error
}

type SimulatedArduino struct {
	types []string
}

func NewSimulatedArduino() DataSource {
	return &SimulatedArduino{
		types: []string{"bpm", "ecg", "air"},
	}
}

func (s *SimulatedArduino) ReadPacket() (ArduinoPacket, error) {
	time.Sleep(80 * time.Millisecond) // Simulate delay

	// Pick a random type
	t := s.types[rand.Intn(len(s.types))]

	var val float64
	switch t {
	case "bpm":
		val = 65 + rand.Float64()*(95-65)
	case "ecg":
		val = 0.2 + rand.Float64()*(1.2-0.2)
	case "air":
		val = 350 + rand.Float64()*(500-350)
	}

	return ArduinoPacket{
		Type:  t,
		Value: val,
	}, nil
}

func (s *SimulatedArduino) Close() error {
	return nil
}

type SerialArduino struct {
	port   serial.Port
	reader *bufio.Reader
}

func NewSerialArduino(portName string) (DataSource, error) {
	mode := &serial.Mode{
		BaudRate: baudRate,
	}
	port, err := serial.Open(portName, mode)
	if err != nil {
		return nil, err
	}

	return &SerialArduino{
		port:   port,
		reader: bufio.NewReader(port),
	}, nil
}

// readNextJSON lee byte a byte y extrae el siguiente objeto JSON completo
// usando conteo de llaves, ignorando cualquier basura entre objetos.
func (s *SerialArduino) readNextJSON() (string, error) {
	var buf []byte
	depth := 0
	inside := false

	for {
		b, err := s.reader.ReadByte()
		if err != nil {
			return "", fmt.Errorf("error leyendo del puerto serial: %w", err)
		}

		if b == '{' {
			if !inside {
				// Empezamos un nuevo objeto JSON, descartar lo anterior
				buf = buf[:0]
				inside = true
			}
			depth++
			buf = append(buf, b)
		} else if inside {
			buf = append(buf, b)
			if b == '}' {
				depth--
				if depth == 0 {
					// Objeto JSON completo
					return string(buf), nil
				}
			}
		}
		// Si no estamos inside, descartamos el byte (basura entre objetos)
	}
}

func (s *SerialArduino) ReadPacket() (ArduinoPacket, error) {
	// Leer el siguiente objeto JSON completo del stream serial
	for {
		jsonStr, err := s.readNextJSON()
		if err != nil {
			return ArduinoPacket{}, err
		}

		// Parsear el JSON real del Arduino: un objeto por sensor.
		var raw RawArduinoData
		if err := json.Unmarshal([]byte(jsonStr), &raw); err != nil {
			log.Printf("JSON inválido (descartando): %v → %q", err, jsonStr)
			continue
		}

		packet, ok := normalizeArduinoData(raw)
		if !ok {
			log.Printf("JSON de sensor inválido o no soportado (descartando): %q", jsonStr)
			continue
		}

		log.Printf("Arduino → sensor=%s type=%s value=%.0f alerta=%s leads_off=%s",
			raw.Sensor,
			packet.Type,
			packet.Value,
			formatOptionalBool(packet.Alert),
			formatOptionalBool(packet.LeadsOff),
		)
		return packet, nil
	}
}

func normalizeArduinoData(raw RawArduinoData) (ArduinoPacket, bool) {
	switch strings.ToUpper(raw.Sensor) {
	case "MQ135":
		if raw.CO2PPM == nil {
			return ArduinoPacket{}, false
		}
		return ArduinoPacket{
			Type:  "air",
			Value: *raw.CO2PPM,
			Alert: raw.Alerta,
		}, true
	case "AD8232":
		if raw.ECG == nil {
			return ArduinoPacket{}, false
		}
		return ArduinoPacket{
			Type:     "ecg",
			Value:    *raw.ECG,
			LeadsOff: raw.LeadsOff,
		}, true
	case "HW827":
		if raw.BPM == nil {
			return ArduinoPacket{}, false
		}
		return ArduinoPacket{
			Type:  "bpm",
			Value: *raw.BPM,
			Alert: raw.Alerta,
		}, true
	default:
		return ArduinoPacket{}, false
	}
}

func formatOptionalBool(value *bool) string {
	if value == nil {
		return "-"
	}
	return fmt.Sprintf("%t", *value)
}

func (s *SerialArduino) Close() error {
	if s.port != nil {
		return s.port.Close()
	}
	return nil
}
