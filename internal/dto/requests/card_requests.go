// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"github.com/google/uuid"
)

// GetCardsRequest - структура для запроса на просмотр карточек
type GetCardsRequest struct {
	Key *string `form:"key"`
}

// CardInfoRequest - структура для запроса на просмотр конкретной карточки
type CardInfoRequest struct {
	CardID string `form:"card-id" binding:"required"`
}

// SaveCardRequest - структура для запроса на
// сохранение карточки объявления
type SaveCardRequest struct {
	Name        string  `json:"name" binding:"required"`
	Description *string `json:"description,omitempty"`

	Price    float64  `json:"price" binding:"required"`
	Currency string   `json:"currency" binding:"required"`
	Type     string   `json:"type" binding:"required"`
	Tags     []string `json:"tags" binding:"required"`
}

// UpdateCardRequest - структура для запроса на
// обновление карточки объявления
type UpdateCardRequest struct {
	CardID      uuid.UUID `json:"card-id"`
	Name        *string   `json:"name,omitempty"`
	Description *string   `json:"description,omitempty"`

	Price    *float64  `json:"price,omitempty"`
	Currency *string   `json:"currency,omitempty"`
	Type     *string   `json:"type,omitempty"`
	Tags     *[]string `json:"tags,omitempty"`
}
