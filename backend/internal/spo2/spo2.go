package spo2

import (
	"time"

	"backend/internal/sensors"
)

// Spo2Measurement stores an array of SpO2 samples for a given session.
type Spo2Measurement struct {
	ID        uint             `gorm:"primaryKey" json:"id"`
	SessionID uint             `gorm:"index;not null" json:"session_id"`
	Datos     []sensors.Sample `gorm:"serializer:json" json:"datos"`
	CreatedAt time.Time        `json:"created_at"`
}
