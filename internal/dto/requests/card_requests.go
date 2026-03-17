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
