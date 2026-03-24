// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"github.com/google/uuid"
)

// PhoneNumberRequests - структура для запроса,
// содержащего только номер телефона
type PhoneNumberRequest struct {
	Phone string `json:"phone" binding:"required"`
}

// UserIDRequest - структура для запросов, содержащих
// только ID пользователя в Body
type UserIDRequest struct {
	UserID uuid.UUID `json:"user-id" binding:"required"`
}
