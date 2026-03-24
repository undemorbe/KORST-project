// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// userRepo - объект, содержащий методы для работы с сущностью пользователя
type userRepo struct {
	db *gorm.DB
}

// NewUserRepository создает и возвращает новый объект userRepo
func NewUserRepository(db *gorm.DB) ports.UserRepository {
	return &userRepo{db: db}
}

// FindByID находит пользователя по его ID
func (r *userRepo) FindByID(userID uuid.UUID) (*entities.User, error) {
	var user entities.User

	err := r.db.
		Preload("Profile").
		Preload("Cards").
		First(&user, userID).
		Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByPhone находит пользователя по номеру телефона
func (r *userRepo) FindByPhone(phone string) (*entities.User, error) {
	var user entities.User

	err := r.db.
		Preload("Profile").
		Where("phone = ?", phone).
		First(&user).
		Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// CreateUser создает новый объект пользователя в БД
func (r *userRepo) CreateUser(user *entities.User) error {
	return r.db.Create(user).Error
}

// UpdateUser изменяет данные определенного пользователя
func (r *userRepo) UpdateUser(user *entities.User) error {
	return r.db.Save(user).Error
}
