package bpm

import (
	"time"

	"backend/internal/sensors"
)

// BpmMeasurement stores an array of BPM samples for a given session.
type BpmMeasurement struct {
	ID        uint             `gorm:"primaryKey" json:"id"`
	SessionID uint             `gorm:"index;not null" json:"session_id"`
	Datos     []sensors.Sample `gorm:"serializer:json" json:"datos"`
	CreatedAt time.Time        `json:"created_at"`
}
