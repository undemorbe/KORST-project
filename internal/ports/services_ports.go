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
	// SendOTP отправляет Otp-код по номеру телефона и сохраняет его
	SendOTP(rawPhone string) error

	// VerifyOTP сравнивает полученный Otp-код c сохраненным в БД
	VerifyOTP(rawPhone string, otp string) (
		responses.VerifyOTPResponse,
		error)
}

// AuthService содержит порты для методов, необходимых для авторизации
type AuthService interface {
	// CheckUser находит пользователя по телефону и проверяет его
	// статус (notFound / notRegistered / registered)
	CheckUser(rawPhone string) (
		responses.IsUserResponse, error)

	// RegisterUser добавляет пользователя в БД или дополняет информацию о нем
	RegisterUser(req requests.RegisterRequest) error

	// GetNewTokens получает новые access и refresh токены для пользователя
	GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error)
}

// TokenService содержит порты для методов создания/обновления токенов
type TokenService interface {
	// CreateTokens создает новый access-токен,
	// обновляет (или создает новый) refresh-токен.
	CreateTokens(user *entities.User) (string, string, error)

	// DecodeAccessToken декодирует полученный access-токен,
	// проверяет его валидность
	DecodeAccessToken(rawToken string) (uuid.UUID, error)
}
