// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// GetExecutorsResponse - структура для ответа на запрос
// получения всех исполнителей объявления
type GetExecutorsResponse struct {
	Executors []CompressedAuthor `json:"executors"`
}
