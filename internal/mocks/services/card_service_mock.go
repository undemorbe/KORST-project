// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"io"
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockCardService - структура для передачи в тестах
// фиктивной структуры сервиса CardService
type MockCardService struct{ mock.Mock }

// SaveCard задает фиктивную реализацию сохранения карточки
func (m *MockCardService) SaveCard(userID uuid.UUID, req *requests.SaveCardRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// UpdateCard задает фиктивную реализацию обновления карточки
func (m *MockCardService) UpdateCard(userID uuid.UUID, req *requests.UpdateCardRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// SaveImage задает фиктивную реализацию сохранения изображения в хранилище
func (m *MockCardService) SaveImage(cardID uuid.UUID, file io.Reader, fileName string) (string, error) {
	args := m.Called(cardID, file, fileName)
	return args.String(0), args.Error(1)
}

// GetCards задает фиктивную реализацию получения страницы карточек
func (m *MockCardService) GetCards(key *time.Time, query *string) (responses.GetCardsResponse, error) {
	args := m.Called(key, query)
	return args.Get(0).(responses.GetCardsResponse), args.Error(1)
}

// GetCardInfo Задает фиктивную реализацию получения информации о карточке
func (m *MockCardService) GetCardInfo(cardID uuid.UUID) (responses.CardInfoResponse, error) {
	args := m.Called(cardID)
	return args.Get(0).(responses.CardInfoResponse), args.Error(1)
}
