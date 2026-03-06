// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/errors"
	"korst-backend/internal/ports"

	"github.com/nyaruka/phonenumbers"
)

// OTPService - объект, содержащий методы для отправки и подтверждения Otp
type OTPService struct {
	otpRepo ports.OTPRepository
}

// NewOTPService создает и возвращает новый объект OTPService
func NewOTPService(otpRepo ports.OTPRepository) ports.OTPService {
	return &OTPService{otpRepo: otpRepo}
}

// SendOTP отправляет Otp-код по номеру телефона и сохраняет его
func (s *OTPService) SendOTP(rawPhone string) error {
	// TODO: отправка и сохранение кода
	num, err := phonenumbers.Parse(rawPhone, "RU")
	if err != nil || !phonenumbers.IsValidNumber(num) {
		return errors.ErrorInvalidPhone
	}

	// phone := phonenumbers.Format(num, phonenumbers.E164)

	// TODO: отправка и сохранение кода

	return nil
}

// VerifyOTP сравнивает полученный Otp-код c сохраненным в БД
func (s *OTPService) VerifyOTP(rawPhone string, otp string) (
	responses.VerifyOTPResponse, error) {
	num, err := phonenumbers.Parse(rawPhone, "RU")
	if err != nil || !phonenumbers.IsValidNumber(num) {
		return responses.VerifyOTPResponse{},
			errors.ErrorInvalidPhone
	}

	// phone := phonenumbers.Format(num, phonenumbers.E164)

	// TODO: подтверждение кода верефикации

	accessToken := "someToken"
	refreshToken := "someToken"
	status := "someStatus"

	response := responses.VerifyOTPResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		Status:       status,
	}
	return response, nil
}
