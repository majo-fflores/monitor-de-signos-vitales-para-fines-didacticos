package users

import (
    "gorm.io/gorm"
)

type UserRepository interface {
    Create(user *User) error
    GetAll() ([]User, error)
    GetByID(id uint) (*User, error)
}

// GormUserRepository implements UserRepository using GORM.
type GormUserRepository struct {
    db *gorm.DB
}

// NewGormUserRepository creates a new repository instance.
func NewGormUserRepository(db *gorm.DB) UserRepository {
    return &GormUserRepository{db: db}
}

func (r *GormUserRepository) Create(user *User) error {
    return r.db.Create(user).Error
}

func (r *GormUserRepository) GetAll() ([]User, error) {
    var users []User
    if err := r.db.Find(&users).Error; err != nil {
        return nil, err
    }
    return users, nil
}

func (r *GormUserRepository) GetByID(id uint) (*User, error) {
    var user User
    if err := r.db.First(&user, id).Error; err != nil {
        return nil, err
    }
    return &user, nil
}
