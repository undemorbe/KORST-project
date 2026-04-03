// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/responses"
	messengerEntities "korst-backend/internal/messenger/entities"
	messengerPorts "korst-backend/internal/messenger/ports"
	ports "korst-backend/internal/ports"
	"slices"

	"github.com/google/uuid"
)

// ChatService - объект, содержащий методы для работы
// с чатами и просмотра сообщений в них
type ChatService struct {
	userRepo ports.UserRepository
	cardRepo ports.CardRepository
	chatRepo messengerPorts.ChatRepository
}

// NewChatService создает и возвращает новый объект ChatService
func NewChatService(userRepo ports.UserRepository,
	cardRepo ports.CardRepository,
	chatRepo messengerPorts.ChatRepository) messengerPorts.ChatService {
	return &ChatService{
		userRepo: userRepo,
		cardRepo: cardRepo,
		chatRepo: chatRepo,
	}
}

// GetChats получает все чаты пользователя вместе с
// самыми последними сообщениями в них
func (s *ChatService) GetChats(userID uuid.UUID) (
	responses.GetChatsResponse, error) {

	response := responses.GetChatsResponse{
		CustomerChats: []responses.ChatInfo{},
		MerchantChats: []responses.ChatInfo{},
	}

	user, err := s.userRepo.FindWithChats(userID)
	if err != nil {
		logger.Log.Error("Ошибка при получении пользователя в БД: ", err)
		return responses.GetChatsResponse{}, err
	}

	if user == nil {
		logger.Log.Warn("Указанный пользователь не найден")
		return responses.GetChatsResponse{},
			errors.ErrorUserNotFound
	}

	customerChats := user.CustomerChats

	// Сортировка customerChats по времени обновления
	slices.SortFunc(customerChats,
		func(a, b messengerEntities.Chat) int {
			return b.UpdatedAt.Compare(a.UpdatedAt)
		})

	merchantChats := user.MerchantChats

	// Сортировка merchantChats по времени обновления
	slices.SortFunc(merchantChats,
		func(a, b messengerEntities.Chat) int {
			return b.UpdatedAt.Compare(a.UpdatedAt)
		})

	// Преобразование элементов customerChats к нужному формату
	for i := range customerChats {

		chat, err := s.convertChat(userID, &customerChats[i])

		if err != nil {
			logger.Log.Warn("Ошибка при обработке чата: ", err)
			continue
		}

		response.CustomerChats = append(response.CustomerChats, chat)
	}

	// Преобразование элементов merchantChats к нужному формату
	for i := range merchantChats {

		chat, err := s.convertChat(userID, &merchantChats[i])

		if err != nil {
			logger.Log.Warn("Ошибка при обработке чата: ", err)
			continue
		}

		response.MerchantChats = append(response.MerchantChats, chat)
	}

	return response, nil
}

// GetMessages получает все сообщения в определенном чате
func (s *ChatService) GetMessages(chatID uuid.UUID) (
	responses.GetMessagesReponse, error) {

	response := responses.GetMessagesReponse{
		Messages: []responses.Message{},
	}

	chat, err := s.chatRepo.FindByID(chatID)
	if err != nil {
		logger.Log.Error("Ошибка при получении чата в БД: ", err)
		return responses.GetMessagesReponse{}, err
	}

	if chat == nil {
		logger.Log.Warn("Указанный чат не найден")
		return responses.GetMessagesReponse{},
			errors.ErrorChatNotFound
	}

	messages := chat.Messages

	slices.SortFunc(messages,
		func(a, b messengerEntities.Message) int {
			return b.CreatedAt.Compare(a.CreatedAt)
		})

	for i := range messages {
		message := s.convertMessage(&messages[i])
		response.Messages = append(response.Messages, message)
	}

	return response, nil
}

// convertChat преобразовывает сущность чата
// к формату, нужному для response
func (s *ChatService) convertChat(userID uuid.UUID,
	chat *messengerEntities.Chat) (responses.ChatInfo, error) {

	convertedChat := responses.ChatInfo{
		ID: chat.ID,
	}

	// Получениу ID другого пользователя
	anotherUserID := chat.MerchantID
	if anotherUserID == userID {
		anotherUserID = chat.CustomerID
	}

	anotherUser, err := s.userRepo.FindByID(anotherUserID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя в БД: ", err)
		return responses.ChatInfo{}, err
	}

	if anotherUser == nil {
		logger.Log.Warn("Указанный пользователь не найден")
		return responses.ChatInfo{}, errors.ErrorUserNotFound
	}

	userInfo := responses.UserInfo{
		ID:      anotherUser.ID,
		Name:    anotherUser.Name,
		Surname: anotherUser.Surname,
	}

	convertedChat.User = userInfo

	card, err := s.cardRepo.FindByID(chat.CardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске карточки в БД: ", err)
		return responses.ChatInfo{}, err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return responses.ChatInfo{}, errors.ErrorCardNotFound
	}

	cardInfo := responses.CardInfo{
		ID:   card.ID,
		Name: card.Name,
	}

	convertedChat.Card = cardInfo

	messages := chat.Messages

	slices.SortFunc(messages,
		func(a, b messengerEntities.Message) int {
			return b.CreatedAt.Compare(a.CreatedAt)
		})

	lastMessage := s.convertMessage(&messages[0])

	convertedChat.LastMessage = lastMessage

	return convertedChat, nil
}

// convertMessage преобразовывает сущность
// сообщения к формату, нужному для response
func (s *ChatService) convertMessage(
	message *messengerEntities.Message) responses.Message {

	convertedMessage := responses.Message{
		ID:        message.ID,
		AuthorID:  message.AuthorID,
		Text:      message.Text,
		CreatedAt: message.CreatedAt,
	}

	return convertedMessage
}
