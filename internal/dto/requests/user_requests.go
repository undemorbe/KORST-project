// requests - пакет, содержащий структуры запросов по Api
package requests

import "gorm.io/datatypes"

// UpdateRequest - структура для запроса
// на обновление профиля пользователя
type UpdateUserRequest struct {
	Name        *string `json:"name"`
	Surname     *string `json:"surname"`
	Description *string `json:"description"`

	Contacts *Contacts `json:"contacts"`
}

type Contacts struct {
	Email    *string `json:"email"`
	Telegram *string `json:"telegram"`

	Others *datatypes.JSONMap `json:"others"`
}
