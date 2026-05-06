// responses - пакет, содержащий структуры ответов на Api запросы
package responses

import (
	"time"
)

// GetMyInfoResponse - структура для ответа на запрос для
// получения расширенной информации о текщем пользователе
type GetMyInfoResponse struct {
	GetUserInfoResponse

	RepliesInfo RepliesInfo `json:"replies-info"`
}

// GetUserInfoResponse - структура для ответа
// на запрос для получения информации о пользователе
type GetUserInfoResponse struct {
	Name     string `json:"name"`
	Surname  string `json:"surname"`
	ImageURL string `json:"image-url,omitempty"`

	Phone       string  `json:"phone"`
	Description string  `json:"description"`
	Rating      float64 `json:"rating"`

	Contacts *Contacts `json:"contacts"`

	UpdatedAt time.Time `json:"updated"`
	CreatedAt time.Time `json:"created"`

	Cards []CompressedCard `json:"cards"`
}

// RepliesInfo содержит статистику об откликах
// текущего пользователя на объявления
type RepliesInfo struct {
	Total     int `json:"total"`
	Accepted  int `json:"accepted"`
	Completed int `json:"completed"`
	Failed    int `json:"failed"`
}
