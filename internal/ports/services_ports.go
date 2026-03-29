// ports - пакет, содержащий все порты (интерфейсы)
package ports

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"time"

	"github.com/google/uuid"
)

// OTPService содержит порты для методов отправки и подтверждения OTP
type OTPService interface {
	// SendOTP отправляет Otp-код по номеру телефона и сохраняет его
	SendOTP(rawPhone string) error

	// VerifyOTP сравнивает полученный Otp-код c сохраненным в БД
	VerifyOTP(rawPhone string, otp string) (
		responses.VerifyOTPResponse,
		error)
}

// AuthService содержит порты для методов, необходимых для авторизации
type AuthService interface {
	// CheckUser находит пользователя по телефону и проверяет его
	// статус (notFound / notRegistered / registered)
	CheckUser(rawPhone string) (
		responses.IsUserResponse, error)

	// GetNewTokens получает новые access и refresh токены для пользователя
	GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error)

	// RemoveRefreshToken удаляет refresh-токен по ID пользователя
	RemoveRefreshToken(userID uuid.UUID) error
}

// TokenService содержит порты для методов создания/обновления токенов
type TokenService interface {
	// CreateTokens создает новый access-токен,
	// обновляет (или создает новый) refresh-токен.
	CreateTokens(user *entities.User) (string, string, error)

	// DecodeAccessToken декодирует полученный access-токен,
	// проверяет его валидность
	DecodeAccessToken(rawToken string) (uuid.UUID, error)
}

// CardService содержит порты для методов просмотра,
// создания и обновления карточек
type CardService interface {
	// SaveCard сохраняет каторчку объявления, созданную пользователем
	SaveCard(userID uuid.UUID, req *requests.SaveCardRequest) error

	// UpdateCard обновляет данные определенной карточки объявления
	UpdateCard(userID uuid.UUID, req *requests.UpdateCardRequest) error

	// GetCards возвращает несколько сжатых карточек
	// с объявлениями для просмотра пользователями
	GetCards(key *time.Time) (responses.GetCardsResponse, error)

	// GetCardInfo возвращает подробную информацию
	// об одной конкретной карточке объявления
	GetCardInfo(cardID uuid.UUID) (responses.CardInfoResponse, error)
}

// UserService содержит порты для методов, необходимых для
// работы с пользователем и его профилем
type UserService interface {
	// UpdateUserInfo обновляет (или дополняет) информацию
	// о каком-то конкретном пользователе
	UpdateUserInfo(userID uuid.UUID,
		req *requests.UpdateUserRequest) error

	// GetUserInfo получает подробную информацию
	// о каком-то конкретном пользователе
	GetUserInfo(userID uuid.UUID) (
		responses.GetUserInfoResponse, error)
}

// ReviewService содержит порты для методов для
// создания и просмотра отзывов на пользователе1
type ReviewService interface {
	// GetReviews получает все отзывы,
	// относящиеся к определенному пользователю
	GetReviews(userID uuid.UUID) (
		responses.GetReviewsResponse, error)

	// PostReview сохраняет отзыв на указанного пользователя
	PostReview(authorID uuid.UUID,
		req *requests.PostReviewRequest) error
}
