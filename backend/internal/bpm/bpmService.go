package bpm

import (
	"errors"

	"gorm.io/gorm"
)

type BpmService interface {
	CreateMeasurement(measurement *BpmMeasurement) error
	GetMeasurementByID(id uint) (*BpmMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]BpmMeasurement, error)
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

func (s *bpmService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
