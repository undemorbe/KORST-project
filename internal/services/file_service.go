// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"io"
	"korst-backend/internal/errors"
	"korst-backend/internal/ports"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"github.com/google/uuid"
)

// FileService - объект, содержащий методы для работы с хранилищем
type FileService struct {
	storage ports.Storage
}

// NewFileService создает и возвращает новый объект FileService
func NewFileService(storage ports.Storage) ports.FileService {
	return &FileService{storage: storage}
}

// SaveProfileImage сохраняет изображение профиля в
// хранилище и возвращает ссылку на него
func (s *FileService) SaveProfileImage(file io.Reader,
	fileName string, userID uuid.UUID) (string, error) {

	ext := filepath.Ext(fileName)
	if !s.isValidExtension(ext) {
		return "", errors.ErrorInvalidInput
	}

	name := userID.String() + ext
	dirName := os.Getenv("PROFILE_IMAGE_DIR")
	basePath := os.Getenv("BASE_PATH")

	path := filepath.Join(dirName, name)

	err := s.storage.Delete(path)
	if err != nil {
		return "", err
	}

	fullPath, err := s.storage.Save(file, path)
	if err != nil || fullPath == "" {
		return "", errors.ErrorInternal
	}

	url := "/" + basePath + "/" + dirName + "/" + name
	return url, nil
}

// SaveCardImage сохраняет изображение карточки в
// хранилище и возвращает ссылку на него
func (s *FileService) SaveCardImage(file io.Reader,
	fileName string, cardID uuid.UUID) (string, error) {

	ext := filepath.Ext(fileName)
	if !s.isValidExtension(ext) {
		return "", errors.ErrorInvalidInput
	}

	name := cardID.String() + ext
	dirName := os.Getenv("CARD_IMAGE_DIR")
	basePath := os.Getenv("BASE_PATH")

	path := filepath.Join(dirName, name)

	err := s.storage.Delete(path)
	if err != nil {
		return "", err
	}

	fullPath, err := s.storage.Save(file, path)
	if err != nil || fullPath == "" {
		return "", errors.ErrorInternal
	}

	url := "/" + basePath + "/" + dirName + "/" + name
	return url, nil
}

// SaveMessageImage сохраняет изображение для сообщения
// в хранилище и возвращает ссылку на него
func (s *FileService) SaveMessageImage(file io.Reader,
	fileName string, messageID uuid.UUID) (string, error) {

	ext := filepath.Ext(fileName)
	if !s.isValidExtension(ext) {
		return "", errors.ErrorInvalidInput
	}

	name := messageID.String() + ext
	dirName := os.Getenv("MESSAGE_IMAGE_DIR")
	basePath := os.Getenv("BASE_PATH")

	path := filepath.Join(dirName, name)

	err := s.storage.Delete(path)
	if err != nil {
		return "", err
	}

	fullPath, err := s.storage.Save(file, path)
	if err != nil || fullPath == "" {
		return "", errors.ErrorInternal
	}

	url := "/" + basePath + "/" + dirName + "/" + name
	return url, nil
}

// SaveBannerImage сохраняет изображение для баннера
// в хранилище и возвращает ссылку на него
func (s *FileService) SaveBannerImage(file io.Reader,
	fileName string, bannerID uuid.UUID) (string, error) {

	ext := filepath.Ext(fileName)
	if !s.isValidExtension(ext) {
		return "", errors.ErrorInvalidInput
	}

	name := bannerID.String() + ext
	dirName := os.Getenv("BANNER_IMAGE_DIR")
	basePath := os.Getenv("BASE_PATH")

	path := filepath.Join(dirName, name)

	err := s.storage.Delete(path)
	if err != nil {
		return "", err
	}

	fullPath, err := s.storage.Save(file, path)
	if err != nil || fullPath == "" {
		return "", errors.ErrorInternal
	}

	url := "/" + basePath + "/" + dirName + "/" + name
	return url, nil
}

// isValidExtension проверяет, является ли расширение валидным
func (s *FileService) isValidExtension(ext string) bool {
	validExtensions := []string{".pdf", ".png", ".jpg", ".jpeg", ".gif"}
	ext = strings.ToLower(ext)

	return slices.Contains(validExtensions, ext)
}
