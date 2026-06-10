package sessions

import "gorm.io/gorm"

type SessionRepository interface {
	Create(session *Session) error
	GetByID(id uint) (*Session, error)
	GetByUserID(userID uint) ([]Session, error)
	Update(session *Session) error
	Delete(id uint) error
	GetSummary(sessionID uint) (*SessionSummaryResponse, error)
}

type gormSessionRepository struct {
	db *gorm.DB
}

func NewGormSessionRepository(db *gorm.DB) SessionRepository {
	return &gormSessionRepository{db: db}
}

func (r *gormSessionRepository) Create(session *Session) error {
	return r.db.Create(session).Error
}

func (r *gormSessionRepository) GetByID(id uint) (*Session, error) {
	var session Session
	if err := r.db.First(&session, id).Error; err != nil {
		return nil, err
	}
	return &session, nil
}

func (r *gormSessionRepository) GetByUserID(userID uint) ([]Session, error) {
	var sessions []Session
	if err := r.db.Where("user_id = ?", userID).Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

func (r *gormSessionRepository) Update(session *Session) error {
	return r.db.Save(session).Error
}

func (r *gormSessionRepository) Delete(id uint) error {
	return r.db.Delete(&Session{}, id).Error
}

func calculateAverage(measurements []SensorMeasurement) float64 {
	if len(measurements) == 0 {
		return 0
	}
	var sum float64
	var count int
	for _, m := range measurements {
		for _, sample := range m.Datos {
			sum += sample.Value
			count++
		}
	}
	if count == 0 {
		return 0
	}
	return sum / float64(count)
}

func (r *gormSessionRepository) GetSummary(sessionID uint) (*SessionSummaryResponse, error) {
	session, err := r.GetByID(sessionID)
	if err != nil {
		return nil, err
	}

	var bpmData []SensorMeasurement
	var ecgData []SensorMeasurement
	var spo2Data []SensorMeasurement
	var airData []SensorMeasurement

	r.db.Table("bpm_measurements").Where("session_id = ?", sessionID).Find(&bpmData)
	r.db.Table("ecg_measurements").Where("session_id = ?", sessionID).Find(&ecgData)
	r.db.Table("spo2_measurements").Where("session_id = ?", sessionID).Find(&spo2Data)
	r.db.Table("air_measurements").Where("session_id = ?", sessionID).Find(&airData)

	summary := &SessionSummaryResponse{
		SessionID: sessionID,
		Notes:     session.Notes,
		AvgBPM:    calculateAverage(bpmData),
		AvgECG:    calculateAverage(ecgData),
		AvgSPO2:   calculateAverage(spo2Data),
		AvgAIR:    calculateAverage(airData),
	}

	return summary, nil
}
