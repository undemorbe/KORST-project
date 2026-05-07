// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"io"
	"korst-backend/internal/dto/responses"

	"github.com/stretchr/testify/mock"
)

// MockBannerService - структура для передачи в тестах
// фиктивной структуры сервиса bannerService
type MockBannerService struct{ mock.Mock }

// SaveBanner задает фиктивную реализацию сохранения баннера
func (m *MockBannerService) SaveBanner(company string, link string, file io.Reader, fileName string) error {
	args := m.Called(company, link, file, fileName)
	return args.Error(0)
}

// GetBanners задает фиктивную реализацию получения нескольких баннеров
func (m *MockBannerService) GetBanners(count *int) (responses.GetBannersResponse, error) {
	args := m.Called(count)
	return args.Get(0).(responses.GetBannersResponse), args.Error(1)
}
