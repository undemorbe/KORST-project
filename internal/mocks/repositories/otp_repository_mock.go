// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/stretchr/testify/mock"
)

// MockOtpRepo - структура для передачи в тестах
// фиктивной структуры репозитория OtpRepo
type MockOtpRepo struct{ mock.Mock }

// FindByPhone задает фиктивную реализацию поиска по телефону
func (m *MockOtpRepo) FindByPhone(phone string) (*entities.Otp, error) {
	args := m.Called(phone)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Otp), args.Error(1)
}

// CreateOTP задает фиктивную реализацию созданию Otp
func (m *MockOtpRepo) CreateOTP(otp *entities.Otp) error {
	args := m.Called(otp)
	return args.Error(0)
}

// UpdateOTP задает фиктивную реализацию обновления Otp
func (m *MockOtpRepo) UpdateOTP(otp *entities.Otp) error {
	args := m.Called(otp)
	return args.Error(0)
}
