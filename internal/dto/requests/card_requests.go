// requests - пакет, содержащий структуры запросов по Api
package requests

import "time"

// GetCardsRequest - структура для запроса на просмотр карточек
type GetCardsRequest struct {
	Key time.Time `json:"key" binding:"required"`
}

// CardInfoRequest - структура для запроса на просмотр конкретной карточки
type CardInfoRequest struct {
	CardID string `json:"card-id" binding:"required"`
}

type SaveCardRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description" binding:"required"`

	Price    float64  `json:"price" binding:"required"`
	Currency string   `json:"currency" binding:"required"`
	Type     string   `json:"type" binding:"required"`
	Tags     []string `json:"tags" binding:"required"`
}
