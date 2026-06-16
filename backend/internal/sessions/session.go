package sessions

import (
	"time"

	"backend/internal/sensors"
)

// Session represents a recording session for a user.
type Session struct {
	ID        uint       `gorm:"primaryKey" json:"id"`
	UserID    uint       `gorm:"not null" json:"user_id"`
	StartTime time.Time  `gorm:"not null" json:"start_time"`
	EndTime   *time.Time `json:"end_time,omitempty"`
	Notes     string     `json:"notes,omitempty"`
}

// SensorMeasurement represents a generic sensor measurement for a session.
type SensorMeasurement struct {
	ID        uint             `json:"id"`
	SessionID uint             `json:"session_id"`
	Datos     []sensors.Sample `json:"datos" gorm:"serializer:json"`
	CreatedAt time.Time        `json:"created_at"`
}

// SessionSummaryResponse represents the aggregated measurements for a session.
type SessionSummaryResponse struct {
	SessionID  uint    `json:"session_id"`
	Notes      string  `json:"notes"`
	MinBPM     float64 `json:"min_bpm"`
	MaxBPM     float64 `json:"max_bpm"`
	AvgBPM     float64 `json:"avg_bpm"`
	MinECG     float64 `json:"min_ecg"`
	MaxECG     float64 `json:"max_ecg"`
	AvgECG     float64 `json:"avg_ecg"`
	MinSPO2    float64 `json:"min_spo2"`
	MaxSPO2    float64 `json:"max_spo2"`
	AvgSPO2    float64 `json:"avg_spo2"`
	MinAIR     float64 `json:"min_air"`
	MaxAIR     float64 `json:"max_air"`
	AvgAIR     float64 `json:"avg_air"`
	AlertCount int     `json:"alert_count"`
}

// SessionWithSummary combina la sesión con su resumen para el endpoint batch.
type SessionWithSummary struct {
	Session
	MinBPM     float64 `json:"min_bpm"`
	MaxBPM     float64 `json:"max_bpm"`
	AvgBPM     float64 `json:"avg_bpm"`
	MinECG     float64 `json:"min_ecg"`
	MaxECG     float64 `json:"max_ecg"`
	AvgECG     float64 `json:"avg_ecg"`
	MinSPO2    float64 `json:"min_spo2"`
	MaxSPO2    float64 `json:"max_spo2"`
	AvgSPO2    float64 `json:"avg_spo2"`
	MinAIR     float64 `json:"min_air"`
	MaxAIR     float64 `json:"max_air"`
	AvgAIR     float64 `json:"avg_air"`
	AlertCount int     `json:"alert_count"`
}

// SensorExportGroup agrupa las mediciones de una sesión por tipo de sensor.
type SensorExportGroup struct {
	Sensor       string
	ValueUnit    string
	Measurements []SensorMeasurement
}
