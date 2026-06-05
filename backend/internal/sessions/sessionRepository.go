package sessions

import "gorm.io/gorm"

type SessionRepository interface {
	Create(session *Session) error
	GetByID(id uint) (*Session, error)
	GetByUserID(userID uint) ([]Session, error)
	Update(session *Session) error
	Delete(id uint) error
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
