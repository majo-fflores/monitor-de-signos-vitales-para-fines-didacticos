package sessions

import "gorm.io/gorm"

type SessionRepository interface {
	Create(session *Session) error
	GetByID(id uint) (*Session, error)
	GetByUserID(userID uint) ([]Session, error)
	Update(session *Session) error
	Delete(id uint) error
	GetSummary(sessionID uint) (*SessionSummaryResponse, error)
	GetUserSessionSummaries(userID uint) ([]SessionWithSummary, error)
	GetExportGroups(sessionID uint) ([]SensorExportGroup, error)
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

func (r *gormSessionRepository) GetExportGroups(sessionID uint) ([]SensorExportGroup, error) {
	configs := []struct {
		sensor    string
		valueUnit string
		tableName string
	}{
		{sensor: "ECG", valueUnit: "adc", tableName: "ecg_measurements"},
		{sensor: "BPM", valueUnit: "bpm", tableName: "bpm_measurements"},
		{sensor: "CO2", valueUnit: "ppm", tableName: "air_measurements"},
		{sensor: "SPO2", valueUnit: "%", tableName: "spo2_measurements"},
	}

	groups := make([]SensorExportGroup, 0, len(configs))
	for _, config := range configs {
		var measurements []SensorMeasurement
		if err := r.db.Table(config.tableName).
			Where("session_id = ?", sessionID).
			Order("created_at ASC").
			Find(&measurements).Error; err != nil {
			return nil, err
		}

		groups = append(groups, SensorExportGroup{
			Sensor:       config.sensor,
			ValueUnit:    config.valueUnit,
			Measurements: measurements,
		})
	}

	return groups, nil
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

func countAlerts(bpmData []SensorMeasurement, airData []SensorMeasurement) int {
	var alerts int
	for _, m := range bpmData {
		for _, sample := range m.Datos {
			if sample.Alert != nil {
				if *sample.Alert {
					alerts++
				}
				continue
			}
			if sample.Value < 60 || sample.Value > 100 {
				alerts++
			}
		}
	}
	for _, m := range airData {
		for _, sample := range m.Datos {
			if sample.Alert != nil {
				if *sample.Alert {
					alerts++
				}
				continue
			}
			if sample.Value > 1000 {
				alerts++
			}
		}
	}
	return alerts
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
		SessionID:  sessionID,
		Notes:      session.Notes,
		AvgBPM:     calculateAverage(bpmData),
		AvgECG:     calculateAverage(ecgData),
		AvgSPO2:    calculateAverage(spo2Data),
		AvgAIR:     calculateAverage(airData),
		AlertCount: countAlerts(bpmData, airData),
	}

	return summary, nil
}

func (r *gormSessionRepository) GetUserSessionSummaries(userID uint) ([]SessionWithSummary, error) {
	sessions, err := r.GetByUserID(userID)
	if err != nil {
		return nil, err
	}

	if len(sessions) == 0 {
		return []SessionWithSummary{}, nil
	}

	sessionIDs := make([]uint, len(sessions))
	for i, s := range sessions {
		sessionIDs[i] = s.ID
	}

	var bpmData []SensorMeasurement
	var ecgData []SensorMeasurement
	var spo2Data []SensorMeasurement
	var airData []SensorMeasurement

	r.db.Table("bpm_measurements").Where("session_id IN ?", sessionIDs).Find(&bpmData)
	r.db.Table("ecg_measurements").Where("session_id IN ?", sessionIDs).Find(&ecgData)
	r.db.Table("spo2_measurements").Where("session_id IN ?", sessionIDs).Find(&spo2Data)
	r.db.Table("air_measurements").Where("session_id IN ?", sessionIDs).Find(&airData)

	bpmBySession := make(map[uint][]SensorMeasurement)
	for _, m := range bpmData {
		bpmBySession[m.SessionID] = append(bpmBySession[m.SessionID], m)
	}
	ecgBySession := make(map[uint][]SensorMeasurement)
	for _, m := range ecgData {
		ecgBySession[m.SessionID] = append(ecgBySession[m.SessionID], m)
	}
	spo2BySession := make(map[uint][]SensorMeasurement)
	for _, m := range spo2Data {
		spo2BySession[m.SessionID] = append(spo2BySession[m.SessionID], m)
	}
	airBySession := make(map[uint][]SensorMeasurement)
	for _, m := range airData {
		airBySession[m.SessionID] = append(airBySession[m.SessionID], m)
	}

	results := make([]SessionWithSummary, 0, len(sessions))
	for _, session := range sessions {
		bpm := bpmBySession[session.ID]
		ecg := ecgBySession[session.ID]
		spo2 := spo2BySession[session.ID]
		air := airBySession[session.ID]

		results = append(results, SessionWithSummary{
			Session:    session,
			AvgBPM:     calculateAverage(bpm),
			AvgECG:     calculateAverage(ecg),
			AvgSPO2:    calculateAverage(spo2),
			AvgAIR:     calculateAverage(air),
			AlertCount: countAlerts(bpm, air),
		})
	}

	return results, nil
}
