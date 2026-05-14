// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"encoding/json"
	"io"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/responses"
	"korst-backend/internal/messenger/entities"
	messengerPorts "korst-backend/internal/messenger/ports"
	ports "korst-backend/internal/ports"
	"os"
	"time"

	"github.com/google/uuid"
)

// MessageService - объект, сожержащий методы для
// работы с сообщениями в чате
type MessageService struct {
	userRepo    ports.UserRepository
	chatRepo    messengerPorts.ChatRepository
	messageRepo messengerPorts.MessageRepository
	fileService ports.FileService
	hub         messengerPorts.Hub
}

// NewMessageService создает и возращает новый объект MessageService
func NewMessageService(userRepo ports.UserRepository,
	chatRepo messengerPorts.ChatRepository,
	messageRepo messengerPorts.MessageRepository,
	fileService ports.FileService,
	hub messengerPorts.Hub) messengerPorts.MessageService {
	return &MessageService{
		userRepo:    userRepo,
		chatRepo:    chatRepo,
		messageRepo: messageRepo,
		fileService: fileService,
		hub:         hub,
	}
}

// SendMessage сохраняет сообщение в определенном чате
// и отправляет его к другому пользователю
func (s *MessageService) SendMessage(authorID uuid.UUID,
	chatID uuid.UUID, text string) error {

	response, err := s.saveMessage(authorID, chatID, text, nil)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении сообщения в чате: ", err)
		return err
	}

	err = s.sendByWebSocket(response)
	if err != nil {
		logger.Log.Warn("Ошибка при отправке сообщения через WebSocket: ", err)
		return nil
	}

	return nil
}

// SendImage сохраняет изображение для определенного
// чата и отправляет сообщение с ним другому пользователю
func (s *MessageService) SendImage(authorID uuid.UUID, chatID uuid.UUID,
	text string, file io.Reader, fileName string) error {

	messageID := uuid.New()

	url, err := s.fileService.SaveMessageImage(file, fileName, messageID)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении изображения в чате: ", err)
		return err
	}

	response, err := s.saveMessage(authorID, chatID, text, &url)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении сообщения в чате: ", err)
		return err
	}

	err = s.sendByWebSocket(response)
	if err != nil {
		logger.Log.Warn("Ошибка при отправке сообщения через WebSocket: ", err)
		return nil
	}

	return nil
}

// saveMessage сохраняет определенное сообщение указанном чате
func (s *MessageService) saveMessage(authorID uuid.UUID, chatID uuid.UUID,
	text string, imageURL *string) (responses.Message, error) {

	var response responses.Message

	author, err := s.userRepo.FindByID(authorID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return response, err
	}

	if author == nil {
		logger.Log.Warn("Указанный пользователь не найден")
		return response, errors.ErrorUserNotFound
	}

	chat, err := s.chatRepo.FindByID(chatID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске чата: ", err)
		return response, err
	}

	if chat == nil {
		logger.Log.Warn("Указанный чат не найден")
		return response, errors.ErrorUserNotFound
	}

	message := &entities.Message{
		ID:        uuid.New(),
		ChatID:    chatID,
		AuthorID:  authorID,
		Text:      text,
		CreatedAt: time.Now().UTC(),
	}

	var fullImageURL string

	baseURL := os.Getenv("BASE_URL")

	if imageURL != nil && len(*imageURL) > 0 {
		message.ImageURL = *imageURL
		fullImageURL = baseURL + *imageURL
	}

	err = s.messageRepo.CreateMessage(message)

	if err != nil {
		logger.Log.Error("Ошибка при сохранении сообщения: ", err)
		return response, err
	}

	response = responses.Message{
		ID:       message.ID,
		ChatID:   chatID,
		AuthorID: authorID,

		Text:      text,
		ImageURL:  fullImageURL,
		IsSeen:    false,
		CreatedAt: message.CreatedAt,
	}

	return response, nil
}

// sendByWebSocket отправляет сообщение собеседнику по WebSocket
func (s *MessageService) sendByWebSocket(message responses.Message) error {

	chat, err := s.chatRepo.FindByID(message.ChatID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске чата: ", err)
		return err
	}

	if chat == nil {
		logger.Log.Warn("Указанный чат не найден")
		return errors.ErrorChatNotFound
	}

	anotherUserID := chat.CustomerID

	if message.AuthorID == chat.CustomerID {
		anotherUserID = chat.MerchantID
	}

	data, err := json.Marshal(message)
	if err != nil {
		logger.Log.Error("Ошибка при кодировании сообщения в JSON: ", err)
		return err
	}

	s.hub.SendToUser(anotherUserID, data)

	return nil
}

// ChangeMessage изменяет текст определенного сообщения в чате
func (s *MessageService) ChangeMessage(authorID uuid.UUID,
	messageID uuid.UUID, text string) error {

	message, err := s.messageRepo.FindByID(messageID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске сообщения: ", err)
		return err
	}

	if message == nil {
		logger.Log.Warn("Указанное сообщение не найдено")
		return errors.ErrorMessageNotFound
	}

	if message.AuthorID != authorID {
		logger.Log.Warn("Попытка изменить чужое сообщение")
		return errors.ErrorForbidden
	}

	message.Text = text

	err = s.messageRepo.UpdateMessage(message)
	if err != nil {
		logger.Log.Error("Ошибка при попытке изменить сообщение: ", err)
		return err
	}

	return nil
}

// DeleteMessage удаляет определенное сообщение из чата
func (s *MessageService) DeleteMessage(authorID uuid.UUID,
	messageID uuid.UUID) error {

	message, err := s.messageRepo.FindByID(messageID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске сообщения: ", err)
		return err
	}

	if message == nil {
		logger.Log.Warn("Указанное сообщение не найдено")
		return errors.ErrorMessageNotFound
	}

	if message.AuthorID != authorID {
		logger.Log.Warn("Попытка удалить чужое сообщение")
		return errors.ErrorForbidden
	}

	err = s.messageRepo.DeleteMessage(message)
	if err != nil {
		logger.Log.Error("Ошибка при удалении сообщения: ", err)
		return err
	}

	return nil
}
