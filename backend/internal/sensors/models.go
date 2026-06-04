package sensors

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
