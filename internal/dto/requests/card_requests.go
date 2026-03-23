// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"time"

	"github.com/google/uuid"
)

// GetCardsRequest - структура для запроса на просмотр карточек
type GetCardsRequest struct {
	Key *time.Time `json:"key"`
}

// CardInfoRequest - структура для запроса на просмотр конкретной карточки
type CardInfoRequest struct {
	CardID uuid.UUID `json:"card-id" binding:"required"`
}

// SaveCardRequest - структура для запроса на
// сохранение карточки объявления
type SaveCardRequest struct {
	Name        string  `json:"name" binding:"required"`
	Description *string `json:"description"`

	Price    float64  `json:"price" binding:"required"`
	Currency string   `json:"currency" binding:"required"`
	Type     string   `json:"type" binding:"required"`
	Tags     []string `json:"tags" binding:"required"`
}
