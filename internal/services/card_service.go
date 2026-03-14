// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/ports"
)

// CardService - объект, содержащий методы для просмотра,
// создания и изменения карточек объявлений
type CardService struct {
	cardRepo     ports.CardRepository
	userRepo     ports.UserRepository
	tokenService ports.TokenService
}

// NewCardRepository создает и возвращает новый объект CardService
func NewCardRepository(
	cardRepo ports.CardRepository,
	userRepo ports.UserRepository,
	tokenService ports.TokenService) ports.CardService {
	return &CardService{
		cardRepo:     cardRepo,
		userRepo:     userRepo,
		tokenService: tokenService,
	}
}
