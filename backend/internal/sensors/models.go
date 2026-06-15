package sensors

// RawArduinoData es el formato real que envía el Arduino por serial.
// Ejemplos:
// {"sensor":"MQ135","co2_ppm":2205,"alerta":true}
// {"sensor":"AD8232","ecg":4095,"leads_off":false}
// {"sensor":"HW827","bpm":59,"alerta":false}
type RawArduinoData struct {
	Sensor   string   `json:"sensor"`
	CO2PPM   *float64 `json:"co2_ppm,omitempty"`
	ECG      *float64 `json:"ecg,omitempty"`
	BPM      *float64 `json:"bpm,omitempty"`
	Alerta   *bool    `json:"alerta,omitempty"`
	LeadsOff *bool    `json:"leads_off,omitempty"`
}

// ArduinoPacket es el formato normalizado interno (un valor por paquete).
type ArduinoPacket struct {
	Type     string  `json:"type"`
	Value    float64 `json:"value"`
	Alert    *bool   `json:"alerta,omitempty"`
	LeadsOff *bool   `json:"leads_off,omitempty"`
}

type Sample struct {
	Timestamp int64   `json:"timestamp"`
	Value     float64 `json:"value"`
	Alert     *bool   `json:"alerta,omitempty"`
	LeadsOff  *bool   `json:"leads_off,omitempty"`
}

type WsPacket struct {
	Type      string  `json:"type"`
	Value     float64 `json:"value"`
	Timestamp int64   `json:"timestamp"`
	Alert     *bool   `json:"alerta,omitempty"`
	LeadsOff  *bool   `json:"leads_off,omitempty"`
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
