// responses - пакет, содержащий структуры ответов на Api запросы
package responses

import (
	"time"
)

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
