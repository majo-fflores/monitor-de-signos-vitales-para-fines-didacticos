package ecg

import (
	"time"

	"backend/internal/sensors"
	"backend/internal/sessions"
)

// EcgMeasurement stores an array of ECG samples for a given session.
type EcgMeasurement struct {
	ID        uint             `gorm:"primaryKey" json:"id"`
	SessionID uint             `gorm:"index;not null" json:"session_id"`
	Session   sessions.Session `gorm:"foreignKey:SessionID" json:"session,omitempty"`
	Datos     []sensors.Sample `gorm:"serializer:json" json:"datos"`
	CreatedAt time.Time        `json:"created_at"`
}
