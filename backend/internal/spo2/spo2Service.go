package spo2

import (
	"errors"

	"gorm.io/gorm"
)

type Spo2Service interface {
	CreateMeasurement(measurement *Spo2Measurement) error
	GetMeasurementByID(id uint) (*Spo2Measurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]Spo2Measurement, error)
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

func (s *spo2Service) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
