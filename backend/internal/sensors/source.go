package sensors

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
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
	queue  []ArduinoPacket // Cola interna de paquetes normalizados
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
		queue:  make([]ArduinoPacket, 0, 4),
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
	// Si hay paquetes en la cola interna, devolver el primero
	if len(s.queue) > 0 {
		pkt := s.queue[0]
		s.queue = s.queue[1:]
		return pkt, nil
	}

	// Leer el siguiente objeto JSON completo del stream serial
	for {
		jsonStr, err := s.readNextJSON()
		if err != nil {
			return ArduinoPacket{}, err
		}

		// Parsear el JSON real del Arduino: {"ecg":362,"bpm":0,"air":0,"leads_off":true}
		var raw RawArduinoData
		if err := json.Unmarshal([]byte(jsonStr), &raw); err != nil {
			log.Printf("JSON inválido (descartando): %v → %q", err, jsonStr)
			continue
		}

		log.Printf("Arduino → ecg=%.0f bpm=%.0f air=%.0f leads_off=%v", raw.ECG, raw.BPM, raw.AIR, raw.LeadsOff)

		// Siempre enviar BPM y AIR (son independientes del estado de los leads del ECG)
		s.queue = append(s.queue,
			ArduinoPacket{Type: "bpm", Value: raw.BPM},
			ArduinoPacket{Type: "air", Value: raw.AIR},
		)

		// ECG solo es confiable cuando los leads están conectados
		if !raw.LeadsOff {
			s.queue = append(s.queue, ArduinoPacket{Type: "ecg", Value: raw.ECG})
		}

		if len(s.queue) == 0 {
			continue
		}

		// Devolver el primero y dejar el resto en la cola
		pkt := s.queue[0]
		s.queue = s.queue[1:]
		return pkt, nil
	}
}

func (s *SerialArduino) Close() error {
	if s.port != nil {
		return s.port.Close()
	}
	return nil
}
