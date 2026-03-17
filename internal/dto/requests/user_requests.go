// requests - пакет, содержащий структуры запросов по Api
package requests

// UpdateRequest - структура для запроса
// на обновление профиля пользователя
type UpdateUserRequest struct {
	Name        *string `json:"name" binding:"required"`
	Surname     *string `json:"surname" binding:"required"`
	Description *string `json:"description" binding:"required"`

	Contacts *Contacts `json:"contacts" binding:"required"`
}

type Contacts struct {
	Email    *string `json:"email" binding:"required"`
	Telegram *string `json:"telegram" binding:"required"`

	Others *map[string]string `json:"others" binding:"required"`
}
