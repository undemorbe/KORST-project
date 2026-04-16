// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"io"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockCardService - структура для передачи в тестах
// фиктивной структуры сервиса FileService
type MockFileService struct{ mock.Mock }

// SaveProfileImage задает фиктивную реализацию сохранения изображения профиля
func (m *MockFileService) SaveProfileImage(file io.Reader, fileName string, userID uuid.UUID) (string, error) {
	args := m.Called(file, fileName, userID)
	return args.String(0), args.Error(1)
}

// SaveCardImage задает фиктивную реализацию сохранения изображения карточки
func (m *MockFileService) SaveCardImage(file io.Reader, fileName string, cardID uuid.UUID) (string, error) {
	args := m.Called(file, fileName, cardID)
	return args.String(0), args.Error(1)
}

// SaveMessageImage задает фиктивную реализацию сохранения изображения в чате
func (m *MockFileService) SaveMessageImage(file io.Reader, fileName string, messageID uuid.UUID) (string, error) {
	args := m.Called(file, fileName, messageID)
	return args.String(0), args.Error(1)
}
