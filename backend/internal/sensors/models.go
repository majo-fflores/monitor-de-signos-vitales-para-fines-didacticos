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
	BPM  []Sample `json:"bpm"`
	SpO2 []Sample `json:"spo2"`
	ECG  []Sample `json:"ecg"`
}

func NewSessionData() *SessionData {
	return &SessionData{
		BPM:  make([]Sample, 0),
		SpO2: make([]Sample, 0),
		ECG:  make([]Sample, 0),
	}
}
