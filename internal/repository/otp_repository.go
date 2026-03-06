// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"gorm.io/gorm"
)

// otpRepo - объект, содержащий методы для работы с сущностью Otp кода
type otpRepo struct {
	db *gorm.DB
}

// NewOTPRepository создает и возвращает новый объект otpRepo
func NewOTPRepository(db *gorm.DB) ports.OTPRepository {
	return &otpRepo{db: db}
}

// FindByPhone находит Otp по номеру телефона
func (r *otpRepo) FindByPhone(phone string) (*entities.Otp, error) {
	var otp entities.Otp
	err := r.db.Where("phone = ?", phone).
		Order("expires_at DESC").
		First(&otp).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &otp, nil
}

// CreateOTP создает новый объект Otp в БД
func (r *otpRepo) CreateOTP(otp *entities.Otp) error {
	return r.db.Create(otp).Error
}
