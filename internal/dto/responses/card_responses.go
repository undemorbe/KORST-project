// responses - пакет, содержащий структуры ответов на Api запросы
package responses

import (
	"time"

	"gorm.io/datatypes"
)

// GetCardsResponse - структура для ответа на запрос
// просмотра карточек объявлений
type GetCardsResponse struct {
	Cards []CompressedCard `json:"cards"`
}

// CompressedCard - структура с краткой информацией о карточке
type CompressedCard struct {
	ID   string `json:"id"`
	Name string `json:"name"`

	Price    float64 `json:"price"`
	Currency string  `json:"currency"`
	Type     string  `json:"type"`

	Author *CompressedAuthor `json:"author"`

	Tags []string `json:"tags"`

	CreatedAt time.Time `json:"created"`
}

// CompressedAuthor - структура с краткой информацией об авторе карточки
type CompressedAuthor struct {
	Name    string `json:"name"`
	Surname string `json:"surname"`

	Rating float64 `json:"rating"`
}

// CardInfoResponse - структура для ответа на запрос
// просмотра подробной информации о карточке
type CardInfoResponse struct {
	Name        string `json:"name"`
	Description string `json:"description"`

	Price    float64 `json:"price"`
	Currency string  `json:"currency"`
	Type     string  `json:"type"`

	Author *Author `json:"author"`

	Tags []string `json:"tags"`

	CreatedAt string `json:"created"`
	UpdatedAt string `json:"updated"`
}

// Author - структура с полной информацией об авторе карточки
type Author struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Surname string `json:"surname"`

	Phone    string    `json:"phone"`
	Contacts *Contacts `json:"contacts"`

	Rating float64 `json:"rating"`
}

// Contacts - структура с контактами автора карточки
type Contacts struct {
	Email    string `json:"email"`
	Telegram string `json:"telegram"`

	Others datatypes.JSONMap `json:"others"`
}
