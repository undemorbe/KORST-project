// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"github.com/google/uuid"
	"gorm.io/datatypes"
)

// UpdateRequest - структура для запроса
// на обновление профиля пользователя
type UpdateUserRequest struct {
	Name        *string `json:"name"`
	Surname     *string `json:"surname"`
	Description *string `json:"description"`

	Contacts *Contacts `json:"contacts"`
}

// Contacts - структура с контактами автора карточки
type Contacts struct {
	Email    *string `json:"email"`
	Telegram *string `json:"telegram"`

	Others *datatypes.JSONMap `json:"others"`
}

// UserIDRequest - структура для запросов, содержащих
// только ID пользователя в Body
type UserIDRequest struct {
	UserID uuid.UUID `json:"user-id" binding:"required"`
}

// PostReviewRequest - структура для запроса на
// размещение отзыва о пользователе
type PostReviewRequest struct {
	UserID  uuid.UUID `json:"user-id" binding:"required"`
	Rating  float64   `json:"rating" binding:"required"`
	Comment *string   `json:"comment"`
}
