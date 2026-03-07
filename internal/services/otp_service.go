// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"bytes"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"math/big"
	"mime/multipart"
	"net/http"
	"os"

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

	phone := phonenumbers.Format(num, phonenumbers.E164)
	code, err := s.generateOTP()
	if err != nil {
		logger.Log.Error("Ошибка при генерации OTP-кода")
		return errors.ErrorInternal
	}

	err = s.sendCodeToNumber(phone, code)
	if err != nil {
		logger.Log.Error("Ошибка при отправке OTP-кода")
		return errors.ErrorInternal
	}

	newOTP := &entities.Otp{
		Code:  code,
		Phone: phone,
	}

	err = s.otpRepo.CreateOTP(newOTP)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении OTP-кода")
		return errors.ErrorInternal
	}

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

// generateOTP генерирует случайный OTP-код
func (s *OTPService) generateOTP() (string, error) {
	number, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", errors.ErrorInternal
	}

	return fmt.Sprintf("%06d", number.Int64()), nil
}

// sendCodeToNumber отправляет запрос на отправку OTP на номер телефона
func (s *OTPService) sendCodeToNumber(phone string, code string) error {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	project := os.Getenv("PROJECT_NAME")
	apiKey := os.Getenv("NOTISEND_API_KEY")
	url := os.Getenv("NOTISEND_URL")

	writer.WriteField("project", project)
	writer.WriteField("recipients", phone)
	writer.WriteField("message", code)
	writer.WriteField("apikey", apiKey)

	writer.Close()

	req, err := http.NewRequest(
		http.MethodGet,
		url,
		body,
	)
	if err != nil {
		return errors.ErrorInternal
	}

	req.Header.Set("Content-Type", writer.FormDataContentType())
	req.Header.Set("Accept", "application/json")

	client := &http.Client{}
	response, err := client.Do(req)
	if err != nil {
		logger.Log.Error("Ошибка при отправке запроса: ", err)
		return errors.ErrorInternal
	}
	defer response.Body.Close()

	var result responses.NotisendResponse

	err = json.NewDecoder(response.Body).Decode(&result)
	if err != nil {
		logger.Log.Error("Ошибка при декодировании ответа: ", err)
		return errors.ErrorInternal
	}

	if result.Status != "success" {
		logger.Log.Error("Не удалость отправить OTP-код, Status: ", result.Status)
		return errors.ErrorInternal
	}

	return nil
}
