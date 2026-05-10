// requests - пакет, содержащий структуры запросов по Api
package requests

// PhoneNumberRequests - структура для запроса,
// содержащего только номер телефона в Params или Body
type PhoneNumberRequest struct {
	Phone string `json:"phone" form:"phone" binding:"required"`
}

// UserIDRequest - структура для запросов, содержащих
// только ID пользователя в Params или Body
type UserIDRequest struct {
	UserID string `json:"user-id" form:"user-id" binding:"required"`
}

// CreateReply - структура для запросов, содержащих
// только ID карточки объявления в Params или Body
type CardIDRequest struct {
	CardID string `json:"card-id" form:"card-id" binding:"required"`
}
