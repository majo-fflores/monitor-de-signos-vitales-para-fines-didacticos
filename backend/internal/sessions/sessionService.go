package sessions

import (
	"errors"
	"fmt"
	"time"

	"backend/internal/users"
	"gorm.io/gorm"
)

type SessionService interface {
	CreateSession(session *Session) error
	GetSessionByID(id uint) (*Session, error)
	GetSessionsByUserID(userID uint) ([]Session, error)
	EndSession(id uint, notes string) error
	DeleteSession(id uint) error
	GetSessionSummary(sessionID uint) (*SessionSummaryResponse, error)
	GetUserSessionSummaries(userID uint) ([]SessionWithSummary, error)
}

type sessionService struct {
	repo SessionRepository
}

var ServiceInstance SessionService

func NewSessionService(db *gorm.DB) SessionService {
	return &sessionService{
		repo: NewGormSessionRepository(db),
	}
}

func (s *sessionService) CreateSession(session *Session) error {
	if session.UserID == 0 {
		return errors.New("user_id is required")
	}
	if _, err := users.ServiceInstance.GetUser(session.UserID); err != nil {
		return fmt.Errorf("usuario con id %d no encontrado", session.UserID)
	}
	if session.StartTime.IsZero() {
		session.StartTime = time.Now()
	}
	return s.repo.Create(session)
}

func (s *sessionService) GetSessionByID(id uint) (*Session, error) {
	return s.repo.GetByID(id)
}

func (s *sessionService) GetSessionsByUserID(userID uint) ([]Session, error) {
	return s.repo.GetByUserID(userID)
}

func (s *sessionService) EndSession(id uint, notes string) error {
	session, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	now := time.Now()
	session.EndTime = &now
	session.Notes = notes
	return s.repo.Update(session)
}

func (s *sessionService) DeleteSession(id uint) error {
	return s.repo.Delete(id)
}

func (s *sessionService) GetSessionSummary(sessionID uint) (*SessionSummaryResponse, error) {
	return s.repo.GetSummary(sessionID)
}

func (s *sessionService) GetUserSessionSummaries(userID uint) ([]SessionWithSummary, error) {
	return s.repo.GetUserSessionSummaries(userID)
}
