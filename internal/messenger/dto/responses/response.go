// responses - пакет, содержащий модели ответов для
// api запросов, связанных с мессенджером
package responses

import (
	"time"

	"github.com/google/uuid"
)

// GetChatsResponse - структура для ответа на запрос
// получения всех чатов пользователя
type GetChatsResponse struct {
	CustomerChats []ChatInfo `json:"customer-chats"`
	MerchantChats []ChatInfo `json:"merchant-chats"`
}

// GetMessagesReponse - структура для ответа на запрос
// получения всех сообщений в определенном чате
type GetMessagesReponse struct {
	Messages []Message `json:"messages"`
}

// ChatInfo - структура информации о чате для ответов
// на запросы получения чатов пользователя
type ChatInfo struct {
	ID          uuid.UUID `json:"id"`
	User        UserInfo  `json:"user"`
	LastMessage Message   `json:"last-message"`
	Card        CardInfo  `json:"card"`
}

// Message - структура сообщения для ответов на запросы
// получения чатов и сообщений в них
type Message struct {
	ID        uuid.UUID `json:"id"`
	AuthorID  uuid.UUID `json:"author-id"`
	Text      string    `json:"text"`
	CreatedAt time.Time `json:"created"`
}

// UserInfo - структура, содержащая краткую информацию
// о пользователе для response
type UserInfo struct {
	ID      uuid.UUID `json:"id"`
	Name    string    `json:"name"`
	Surname string    `json:"surname"`
}

// CardInfo - структура, содержащая краткую информацию
// о карточке объявления для response
type CardInfo struct {
	ID   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

// GenericResponse - структура для общего ответа на запросы
type GenericResponse struct {
	Message string `json:"message,omitempty"`
	Code    string `json:"code,omitempty"`
}
