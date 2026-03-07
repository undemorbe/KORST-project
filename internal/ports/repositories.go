// ports - пакет, содержащий все порты (интерфейсы)
package ports

import (
	"korst-backend/internal/entities"
)

// UserRepository содержит порты для взаимодействия с User в БД
type UserRepository interface {
	FindByPhone(phone string) (*entities.User, error)
	CreateUser(user *entities.User) error
	UpdateUser(user *entities.User) error
}

// OTPRepository содержит порты для взаимодействия с Otp в БД
type OTPRepository interface {
	FindByPhone(phone string) (*entities.Otp, error)
	CreateOTP(otp *entities.Otp) error
}

// RefreshTokenRepository содержит порты для взаимодействия с
// refresh-токенами в БД
type RefreshTokenRepository interface {
	FindByToken(token string) (*entities.RefreshToken, error)
	UpdateRefreshToken(refreshToken *entities.RefreshToken) error
}
