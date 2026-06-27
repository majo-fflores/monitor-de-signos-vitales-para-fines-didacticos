package sensors

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"math"
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
	types       []string
	typeIndex   int
	ecgIndex    int
	lastBPM     float64
	lastBPMTime time.Time
	airSimTime  float64
}

func NewSimulatedArduino() DataSource {
	return &SimulatedArduino{
		types:       []string{"bpm", "ecg", "air"},
		typeIndex:   0,
		ecgIndex:    0,
		lastBPM:     72.0,
		lastBPMTime: time.Now(),
		airSimTime:  0.0,
	}
}

func (s *SimulatedArduino) ReadPacket() (ArduinoPacket, error) {
	// Pick sequentially
	t := s.types[s.typeIndex%len(s.types)]
	s.typeIndex++

	// Only sleep before sending the first packet in the cycle
	if t == "bpm" {
		time.Sleep(10 * time.Millisecond) // Simulate delay
	}

	var val float64
	switch t {
	case "bpm":
		now := time.Now()
		if now.Sub(s.lastBPMTime) >= 1*time.Second {
			// Fluctuación aleatoria entre -2 y +2
			s.lastBPM = s.lastBPM + (rand.Float64()*4.0 - 2.0)
			if s.lastBPM < 60 {
				s.lastBPM = 60
			} else if s.lastBPM > 100 {
				s.lastBPM = 100
			}
			s.lastBPMTime = now
		}
		val = s.lastBPM
	case "ecg":
		ecgTemplate := []float64{
			0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.05, 0.1, 0.05, 0.0,
			0.0, -0.05, 0.8, -0.2, 0.0, 0.05, 0.1, 0.15, 0.2, 0.15,
			0.1, 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
		}
		// Generar ECG en rango ADC (Amplitud de ~800, centrado en 2048)
		val = 2048.0 + (ecgTemplate[s.ecgIndex%len(ecgTemplate)] * 800.0)
		s.ecgIndex++

		// Simular deriva de la línea base (onda sinusoidal lenta +/- 400 unidades)
		drift := 400.0 * math.Sin(s.airSimTime*0.5)
		val += drift

		// Simular un 2% de probabilidad de picos de ruido extremos (outliers)
		if rand.Float64() < 0.02 {
			if rand.Float64() < 0.5 {
				val = 4095.0
			} else {
				val = 0.0
			}
		}
	case "air":
		s.airSimTime += 0.01 // advances 10ms per cycle
		// Ruido real entre 1150 y 1250
		base := 1150.0 + rand.Float64()*100.0 
		cycle := math.Mod(s.airSimTime, 4.0) // 4 seconds breathing cycle
		
		// Pico para simular la respiración (cae a ~950)
		if cycle > 2.5 {
			// Onda sinusoide suave para el pico de respiración
			dropProgress := math.Sin((cycle - 2.5) / 1.5 * math.Pi)
			// Base promedio es ~1200. Queremos bajar a ~950 (caída de 250)
			val = base - (dropProgress * 250.0)
		} else {
			val = base
		}
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
