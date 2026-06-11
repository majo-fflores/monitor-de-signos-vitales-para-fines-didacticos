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
	AvgBPM     float64 `json:"avg_bpm"`
	AvgECG     float64 `json:"avg_ecg"`
	AvgSPO2    float64 `json:"avg_spo2"`
	AvgAIR     float64 `json:"avg_air"`
	AlertCount int     `json:"alert_count"`
}

// SessionWithSummary combina la sesión con su resumen para el endpoint batch.
type SessionWithSummary struct {
	Session
	AvgBPM     float64 `json:"avg_bpm"`
	AvgECG     float64 `json:"avg_ecg"`
	AvgSPO2    float64 `json:"avg_spo2"`
	AvgAIR     float64 `json:"avg_air"`
	AlertCount int     `json:"alert_count"`
}
