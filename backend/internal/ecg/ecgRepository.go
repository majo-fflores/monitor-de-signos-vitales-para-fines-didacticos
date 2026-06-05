package ecg

import "gorm.io/gorm"

type EcgRepository interface {
	Create(measurement *EcgMeasurement) error
	GetByID(id uint) (*EcgMeasurement, error)
	GetBySessionID(sessionID uint) ([]EcgMeasurement, error)
	Delete(id uint) error
}

type gormEcgRepository struct {
	db *gorm.DB
}

func NewGormEcgRepository(db *gorm.DB) EcgRepository {
	return &gormEcgRepository{db: db}
}

func (r *gormEcgRepository) Create(measurement *EcgMeasurement) error {
	return r.db.Create(measurement).Error
}

func (r *gormEcgRepository) GetByID(id uint) (*EcgMeasurement, error) {
	var measurement EcgMeasurement
	if err := r.db.First(&measurement, id).Error; err != nil {
		return nil, err
	}
	return &measurement, nil
}

func (r *gormEcgRepository) GetBySessionID(sessionID uint) ([]EcgMeasurement, error) {
	var measurements []EcgMeasurement
	if err := r.db.Where("session_id = ?", sessionID).Find(&measurements).Error; err != nil {
		return nil, err
	}
	return measurements, nil
}

func (r *gormEcgRepository) Delete(id uint) error {
	return r.db.Delete(&EcgMeasurement{}, id).Error
}
