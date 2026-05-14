// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// GetBannersResponse - структура для ответа на запрос
// для получения рекламных баннеров
type GetBannersResponse struct {
	Banners []BannerInfo `json:"banners"`
}

// BannerInfo - структура, содержащая информацию об определенном баннере
type BannerInfo struct {
	Company  string `json:"company"`
	ImageURL string `json:"image-url"`
	Link     string `json:"link"`
}
