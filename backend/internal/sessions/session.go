package sessions

import "time"

// Session represents a recording session for a user.
type Session struct {
	ID        uint       `gorm:"primaryKey" json:"id"`
	UserID    uint       `gorm:"not null" json:"user_id"`
	StartTime time.Time  `gorm:"not null" json:"start_time"`
	EndTime   *time.Time `json:"end_time,omitempty"`
	Notes     string     `json:"notes,omitempty"`
}
