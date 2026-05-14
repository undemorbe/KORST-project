// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/stretchr/testify/mock"
)

// MockBannerRepo - структура для передачи в тестах
// фиктивной структуры репозитория bannerRepo
type MockBannerRepo struct{ mock.Mock }

// FindBanners задает фиктивную реализацию получения нескольких баннеров из БД
func (m *MockBannerRepo) FindBanners(count int) ([]entities.Banner, error) {
	args := m.Called(count)
	return args.Get(0).([]entities.Banner), args.Error(1)
}

// CreateBanner задает фиктивную реализацию создания баннера в БД
func (m *MockBannerRepo) CreateBanner(banner *entities.Banner) error {
	args := m.Called(banner)
	return args.Error(0)
}
