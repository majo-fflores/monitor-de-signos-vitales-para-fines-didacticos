package sessions

import (
	"bytes"
	"encoding/csv"
	"errors"
	"fmt"
	"strconv"
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
	ExportSessionCSV(sessionID uint) ([]byte, error)
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

func (s *sessionService) ExportSessionCSV(sessionID uint) ([]byte, error) {
	if _, err := s.repo.GetByID(sessionID); err != nil {
		return nil, err
	}

	groups, err := s.repo.GetExportGroups(sessionID)
	if err != nil {
		return nil, err
	}

	var buf bytes.Buffer
	writer := csv.NewWriter(&buf)

	if err := writer.Write([]string{
		"sensor",
		"resultado_medicion",
		"timestamp",
		"alerta",
	}); err != nil {
		return nil, err
	}

	for _, group := range groups {
		for _, measurement := range group.Measurements {
			for _, sample := range measurement.Datos {
				timestamp := measurement.CreatedAt.Local().Format("2006-01-02 15:04:05.000")
				if sample.Timestamp > 0 {
					timestamp = time.UnixMilli(sample.Timestamp).Local().Format("2006-01-02 15:04:05.000")
				}

				if err := writer.Write([]string{
					group.Sensor,
					formatMeasurementResult(sample.Value, group.ValueUnit),
					timestamp,
					formatAlert(sample.Alert, sample.LeadsOff),
				}); err != nil {
					return nil, err
				}
			}
		}
	}

	writer.Flush()
	if err := writer.Error(); err != nil {
		return nil, err
	}

	return buf.Bytes(), nil
}

func formatMeasurementResult(value float64, unit string) string {
	formattedValue := strconv.FormatFloat(value, 'f', -1, 64)
	if unit == "" {
		return formattedValue
	}
	if unit == "%" {
		return formattedValue + "%"
	}
	return formattedValue + " " + unit
}

func formatAlert(alert *bool, leadsOff *bool) string {
	if alert != nil {
		return yesNo(*alert)
	}
	if leadsOff != nil {
		return yesNo(*leadsOff)
	}
	return "NO"
}

func yesNo(value bool) string {
	if value {
		return "SI"
	}
	return "NO"
}
