// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// CardHandler - объект, содержащий методы для обработки
// Api запросов, связанных с карточками объявлений
type CardHandler struct {
	cardService  ports.CardService
	tokenService ports.TokenService
}

// NewCardHandler создает и возвращает новый объект CardHandler
func NewCardHandler(cardService ports.CardService,
	tokenService ports.TokenService) *CardHandler {
	return &CardHandler{
		cardService:  cardService,
		tokenService: tokenService,
	}
}

// SaveCard обрабатывает запрос на сохрание карточки объявления
func (h *CardHandler) SaveCard(c *gin.Context) {
	var req requests.SaveCardRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.cardService.SaveCard(userID, &req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Создание новой карточки прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// UpdateCard обрабатывает запрос на изменение
// данных карточки объявления
func (h *CardHandler) UpdateCard(c *gin.Context) {
	var req requests.UpdateCardRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.cardService.UpdateCard(userID, &req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Обновление карточки прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// SaveImage обрабатывает запрос на сохранение
// изображения для карточки объявления
func (h *CardHandler) SaveImage(c *gin.Context) {

	rawCardID := c.PostForm("card-id")

	cardID, err := uuid.Parse(rawCardID)
	if err != nil {
		logger.Log.Warn("Ошибка при парсинге uuid: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	fileHeader, err := c.FormFile("image")
	if err != nil {
		logger.Log.Warn("Ошибка при получении файла: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	file, err := fileHeader.Open()
	if err != nil {
		logger.Log.Warn("Ошибка при открытии полученного файла: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}
	defer file.Close()

	url, err := h.cardService.SaveImage(cardID, file, fileHeader.Filename)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Сохранение изображения карточки успешно выполнено")
	c.JSON(http.StatusOK, responses.SaveImageResponse{ImageURL: url})
}

// GetCards обрабатывает запрос на получение
// карточек для отображения пользователям
func (h *CardHandler) GetCards(c *gin.Context) {
	var req requests.GetCardsRequest
	var key *time.Time = nil

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	if req.Key != nil {

		rawTime := strings.Trim(*req.Key, `"`)

		parsedTime, err := time.Parse(time.RFC3339Nano, rawTime)
		if err != nil {
			logger.Log.Warn("Ошибка при парсинге времени в key: ", err)
			c.Error(errors.ErrorInvalidInput)
			return
		}

		key = &parsedTime
	}

	response, err := h.cardService.GetCards(key, nil)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение карточек прошло успешно")
	c.JSON(http.StatusOK, response)
}

// GetWithQuery обрабатывает запрос на получение
// карточек по времени и запросу в поиске
func (h *CardHandler) GetWithQuery(c *gin.Context) {
	var req requests.GetWithQueryRequest
	var key *time.Time = nil

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	if req.Key != nil {

		rawTime := strings.Trim(*req.Key, `"`)

		parsedTime, err := time.Parse(time.RFC3339Nano, rawTime)
		if err != nil {
			logger.Log.Warn("Ошибка при парсинге времени в key: ", err)
			c.Error(errors.ErrorInvalidInput)
			return
		}

		key = &parsedTime
	}

	response, err := h.cardService.GetCards(key, req.Query)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение карточек по запросу поиска прошло успешно")
	c.JSON(http.StatusOK, response)
}

// GetCardInfo обрабатывает запрос на получение подробной
// информации об определенной карточке
func (h *CardHandler) GetCardInfo(c *gin.Context) {
	var req requests.CardInfoRequest

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	cardID, err := uuid.Parse(req.CardID)
	if err != nil {
		logger.Log.Warn("Ошибка при парсинге uuid: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.cardService.GetCardInfo(cardID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Успешно получена информация о карточке")
	c.JSON(http.StatusOK, response)
}
