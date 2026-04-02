// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/dto/responses"

	"github.com/stretchr/testify/mock"
)

// MockOTPService - структура для передачи в тестах
// фиктивной структуры сервиса OTPService
type MockOTPService struct{ mock.Mock }

// SendOTP задает фиктивную реализацию отправки otp
func (m *MockOTPService) SendOTP(rawPhone string) error {
	args := m.Called(rawPhone)
	return args.Error(0)
}

// VerifyOTP задает фиктивную реализацию подтверждения otp
func (m *MockOTPService) VerifyOTP(rawPhone string, otp string) (
	responses.VerifyOTPResponse, error) {
	args := m.Called(rawPhone, otp)
	return args.Get(0).(responses.VerifyOTPResponse), args.Error(1)
}
