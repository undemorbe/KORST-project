// responses - пакет, содержащий структуры ответов на Api запросы
package responses

import (
	"time"
)

type GetUserInfoResponse struct {
	Name    string `json:"name"`
	Surname string `json:"surname"`

	Phone       string  `json:"phone"`
	Description string  `json:"description"`
	Rating      float64 `json:"rating"`

	Contacts *Contacts `json:"contacts"`

	UpdatedAt time.Time `json:"updated"`
	CreatedAt time.Time `json:"created"`

	Cards []CompressedCard `json:"cards"`
}

type GetReviewsResponse struct {
	Reviews []Review `json:"reviews"`
}

type Review struct {
	Rating  float64 `json:"rating"`
	Comment string  `json:"comment"`

	Author CompressedAuthor `json:"author"`
}
