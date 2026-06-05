package spo2

import "gorm.io/gorm"

type Spo2Repository interface {
	Create(measurement *Spo2Measurement) error
	GetByID(id uint) (*Spo2Measurement, error)
	GetBySessionID(sessionID uint) ([]Spo2Measurement, error)
	Delete(id uint) error
}

type gormSpo2Repository struct {
	db *gorm.DB
}

func NewGormSpo2Repository(db *gorm.DB) Spo2Repository {
	return &gormSpo2Repository{db: db}
}

func (r *gormSpo2Repository) Create(measurement *Spo2Measurement) error {
	return r.db.Create(measurement).Error
}

func (r *gormSpo2Repository) GetByID(id uint) (*Spo2Measurement, error) {
	var measurement Spo2Measurement
	if err := r.db.First(&measurement, id).Error; err != nil {
		return nil, err
	}
	return &measurement, nil
}

func (r *gormSpo2Repository) GetBySessionID(sessionID uint) ([]Spo2Measurement, error) {
	var measurements []Spo2Measurement
	if err := r.db.Where("session_id = ?", sessionID).Find(&measurements).Error; err != nil {
		return nil, err
	}
	return measurements, nil
}

func (r *gormSpo2Repository) Delete(id uint) error {
	return r.db.Delete(&Spo2Measurement{}, id).Error
}
