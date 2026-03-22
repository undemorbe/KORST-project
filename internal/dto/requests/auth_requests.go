// requests - пакет, содержащий структуры запросов по Api
package requests

// PhoneNumberRequests - структура для запроса,
// содержащего только номер телефона
type PhoneNumberRequest struct {
	Phone string `json:"phone" binding:"required"`
}

// VerifyOTPRequest - структура для запроса на подтверждение OTP кода
type VerifyOTPRequest struct {
	Phone string `json:"phone" binding:"required"`
	OTP   string `json:"otp" binding:"required"`
}

// RefreshRequest - структура для запроса на обновление refresh токена
type RefreshRequest struct {
	RefreshToken string `json:"refresh-token" binding:"required"`
}
