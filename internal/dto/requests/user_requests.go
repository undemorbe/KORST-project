// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"gorm.io/datatypes"
)

// UpdateRequest - структура для запроса
// на обновление профиля пользователя
type UpdateUserRequest struct {
	Name        *string `json:"name,omitempty"`
	Surname     *string `json:"surname,omitempty"`
	Description *string `json:"description,omitempty"`

	Contacts *Contacts `json:"contacts,omitempty"`
}

// Contacts - структура с контактами автора карточки
type Contacts struct {
	Email    *string `json:"email,omitempty"`
	Telegram *string `json:"telegram,omitempty"`

	Others *datatypes.JSONMap `json:"others,omitempty"`
}
