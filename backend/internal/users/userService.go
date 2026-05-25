package users

import (
    "gorm.io/gorm"
)

// Service defines the business logic for user management.
type Service interface {
    CreateUser(user *User) error
    GetUsers() ([]User, error)
    GetUser(id uint) (*User, error)
}

// service implements Service using a UserRepository.
type service struct {
    repo UserRepository
}

// ServiceInstance is the globally accessible implementation used by controllers.
var ServiceInstance Service

// NewService creates a new Service implementation using the provided GORM DB.
func NewService(db *gorm.DB) Service {
    repo := NewGormUserRepository(db)
    return &service{repo: repo}
}

// CreateUser creates a new user via the repository.
func (s *service) CreateUser(user *User) error {
    return s.repo.Create(user)
}

// GetUsers retrieves all users via the repository.
func (s *service) GetUsers() ([]User, error) {
    return s.repo.GetAll()
}

// GetUser retrieves a user by ID via the repository.
func (s *service) GetUser(id uint) (*User, error) {
    return s.repo.GetByID(id)
}
