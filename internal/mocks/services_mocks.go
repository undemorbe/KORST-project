// mocks - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mocks

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"time"

	"github.com/google/uuid"
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

// MockAuthService - структура для передачи в тестах
// фиктивной структуры сервиса AuthService
type MockAuthService struct{ mock.Mock }

// CheckUser задает фиктивную реализацию проверки статуса пользователя
func (m *MockAuthService) CheckUser(rawPhone string) (responses.IsUserResponse, error) {
	args := m.Called(rawPhone)
	return args.Get(0).(responses.IsUserResponse), args.Error(1)
}

// GetNewTokens задает фиктивную реализацию генерации токенов
func (m *MockAuthService) GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error) {
	args := m.Called(refreshTokenStr)
	return args.Get(0).(responses.RefreshResponse), args.Error(1)
}

// RemoveRefreshToken задает фиктивную реализацию удаления access-токена
func (m *MockAuthService) RemoveRefreshToken(userID uuid.UUID) error {
	args := m.Called(userID)
	return args.Error(0)
}

// MockTokenService - структура для передачи в тестах
// фиктивной структуры сервиса TokenService
type MockTokenService struct{ mock.Mock }

// CreateTokens задает фиктивную реализацию создания refresh и access токенов
func (m *MockTokenService) CreateTokens(user *entities.User) (string, string, error) {
	args := m.Called(user)
	return args.String(0), args.String(1), args.Error(2)
}

// DecodeAccessToken задает фиктивную реализацию декодировки access-токена
func (m *MockTokenService) DecodeAccessToken(rawToken string) (uuid.UUID, error) {
	args := m.Called(rawToken)
	return args.Get(0).(uuid.UUID), args.Error(1)
}

// MockCardService - структура для передачи в тестах
// фиктивной структуры сервиса CardService
type MockCardService struct{ mock.Mock }

// SaveCard задает фиктивную реализацию сохранения карточки
func (m *MockCardService) SaveCard(userID uuid.UUID, req *requests.SaveCardRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// GetCards задает фиктивную реализацию получения страницы карточек
func (m *MockCardService) GetCards(key *time.Time) (responses.GetCardsResponse, error) {
	args := m.Called(key)
	return args.Get(0).(responses.GetCardsResponse), args.Error(1)
}

// GetCardInfo Задает фиктивную реализацию получения информации о карточке
func (m *MockCardService) GetCardInfo(cardID uuid.UUID) (responses.CardInfoResponse, error) {
	args := m.Called(cardID)
	return args.Get(0).(responses.CardInfoResponse), args.Error(1)
}

// MockCardService - структура для передачи в тестах
// фиктивной структуры сервиса UserService
type MockUserService struct{ mock.Mock }

// UpdateUserInfo задает фиктивную реализацию обновления данных пользователя
func (m *MockUserService) UpdateUserInfo(userID uuid.UUID, req *requests.UpdateUserRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// GetUserInfo задает фиктивную реализацию получения информации о пользователе
func (m *MockUserService) GetUserInfo(userID uuid.UUID) (responses.GetUserInfoResponse, error) {
	args := m.Called(userID)
	return args.Get(0).(responses.GetUserInfoResponse), args.Error(1)
}

// MockReviewService - структура для передачи в тестах
// фиктивной структуры сервиса ReviewService
type MockReviewService struct{ mock.Mock }

// GetReviews задает фиктивную реализацию получения отзывов
func (m *MockReviewService) GetReviews(userID uuid.UUID) (responses.GetReviewsResponse, error) {
	args := m.Called(userID)
	return args.Get(0).(responses.GetReviewsResponse), args.Error(1)
}

// PostReview задает фиктивную реализацию размещения отзыва
func (m *MockReviewService) PostReview(authorID uuid.UUID, req *requests.PostReviewRequest) error {
	args := m.Called(authorID, req)
	return args.Error(0)
}
