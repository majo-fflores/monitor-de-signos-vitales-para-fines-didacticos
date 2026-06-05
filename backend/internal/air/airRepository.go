package air

import "gorm.io/gorm"

type AirRepository interface {
	Create(measurement *AirMeasurement) error
	GetByID(id uint) (*AirMeasurement, error)
	GetBySessionID(sessionID uint) ([]AirMeasurement, error)
	Delete(id uint) error
}

type gormAirRepository struct {
	db *gorm.DB
}

func NewGormAirRepository(db *gorm.DB) AirRepository {
	return &gormAirRepository{db: db}
}

func (r *gormAirRepository) Create(measurement *AirMeasurement) error {
	return r.db.Create(measurement).Error
}

func (r *gormAirRepository) GetByID(id uint) (*AirMeasurement, error) {
	var measurement AirMeasurement
	if err := r.db.First(&measurement, id).Error; err != nil {
		return nil, err
	}
	return &measurement, nil
}

func (r *gormAirRepository) GetBySessionID(sessionID uint) ([]AirMeasurement, error) {
	var measurements []AirMeasurement
	if err := r.db.Where("session_id = ?", sessionID).Find(&measurements).Error; err != nil {
		return nil, err
	}
	return measurements, nil
}

func (r *gormAirRepository) Delete(id uint) error {
	return r.db.Delete(&AirMeasurement{}, id).Error
}
