package users

import (
    "errors"

    "gorm.io/gorm"
)

type Service interface {
    CreateUser(user *User) error
    GetUsers() ([]User, error)
    GetUser(id uint) (*User, error)
    DeleteUser(id uint) error
}

type service struct {
    repo UserRepository
}

var ServiceInstance Service

func NewService(db *gorm.DB) Service {
    repo := NewGormUserRepository(db)
    return &service{repo: repo}
}

func (s *service) CreateUser(user *User) error {
    if user.Name == "" || user.Email == "" || user.DNI <= 0 {
        return errors.New("el nombre, el email y un DNI válido son obligatorios")
    }
    return s.repo.Create(user)
}

func (s *service) GetUsers() ([]User, error) {
    return s.repo.GetAll()
}

func (s *service) GetUser(id uint) (*User, error) {
    return s.repo.GetByID(id)
}

func (s *service) DeleteUser(id uint) error {
    return s.repo.Delete(id)
}
