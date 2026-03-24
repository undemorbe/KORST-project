// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"github.com/google/uuid"
)

// PostReviewRequest - структура для запроса на
// размещение отзыва о пользователе
type PostReviewRequest struct {
	UserID  uuid.UUID `json:"user-id" binding:"required"`
	Rating  float64   `json:"rating" binding:"required"`
	Comment *string   `json:"comment"`
}
