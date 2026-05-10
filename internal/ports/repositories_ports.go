// ports - пакет, содержащий все порты (интерфейсы)
package ports

import (
	"korst-backend/internal/entities"
	"time"

	"github.com/google/uuid"
)

// UserRepository содержит порты для взаимодействия с User в БД
type UserRepository interface {
	// FindByID находит пользователя по его ID
	FindByID(userID uuid.UUID) (*entities.User, error)

	// FindWithCards находит пользователя по его ID вместе с АКТИВНЫМИ карточками
	FindWithCards(userID uuid.UUID) (*entities.User, error)

	// FindWithReplies находит текущего пользователя по его ID со всеми его карточками и откликами
	FindWithReplies(userID uuid.UUID) (*entities.User, error)

	// FindWithReviews находит пользователя по его ID вместе с отзывами на него
	FindWithRelatedReviews(userID uuid.UUID) (*entities.User, error)

	// FindWithChats находит пользователя по его ID вместе с его чатами
	FindWithChats(userID uuid.UUID) (*entities.User, error)

	// FindByPhone находит пользователя по номеру телефона
	FindByPhone(phone string) (*entities.User, error)

	// CreateUser создает новый объект пользователя в БД
	CreateUser(user *entities.User) error

	// UpdateUser изменяет данные определенного пользователя
	UpdateUser(user *entities.User) error
}

// OTPRepository содержит порты для взаимодействия с Otp в БД
type OTPRepository interface {
	// FindByPhone находит Otp по номеру телефона
	FindByPhone(phone string) (*entities.Otp, error)

	// CreateOTP создает новый объект Otp в БД
	CreateOTP(otp *entities.Otp) error

	// UpdateOTP изменяет данные для сущности OTP
	UpdateOTP(otp *entities.Otp) error
}

// RefreshTokenRepository содержит порты для взаимодействия с
// refresh-токенами в БД
type RefreshTokenRepository interface {
	// FindByToken находит сущность refresh-токена по его значению
	FindByToken(token string) (*entities.RefreshToken, error)

	// CreateRefreshToken создает новый объект токена в БД
	CreateRefreshToken(refreshToken *entities.RefreshToken) error

	// UpdateRefreshToken изменяет данные определенного refresh-токена
	UpdateRefreshToken(refreshToken *entities.RefreshToken) error

	// DeleteByUserID удаляет все refresh-токены c определенным userID
	DeleteByUserID(userID uuid.UUID) error
}

// CardRepository содержит порты для взаимодействия с
// карточками объявлений с услугами/товарами в БД
type CardRepository interface {
	// FindByID находит карточку по ее ID
	FindByID(cardID uuid.UUID) (*entities.Card, error)

	// FindWithReplies находит карточку по ее ID вместе с откликами на нее
	FindWithReplies(cardID uuid.UUID) (*entities.Card, error)

	// FindСardsByTime находит заданное количество карточек,
	// которые больше ключа и отсортированны по времени.
	FindCardsByTime(key *time.Time, limit int) ([]entities.Card, error)

	// FindCardsByQuery находит заданное количество карточек
	// по запросу поиска пользователя (query)
	FindCardsByQuery(key *time.Time, query string,
		limit int) ([]entities.Card, error)

	// CreateCard создает новый объект карточки объявления в БД
	CreateCard(card *entities.Card) error

	// UpdateCard изменяет данные карточки в БД
	UpdateCard(card *entities.Card) error
}

// ProfileRepository содержит порты для взаимодействия с
// профилем пользователя в БД
type ProfileRepository interface {
	// CreateProfile создает новый объект профиля в БД
	CreateProfile(profile *entities.Profile) error

	// UpdateProfile обновляет данные профиля пользователя в БД
	UpdateProfile(profile *entities.Profile) error
}

// ReviewRepository содержит порты для взаимодействия с
// отзывами на пользователя в БД
type ReviewRepository interface {
	// FindReviewToUser находит отзыв, созданный пользователем с authorID
	// и относящийся к пользователю с relatedToID
	FindReviewToUser(authorID uuid.UUID,
		relatedToID uuid.UUID) (*entities.Review, error)

	// CreateReview создает новый объект отзыва на пользователя в БД
	CreateReview(review *entities.Review) error

	// UpdateReview изменяет содержимое отзыва на пользователя в БД
	UpdateReview(review *entities.Review) error
}

// ReplyRepository содержит порты для взаимодействия с
// откликами на объявление в БД
type ReplyRepository interface {
	// FindByAuthorAndCard находит отклик на объявление по
	// его автору и карточке, на которую был оставлен отклик
	FindByAuthorAndCard(authorID uuid.UUID,
		cardID uuid.UUID) (*entities.Reply, error)

	// Createreply создает новый объект отклика в БД
	CreateReply(reply *entities.Reply) error

	// UpdateReply изменяет статус отклика на объявление в БД
	UpdateReply(reply *entities.Reply) error
}

// BannerRepository содержит порты для взаимодействия
// с рекламными баннерами в БД
type BannerRepository interface {
	// FindBanners находит count случайных баннеров из всех записей в БД
	FindBanners(count int) ([]entities.Banner, error)

	// CreateBanner создает новый объект рекламного баннера в БД
	CreateBanner(banner *entities.Banner) error
}
