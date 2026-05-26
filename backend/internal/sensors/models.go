package sensors

// ArduinoPacket represents a single line of data from Arduino
// Example: {"type":"bpm","value":82}
type ArduinoPacket struct {
	Type  string  `json:"type"`
	Value float64 `json:"value"`
}

// Sample represents a recorded value with a backend-assigned timestamp
type Sample struct {
	Timestamp int64   `json:"timestamp"`
	Value     float64 `json:"value"`
}

// SessionData stores all samples recorded during an active session
type SessionData struct {
	BPM  []Sample `json:"bpm"`
	SpO2 []Sample `json:"spo2"`
	ECG  []Sample `json:"ecg"`
}

// NewSessionData creates a new empty session
func NewSessionData() *SessionData {
	return &SessionData{
		BPM:  make([]Sample, 0),
		SpO2: make([]Sample, 0),
		ECG:  make([]Sample, 0),
	}
}
