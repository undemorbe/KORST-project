// requests - пакет, содержащий структуры запросов по Api
package requests

// GetBannersRequest - структура для запроса на получение рекламных баннеров
type GetBannersRequest struct {
	Count *int `form:"count"`
}
