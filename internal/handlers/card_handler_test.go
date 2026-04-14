// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"

	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestSaveCard тестирует обработку запроса на
// сохранение карточки объявления
func TestSaveCard(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockCardService := &mockServices.MockCardService{}
	mockTokenService := &mockServices.MockTokenService{}

	cardHandler := NewCardHandler(mockCardService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/save-card", cardHandler.SaveCard)

	accessToken := "access-token"
	userID := uuid.New()

	body := `{
		"name": "name",
		"description": null,
		"price": 100,
		"currency": "USD",
		"type": "услуга",
		"tags": ["tag1", "tag2", "tag3"]
	}`

	requiredReq := &requests.SaveCardRequest{
		Name:        "name",
		Description: nil,
		Price:       100,
		Currency:    "USD",
		Type:        "услуга",
		Tags:        []string{"tag1", "tag2", "tag3"},
	}

	mockTokenService.On("DecodeAccessToken", accessToken).Return(userID, nil)

	mockCardService.
		On("SaveCard", userID, requiredReq).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/save-card",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockTokenService.AssertExpectations(t)
	mockCardService.AssertExpectations(t)
}

// TestGetCards тестирует обработку запроса на
// получение карточек объявлений (с пагинацией)
func TestGetCards(t *testing.T) {

	mockCardService := &mockServices.MockCardService{}
	mockTokenService := &mockServices.MockTokenService{}

	cardHandler := NewCardHandler(mockCardService, mockTokenService)

	var query *string = nil

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/get-cards", cardHandler.GetCards)

	mockCardService.
		On("GetCards", mock.AnythingOfType("*time.Time"), query).
		Return(responses.GetCardsResponse{}, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		"/get-cards?key=2026-03-19T20:15:34.123Z",
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockCardService.AssertExpectations(t)
}

// TestGetCardInfo тестирует обработку запроса на
// получение информации об определенной карточке
func TestGetCardInfo(t *testing.T) {

	mockCardService := &mockServices.MockCardService{}
	mockTokenService := &mockServices.MockTokenService{}

	cardHandler := NewCardHandler(mockCardService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/card-info", cardHandler.GetCardInfo)

	cardID, _ := uuid.Parse("a807daa3-c98a-4da2-bd03-a88ed68cdd48")

	name := "Олег"
	phone := "+79123456789"
	telegram := "@oleg"

	responseFromFunc := responses.CardInfoResponse{
		Name: name,
		Author: &responses.Author{
			Phone: phone,
			Contacts: &responses.Contacts{
				Telegram: telegram,
			},
		},
	}

	mockCardService.On("GetCardInfo", cardID).Return(responseFromFunc, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		"/card-info?card-id=a807daa3-c98a-4da2-bd03-a88ed68cdd48",
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.CardInfoResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, name, response.Name)
	require.Equal(t, phone, response.Author.Phone)
	require.Equal(t, telegram, response.Author.Contacts.Telegram)
	mockCardService.AssertExpectations(t)
}
