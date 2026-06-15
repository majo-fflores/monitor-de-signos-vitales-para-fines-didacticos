package sensors

import (
	"log"
	"strings"
	"sync"
	"time"
)

type Manager struct {
	source        DataSource
	activeSession *SessionData
	isRecording   bool
	mu            sync.Mutex
	subscribers   map[chan WsPacket]bool
}

var GlobalManager *Manager

func NewManager(source DataSource) *Manager {
	return &Manager{
		source:      source,
		subscribers: make(map[chan WsPacket]bool),
	}
}

func (m *Manager) StartBackgroundListening() {
	log.Println("Iniciando escucha en segundo plano del sensor...")
	for {
		packet, err := m.source.ReadPacket()
		if err != nil {
			log.Printf("Error leyendo paquete: %v", err)
			time.Sleep(1 * time.Second) // Prevent tight loop on continuous errors
			continue
		}

		// fmt.Println("Paquete recibido del sensor: ", packet)
		// Calculate timestamp at reception time
		ts := time.Now().UnixMilli()

		m.mu.Lock()

		// Broadcast to all websocket subscribers
		wsPacket := WsPacket{
			Type:      packet.Type,
			Value:     packet.Value,
			Timestamp: ts,
			Alert:     packet.Alert,
			LeadsOff:  packet.LeadsOff,
		}
		for ch := range m.subscribers {
			select {
			case ch <- wsPacket:
			default: // Prevent blocking if the channel is full
			}
		}

		// Store in session if recording
		if m.isRecording && m.activeSession != nil {
			sample := Sample{
				Timestamp: ts,
				Value:     packet.Value,
				Alert:     packet.Alert,
				LeadsOff:  packet.LeadsOff,
			}

			switch strings.ToUpper(packet.Type) {
			case "BPM":
				m.activeSession.BPM = append(m.activeSession.BPM, sample)
			case "AIR":
				m.activeSession.AIR = append(m.activeSession.AIR, sample)
			case "ECG":
				m.activeSession.ECG = append(m.activeSession.ECG, sample)
			default:
				log.Printf("Tipo de paquete desconocido: %s", packet.Type)
			}
		}
		m.mu.Unlock()
	}
}

// StartSession begins enqueueing incoming samples
func (m *Manager) StartSession() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.activeSession = NewSessionData()
	m.isRecording = true
	log.Println("Sesión iniciada. Grabando datos...")
}

// StopSession stops recording and returns the collected data
func (m *Manager) StopSession() *SessionData {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.isRecording = false
	session := m.activeSession
	m.activeSession = nil
	log.Println("Sesión detenida.")
	return session
}

// Subscribe adds a new channel to receive real-time data
func (m *Manager) Subscribe(ch chan WsPacket) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.subscribers[ch] = true
}

// Unsubscribe removes a channel from receiving real-time data
func (m *Manager) Unsubscribe(ch chan WsPacket) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if _, ok := m.subscribers[ch]; ok {
		delete(m.subscribers, ch)
		close(ch)
	}
}
