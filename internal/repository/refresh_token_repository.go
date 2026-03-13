// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// refreshTokenRepo - объект, содержащий методы для работы с сущностью refresh-токена
type refreshTokenRepo struct {
	db *gorm.DB
}

// NewRefreshTokenRepository создает и возвращает новый объект refreshTokenRepo
func NewRefreshTokenRepository(db *gorm.DB) ports.RefreshTokenRepository {
	return &refreshTokenRepo{db: db}
}

// FindByToken находит сущность refresh-токена по его значению
func (r *refreshTokenRepo) FindByToken(
	token string) (*entities.RefreshToken, error) {
	var refreshToken entities.RefreshToken
	err := r.db.Where("token = ?", token).First(&refreshToken).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &refreshToken, nil
}

// CreateRefreshToken создает новый объект токена в БД
func (r *refreshTokenRepo) CreateRefreshToken(
	refreshToken *entities.RefreshToken) error {
	return r.db.Create(refreshToken).Error
}

// UpdateRefreshToken изменяет данные определенного refresh-токена
func (r *refreshTokenRepo) UpdateRefreshToken(
	refreshToken *entities.RefreshToken) error {
	return r.db.Save(refreshToken).Error
}

// DeleteByUserID удаляет все refresh-токены c определенным userID
func (r *refreshTokenRepo) DeleteByUserID(
	userID uuid.UUID) error {
	return r.db.Where("user_id = ?", userID).
		Delete(&entities.RefreshToken{}).Error
}
