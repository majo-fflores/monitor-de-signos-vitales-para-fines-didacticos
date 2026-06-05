package air

import (
	"time"

	"backend/internal/sensors"
)

// AirMeasurement stores an array of Air Quality samples for a given session.
type AirMeasurement struct {
	ID        uint             `gorm:"primaryKey" json:"id"`
	SessionID uint             `gorm:"index;not null" json:"session_id"`
	Datos     []sensors.Sample `gorm:"serializer:json" json:"datos"`
	CreatedAt time.Time        `json:"created_at"`
}
