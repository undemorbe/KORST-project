// ports - пакет, содержащий все порты (интерфейсы)
package ports

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"

	"github.com/google/uuid"
)

// OTPService содержит порты для методов отправки и подтверждения OTP
type OTPService interface {
	SendOTP(rawPhone string) error
	VerifyOTP(rawPhone string, otp string) (
		responses.VerifyOTPResponse,
		error)
}

// AuthService содержит порты для методов, необходимых для авторизации
type AuthService interface {
	CheckUser(rawPhone string) (
		responses.IsUserResponse, error)
	RegisterUser(req requests.RegisterRequest) error
	GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error)
}

// TokenService содержит порты для методов создания/обновления токенов
type TokenService interface {
	CreateTokens(user *entities.User) (string, string, error)
	DecodeAccessToken(rawToken string) (uuid.UUID, error)
}
