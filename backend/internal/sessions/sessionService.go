package sessions

import (
	"bytes"
	"encoding/csv"
	"errors"
	"fmt"
	"strconv"
	"strings"
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
	if session.EndTime == nil {
		now := time.Now()
		session.EndTime = &now
	}
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
	session, err := s.repo.GetByID(sessionID)
	if err != nil {
		return nil, err
	}

	groups, err := s.repo.GetExportGroups(sessionID)
	if err != nil {
		return nil, err
	}

	var buf bytes.Buffer
	writer := csv.NewWriter(&buf)

	// Agregar metadatos de la sesión
	writer.Write([]string{"#_METADATOS_DE_LA_SESION"})
	writer.Write([]string{"#_ID_Sesion", strconv.Itoa(int(session.ID))})
	writer.Write([]string{"#_Fecha_Inicio", session.StartTime.Format(time.RFC3339)})
	endTimeStr := ""
	if session.EndTime != nil {
		endTimeStr = session.EndTime.Format(time.RFC3339)
	}
	writer.Write([]string{"#_Fecha_Fin", endTimeStr})
	// Eliminar espacios y saltos de línea de las notas para no romper el CSV si lo leen por espacio
	notasLimpias := strings.ReplaceAll(session.Notes, " ", "_")
	notasLimpias = strings.ReplaceAll(notasLimpias, "\n", "_")
	writer.Write([]string{"#_Notas_Clinicas", notasLimpias})
	writer.Write([]string{""})

	if err := writer.Write([]string{
		"sensor",
		"valor",
		"unidad",
		"timestamp",
		"alerta",
	}); err != nil {
		return nil, err
	}

	for _, group := range groups {
		for _, measurement := range group.Measurements {
			for _, sample := range measurement.Datos {
				timestamp := measurement.CreatedAt.UTC().Format(time.RFC3339)
				if sample.Timestamp > 0 {
					timestamp = time.UnixMilli(sample.Timestamp).UTC().Format(time.RFC3339)
				}

				if err := writer.Write([]string{
					group.Sensor,
					strconv.FormatFloat(sample.Value, 'f', -1, 64),
					group.ValueUnit,
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
