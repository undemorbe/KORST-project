// ports - пакет, содержащий все порты (интерфейсы)
package ports

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
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
}
