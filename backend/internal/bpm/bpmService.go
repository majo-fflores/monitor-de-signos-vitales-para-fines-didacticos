package bpm

import (
	"errors"
	"fmt"

	"backend/internal/sessions"
	"backend/internal/users"
	"gorm.io/gorm"
)

type BpmService interface {
	CreateMeasurement(measurement *BpmMeasurement) error
	GetMeasurementByID(id uint) (*BpmMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]BpmMeasurement, error)
	GetMeasurementsByUserID(userID uint) ([]BpmMeasurement, error)
	DeleteMeasurement(id uint) error
}

type bpmService struct {
	repo BpmRepository
}

var ServiceInstance BpmService

func NewBpmService(db *gorm.DB) BpmService {
	return &bpmService{
		repo: NewGormBpmRepository(db),
	}
}

func (s *bpmService) CreateMeasurement(measurement *BpmMeasurement) error {
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

func (s *bpmService) GetMeasurementByID(id uint) (*BpmMeasurement, error) {
	return s.repo.GetByID(id)
}

func (s *bpmService) GetMeasurementsBySessionID(sessionID uint) ([]BpmMeasurement, error) {
	return s.repo.GetBySessionID(sessionID)
}

func (s *bpmService) GetMeasurementsByUserID(userID uint) ([]BpmMeasurement, error) {
	if _, err := users.ServiceInstance.GetUser(userID); err != nil {
		return nil, fmt.Errorf("usuario con id %d no encontrado", userID)
	}
	userSessions, err := sessions.ServiceInstance.GetSessionsByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("error al obtener sesiones: %w", err)
	}
	var all []BpmMeasurement
	for _, sess := range userSessions {
		mediciones, err := s.repo.GetBySessionID(sess.ID)
		if err == nil {
			all = append(all, mediciones...)
		}
	}
	if all == nil {
		all = []BpmMeasurement{}
	}
	return all, nil
}

func (s *bpmService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
