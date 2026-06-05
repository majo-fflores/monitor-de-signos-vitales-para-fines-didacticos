package bpm

import "gorm.io/gorm"

type BpmRepository interface {
	Create(measurement *BpmMeasurement) error
	GetByID(id uint) (*BpmMeasurement, error)
	GetBySessionID(sessionID uint) ([]BpmMeasurement, error)
	Delete(id uint) error
}

type gormBpmRepository struct {
	db *gorm.DB
}

func NewGormBpmRepository(db *gorm.DB) BpmRepository {
	return &gormBpmRepository{db: db}
}

func (r *gormBpmRepository) Create(measurement *BpmMeasurement) error {
	return r.db.Create(measurement).Error
}

func (r *gormBpmRepository) GetByID(id uint) (*BpmMeasurement, error) {
	var measurement BpmMeasurement
	if err := r.db.First(&measurement, id).Error; err != nil {
		return nil, err
	}
	return &measurement, nil
}

func (r *gormBpmRepository) GetBySessionID(sessionID uint) ([]BpmMeasurement, error) {
	var measurements []BpmMeasurement
	if err := r.db.Where("session_id = ?", sessionID).Find(&measurements).Error; err != nil {
		return nil, err
	}
	return measurements, nil
}

func (r *gormBpmRepository) Delete(id uint) error {
	return r.db.Delete(&BpmMeasurement{}, id).Error
}
