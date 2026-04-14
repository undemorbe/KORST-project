// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockCardRepo - структура для передачи в тестах
// фиктивной структуры репозитория cardRepo
type MockCardRepo struct{ mock.Mock }

// FindByID задает фиктивную реализацию поиска карточки по ID
func (m *MockCardRepo) FindByID(cardID uuid.UUID) (*entities.Card, error) {
	args := m.Called(cardID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Card), args.Error(1)
}

// FindСardsByTime задает фиктивную реализацию пагинации по времени
func (m *MockCardRepo) FindCardsByTime(key *time.Time, limit int) ([]entities.Card, error) {
	args := m.Called(key, limit)
	return args.Get(0).([]entities.Card), args.Error(1)
}

// FindCardsByQuery задает фиктивную реализацию нахождения карточек по поиску
func (m *MockCardRepo) FindCardsByQuery(key *time.Time, query string, limit int) ([]entities.Card, error) {
	args := m.Called(key, query, limit)
	return args.Get(0).([]entities.Card), args.Error(1)
}

// CreateCard задает фиктивную реализацию создания сущности карточки
func (m *MockCardRepo) CreateCard(card *entities.Card) error {
	args := m.Called(card)
	return args.Error(0)
}

// UpdateCard задает фиктивную реализацию обновления карточки в БД
func (m *MockCardRepo) UpdateCard(card *entities.Card) error {
	args := m.Called(card)
	return args.Error(0)
}
