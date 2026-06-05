package spo2

import (
	"errors"
	"fmt"

	"backend/internal/sessions"
	"backend/internal/users"
	"gorm.io/gorm"
)

type Spo2Service interface {
	CreateMeasurement(measurement *Spo2Measurement) error
	GetMeasurementByID(id uint) (*Spo2Measurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]Spo2Measurement, error)
	GetMeasurementsByUserID(userID uint) ([]Spo2Measurement, error)
	DeleteMeasurement(id uint) error
}

type spo2Service struct {
	repo Spo2Repository
}

var ServiceInstance Spo2Service

func NewSpo2Service(db *gorm.DB) Spo2Service {
	return &spo2Service{
		repo: NewGormSpo2Repository(db),
	}
}

func (s *spo2Service) CreateMeasurement(measurement *Spo2Measurement) error {
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

func (s *spo2Service) GetMeasurementByID(id uint) (*Spo2Measurement, error) {
	return s.repo.GetByID(id)
}

func (s *spo2Service) GetMeasurementsBySessionID(sessionID uint) ([]Spo2Measurement, error) {
	return s.repo.GetBySessionID(sessionID)
}

func (s *spo2Service) GetMeasurementsByUserID(userID uint) ([]Spo2Measurement, error) {
	if _, err := users.ServiceInstance.GetUser(userID); err != nil {
		return nil, fmt.Errorf("usuario con id %d no encontrado", userID)
	}
	userSessions, err := sessions.ServiceInstance.GetSessionsByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("error al obtener sesiones: %w", err)
	}
	var all []Spo2Measurement
	for _, sess := range userSessions {
		mediciones, err := s.repo.GetBySessionID(sess.ID)
		if err == nil {
			all = append(all, mediciones...)
		}
	}
	if all == nil {
		all = []Spo2Measurement{}
	}
	return all, nil
}

func (s *spo2Service) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
