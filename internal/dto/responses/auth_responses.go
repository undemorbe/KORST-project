// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// IsUserResponse - структура для ответа на запрос проверки пользователя
type IsUserResponse struct {
	Status string `json:"status"`
}

// VerifyOTPResponse - структура для ответа на запрос подтверждения OTP кода
type VerifyOTPResponse struct {
	AccessToken  string `json:"access-token"`
	RefreshToken string `json:"refresh-token"`
	Status       string `json:"status"`
}

// RefreshResponse - структура для ответа на запрос обновления refresh токена
type RefreshResponse struct {
	AccessToken  string `json:"access-token"`
	RefreshToken string `json:"refresh-token"`
}

// NotisendResponse - структура для получения ответа при отправке кода
type NotisendResponse struct {
	Status string `json:"status"`
}
