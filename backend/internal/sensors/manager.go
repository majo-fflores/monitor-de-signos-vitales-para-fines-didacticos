package sensors

import (
	"log"
	"sync"
	"time"
)

// Manager handles the data source reading and the active session
type Manager struct {
	source        DataSource
	activeSession *SessionData
	isRecording   bool
	mu            sync.Mutex
}

// GlobalManager is a global instance to be accessed from routes
var GlobalManager *Manager

// NewManager creates a new Manager instance
func NewManager(source DataSource) *Manager {
	return &Manager{
		source: source,
	}
}

// StartBackgroundListening starts an infinite loop reading from the DataSource
func (m *Manager) StartBackgroundListening() {
	log.Println("Iniciando escucha en segundo plano del sensor...")
	for {
		packet, err := m.source.ReadPacket()
		if err != nil {
			log.Printf("Error leyendo paquete: %v", err)
			time.Sleep(1 * time.Second) // Prevent tight loop on continuous errors
			continue
		}

		// Calculate timestamp at reception time
		ts := time.Now().UnixMilli()

		// Store in session if recording
		m.mu.Lock()
		if m.isRecording && m.activeSession != nil {
			sample := Sample{
				Timestamp: ts,
				Value:     packet.Value,
			}

			switch packet.Type {
			case "bpm":
				m.activeSession.BPM = append(m.activeSession.BPM, sample)
			case "spo2":
				m.activeSession.SpO2 = append(m.activeSession.SpO2, sample)
			case "ecg":
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
