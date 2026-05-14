// handlers - пакет, содержащий хэндлеры для обработки
// запросов, связанных с мессенджером
package handlers

import (
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/requests"
	"korst-backend/internal/messenger/dto/responses"
	messengerPorts "korst-backend/internal/messenger/ports"
	"korst-backend/internal/ports"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// MessageHandler - объект, содержащий методы для обработки
// Api запросов, связанных с сообщениями в чатах
type MessageHandler struct {
	messageService messengerPorts.MessageService
	tokenService   ports.TokenService
}

// NewMessageHandler создает и возвращает новый объект MessageHandler
func NewMessageHandler(
	messageService messengerPorts.MessageService,
	tokenService ports.TokenService) *MessageHandler {
	return &MessageHandler{
		messageService: messageService,
		tokenService:   tokenService,
	}
}

// SendMessage обрабатывает запрос на отправку
// сообщения в определенном чате
func (h *MessageHandler) SendMessage(c *gin.Context) {
	var req requests.SendMessageRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	accessToken := c.GetHeader("Authorization")

	authorID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.messageService.SendMessage(authorID, req.ChatID, req.Text)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Отправка сообщения успешно выполнена")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// SendImage обрабатывает запрос на отправку
// сообщения c изображением в определенном чате
func (h *MessageHandler) SendImage(c *gin.Context) {

	rawChatID := c.PostForm("chat-id")
	text := c.PostForm("text")

	chatID, err := uuid.Parse(rawChatID)
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

	accessToken := c.GetHeader("Authorization")

	authorID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.messageService.SendImage(authorID, chatID, text, file, fileHeader.Filename)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Отправка сообщения с изображением успешно выполнена")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// ChangeMessage обрабатывает запрос на
// изменение определенного сообщения в чате
func (h *MessageHandler) ChangeMessage(c *gin.Context) {
	var req requests.ChangeMessageRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(err)
		return
	}

	accessToken := c.GetHeader("Authorization")

	authorID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.messageService.ChangeMessage(authorID, req.MessageID, req.Text)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Изменение сообщения успешно выполнено")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// DeleteMessage обрабатывает запрос на
// удаление определенного сообщения в чате
func (h *MessageHandler) DeleteMessage(c *gin.Context) {
	var req requests.DeleteMessageRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
	}

	accessToken := c.GetHeader("Authorization")

	authorID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.messageService.DeleteMessage(authorID, req.MessageID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Удаление сообщения успешно выполнено")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
