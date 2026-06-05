package ecg

import (
	"errors"
	"fmt"

	"backend/internal/sessions"
	"backend/internal/users"
	"gorm.io/gorm"
)

type EcgService interface {
	CreateMeasurement(measurement *EcgMeasurement) error
	GetMeasurementByID(id uint) (*EcgMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]EcgMeasurement, error)
	GetMeasurementsByUserID(userID uint) ([]EcgMeasurement, error)
	DeleteMeasurement(id uint) error
}

type ecgService struct {
	repo EcgRepository
}

var ServiceInstance EcgService

func NewEcgService(db *gorm.DB) EcgService {
	return &ecgService{
		repo: NewGormEcgRepository(db),
	}
}

func (s *ecgService) CreateMeasurement(measurement *EcgMeasurement) error {
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

func (s *ecgService) GetMeasurementByID(id uint) (*EcgMeasurement, error) {
	return s.repo.GetByID(id)
}

func (s *ecgService) GetMeasurementsBySessionID(sessionID uint) ([]EcgMeasurement, error) {
	return s.repo.GetBySessionID(sessionID)
}

func (s *ecgService) GetMeasurementsByUserID(userID uint) ([]EcgMeasurement, error) {
	if _, err := users.ServiceInstance.GetUser(userID); err != nil {
		return nil, fmt.Errorf("usuario con id %d no encontrado", userID)
	}
	userSessions, err := sessions.ServiceInstance.GetSessionsByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("error al obtener sesiones: %w", err)
	}
	var all []EcgMeasurement
	for _, sess := range userSessions {
		mediciones, err := s.repo.GetBySessionID(sess.ID)
		if err == nil {
			all = append(all, mediciones...)
		}
	}
	if all == nil {
		all = []EcgMeasurement{}
	}
	return all, nil
}

func (s *ecgService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
