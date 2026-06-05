package air

import (
	"errors"

	"gorm.io/gorm"
)

type AirService interface {
	CreateMeasurement(measurement *AirMeasurement) error
	GetMeasurementByID(id uint) (*AirMeasurement, error)
	GetMeasurementsBySessionID(sessionID uint) ([]AirMeasurement, error)
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

func (s *airService) DeleteMeasurement(id uint) error {
	return s.repo.Delete(id)
}
