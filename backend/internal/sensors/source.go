package sensors

import (
	"bufio"
	"encoding/json"
	"fmt"
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
		types: []string{"bpm", "spo2", "ecg"},
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
	case "spo2":
		val = 94 + rand.Float64()*(100-94)
	case "ecg":
		val = 0.2 + rand.Float64()*(1.2-0.2)
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
	port    serial.Port
	scanner *bufio.Scanner
}

func NewSerialArduino(portName string) (DataSource, error) {
	mode := &serial.Mode{
		BaudRate: baudRate,
	}
	port, err := serial.Open(portName, mode)
	if err != nil {
		return nil, err
	}

	scanner := bufio.NewScanner(port)
	return &SerialArduino{
		port:    port,
		scanner: scanner,
	}, nil
}

func (s *SerialArduino) ReadPacket() (ArduinoPacket, error) {
	if s.scanner.Scan() {
		line := s.scanner.Text()

		var packet ArduinoPacket
		err := json.Unmarshal([]byte(line), &packet)
		if err != nil {
			return ArduinoPacket{}, fmt.Errorf("error unmarshaling json: %w (line: %s)", err, line)
		}

		return packet, nil
	}

	if err := s.scanner.Err(); err != nil {
		return ArduinoPacket{}, err
	}

	return ArduinoPacket{}, fmt.Errorf("EOF")
}

func (s *SerialArduino) Close() error {
	if s.port != nil {
		return s.port.Close()
	}
	return nil
}
