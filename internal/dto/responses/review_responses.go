// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// GetReviewsResponse - структура для ответа
// на запрос для получения отзывов о пользователе
type GetReviewsResponse struct {
	Reviews []Review `json:"reviews"`
}

// Review - структура, содержащая информацию о отзыве на пользователя
type Review struct {
	Rating  float64 `json:"rating"`
	Comment string  `json:"comment"`

	Author CompressedAuthor `json:"author"`
}
