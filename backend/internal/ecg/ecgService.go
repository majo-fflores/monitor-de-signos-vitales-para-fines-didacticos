package ecg

import (
	"errors"

	"gorm.io/gorm"
)

type EcgService interface {
	CreateMeasurement(measurement *EcgMeasurement) error
	GetMeasurementByID(id uint) (*EcgMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]EcgMeasurement, error)
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

func (s *ecgService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
