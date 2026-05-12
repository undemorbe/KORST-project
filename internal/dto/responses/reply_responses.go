// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// GetExecutorsResponse - структура для ответа на запрос
// получения всех исполнителей объявления
type GetExecutorsResponse struct {
	Executors []Executor `json:"executors"`
}

// Executor - структура, содержащая
// информацию об исполнителе карточки
type Executor struct {
	CompressedAuthor
	ReplyStatus string `json:"reply-status"`
}
