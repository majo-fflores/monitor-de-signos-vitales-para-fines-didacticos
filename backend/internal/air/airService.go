package air

import (
	"errors"
	"fmt"

	"backend/internal/sessions"
	"backend/internal/users"
	"gorm.io/gorm"
)

type AirService interface {
	CreateMeasurement(measurement *AirMeasurement) error
	GetMeasurementByID(id uint) (*AirMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]AirMeasurement, error)
	GetMeasurementsByUserID(userID uint) ([]AirMeasurement, error)
	DeleteMeasurement(id uint) error
}

type airService struct {
	repo AirRepository
}

var ServiceInstance AirService

func NewAirService(db *gorm.DB) AirService {
	return &airService{
		repo: NewGormAirRepository(db),
	}
}

func (s *airService) CreateMeasurement(measurement *AirMeasurement) error {
	if measurement.SessionID == 0 {
		return errors.New("session_id is required")
	}
	if _, err := sessions.ServiceInstance.GetSessionByID(measurement.SessionID); err != nil {
		return fmt.Errorf("sesión con id %d no encontrada", measurement.SessionID)
	}
	if len(measurement.Datos) == 0 {
		return errors.New("datos cannot be empty")
	}
	return s.repo.Create(measurement)
}

func (s *airService) GetMeasurementByID(id uint) (*AirMeasurement, error) {
	return s.repo.GetByID(id)
}

func (s *airService) GetMeasurementsBySessionID(sessionID uint) ([]AirMeasurement, error) {
	return s.repo.GetBySessionID(sessionID)
}

func (s *airService) GetMeasurementsByUserID(userID uint) ([]AirMeasurement, error) {
	if _, err := users.ServiceInstance.GetUser(userID); err != nil {
		return nil, fmt.Errorf("usuario con id %d no encontrado", userID)
	}
	userSessions, err := sessions.ServiceInstance.GetSessionsByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("error al obtener sesiones: %w", err)
	}
	var all []AirMeasurement
	for _, sess := range userSessions {
		mediciones, err := s.repo.GetBySessionID(sess.ID)
		if err == nil {
			all = append(all, mediciones...)
		}
	}
	if all == nil {
		all = []AirMeasurement{}
	}
	return all, nil
}

func (s *airService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
