// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/entities"
	messengerPorts "korst-backend/internal/messenger/ports"
	ports "korst-backend/internal/ports"

	"github.com/google/uuid"
)

// MessageService - объект, сожержащий методы для
// работы с сообщениями в чате
type MessageService struct {
	userRepo    ports.UserRepository
	chatRepo    messengerPorts.ChatRepository
	messageRepo messengerPorts.MessageRepository
}

// NewMessageService создает и возращает новый объект MessageService
func NewMessageService(userRepo ports.UserRepository,
	chatRepo messengerPorts.ChatRepository,
	messageRepo messengerPorts.MessageRepository) messengerPorts.MessageService {
	return &MessageService{
		userRepo:    userRepo,
		chatRepo:    chatRepo,
		messageRepo: messageRepo,
	}
}

// SendMessage сохраняет сообщение в определенном чате
// и отправляет его к другому пользователю
func (s *MessageService) SendMessage(authorID uuid.UUID,
	chatID uuid.UUID, text string) error {

	author, err := s.userRepo.FindByID(authorID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return err
	}

	if author == nil {
		logger.Log.Warn("Указанный пользователь не найден")
		return errors.ErrorUserNotFound
	}

	chat, err := s.chatRepo.FindByID(chatID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске чата: ", err)
		return err
	}

	if chat == nil {
		logger.Log.Warn("Указанный чат не найден")
		return errors.ErrorUserNotFound
	}

	message := &entities.Message{
		ChatID:   chatID,
		AuthorID: authorID,
		Text:     text,
	}

	err = s.messageRepo.CreateMessage(message)

	if err != nil {
		logger.Log.Error("Ошибка при сохранении сообщения")
		return err
	}

	// TODO: добавить отправку сообщения по web-socket

	return nil
}
