package sessions

import (
	"time"

	"backend/internal/users"
)

// Session represents a recording session for a user.
type Session struct {
	ID        uint       `gorm:"primaryKey" json:"id"`
	UserID    uint       `gorm:"not null" json:"user_id"`
	User      users.User `gorm:"foreignKey:UserID" json:"user,omitempty"`
	StartTime time.Time  `gorm:"not null" json:"start_time"`
	EndTime   *time.Time `json:"end_time,omitempty"`
}
