// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/mocks"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestSaveCard проверяет сохранение карточки
func TestSaveCard(t *testing.T) {
	logger.InitLoggerTest()

	mockCardRepo := &mocks.MockCardRepo{}
	mockUserRepo := &mocks.MockUserRepo{}

	cardService := NewCardService(mockCardRepo, mockUserRepo)

	userID := uuid.New()
	name := "Название"
	price := 100.0
	currency := "Валюта"
	cardType := "Тип"
	tags := []string{}

	req := &requests.SaveCardRequest{
		Name:     name,
		Price:    price,
		Currency: currency,
		Type:     cardType,
		Tags:     tags,
	}

	card := &entities.Card{
		UserID:   userID,
		Name:     name,
		Price:    price,
		Currency: currency,
		Type:     cardType,
		Tags:     pq.StringArray(tags),
	}

	mockCardRepo.On("CreateCard", card).Return(nil)

	err := cardService.SaveCard(userID, req)

	require.NoError(t, err)
}

// TestGetCards проверяет получение нескольких карточек
func TestGetCards(t *testing.T) {
	os.Setenv("CARD_LIMIT", "12")

	mockCardRepo := &mocks.MockCardRepo{}
	mockUserRepo := &mocks.MockUserRepo{}

	cardService := NewCardService(mockCardRepo, mockUserRepo)

	userID := uuid.New()
	userName := "Олег"
	key := time.Now().UTC().Add(-5 * time.Minute)

	proflie := &entities.Profile{
		UserID: userID,
	}

	user := &entities.User{
		ID:      userID,
		Name:    userName,
		Profile: proflie,
	}

	cardName1 := "Карточка 1"
	cardName2 := "Карточка 2"

	card1 := entities.Card{
		ID:        uuid.New(),
		UserID:    userID,
		Name:      cardName1,
		Price:     50,
		Currency:  "USD",
		Type:      "услуга",
		Tags:      []string{},
		CreatedAt: time.Now().UTC().Add(-1 * time.Minute),
		UpdatedAt: time.Now().UTC().Add(-1 * time.Minute),
	}

	card2 := entities.Card{
		ID:        uuid.New(),
		UserID:    userID,
		Name:      cardName2,
		Price:     50,
		Currency:  "USD",
		Type:      "услуга",
		Tags:      []string{},
		CreatedAt: time.Now().UTC().Add(-2 * time.Minute),
		UpdatedAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	cards := []entities.Card{card1, card2}

	mockCardRepo.
		On("FindCardsByTime", mock.AnythingOfType("*time.Time"), 12).
		Return(cards, nil)

	mockUserRepo.
		On("FindByID", userID).
		Return(user, nil)

	response, err := cardService.GetCards(&key)

	require.NoError(t, err)
	require.Equal(t, cardName1, response.Cards[0].Name)
	require.Equal(t, cardName2, response.Cards[1].Name)

	require.Equal(t, userName, response.Cards[0].Author.Name)
	require.Equal(t, userName, response.Cards[1].Author.Name)
}

// TestGetCardInfo проверяет получение конкретной карточки
func TestGetCardInfo(t *testing.T) {

	mockCardRepo := &mocks.MockCardRepo{}
	mockUserRepo := &mocks.MockUserRepo{}

	cardService := NewCardService(mockCardRepo, mockUserRepo)

	userID := uuid.New()
	userName := "Олег"
	telegram := "telegram"
	cardID := uuid.New()
	cardName := "Карточка 1"

	proflie := &entities.Profile{
		UserID:   userID,
		Telegram: telegram,
	}

	user := &entities.User{
		ID:      userID,
		Name:    userName,
		Profile: proflie,
	}

	card := &entities.Card{
		ID:        uuid.New(),
		UserID:    userID,
		Name:      cardName,
		Price:     50,
		Currency:  "USD",
		Type:      "услуга",
		Tags:      []string{},
		CreatedAt: time.Now().UTC().Add(-2 * time.Minute),
		UpdatedAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	mockUserRepo.On("FindByID", userID).Return(user, nil)

	response, err := cardService.GetCardInfo(cardID)

	require.NoError(t, err)

	require.Equal(t, cardName, response.Name)
	require.Equal(t, userName, response.Author.Name)
	require.Equal(t, telegram, response.Author.Contacts.Telegram)
}
