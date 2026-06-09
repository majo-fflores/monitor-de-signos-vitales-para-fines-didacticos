package sensors

// RawArduinoData es el formato real que envía el Arduino por serial.
// Ejemplo: {"ecg":362,"bpm":0,"air":0,"leads_off":true}
type RawArduinoData struct {
	ECG      float64 `json:"ecg"`
	BPM      float64 `json:"bpm"`
	AIR      float64 `json:"air"`
	LeadsOff bool    `json:"leads_off"`
}

// ArduinoPacket es el formato normalizado interno (un valor por paquete).
type ArduinoPacket struct {
	Type  string  `json:"type"`
	Value float64 `json:"value"`
}

type Sample struct {
	Timestamp int64   `json:"timestamp"`
	Value     float64 `json:"value"`
}

type WsPacket struct {
	Type      string  `json:"type"`
	Value     float64 `json:"value"`
	Timestamp int64   `json:"timestamp"`
}

type SessionData struct {
	BPM []Sample `json:"BPM"`
	AIR []Sample `json:"AIR"`
	ECG []Sample `json:"ECG"`
}

func NewSessionData() *SessionData {
	return &SessionData{
		BPM: make([]Sample, 0),
		AIR: make([]Sample, 0),
		ECG: make([]Sample, 0),
	}
}
