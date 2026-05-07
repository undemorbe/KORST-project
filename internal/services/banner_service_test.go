// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	mockRepositories "korst-backend/internal/mocks/repositories"
	mockServices "korst-backend/internal/mocks/services"
	"os"
	"testing"

	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestSaveBanner тестирует сохранение рекламного баннера в БД
func TestSaveBanner(t *testing.T) {
	logger.InitLoggerTest()

	mockBannerRepo := &mockRepositories.MockBannerRepo{}
	mockFileService := &mockServices.MockFileService{}

	bannerService := NewBannerService(mockBannerRepo, mockFileService)

	fileName := "test.png"
	imageURL := "some-url"

	company := "some-company"
	link := "some-link"

	mockFileService.
		On("SaveBannerImage", nil, fileName, mock.AnythingOfType("uuid.UUID")).
		Return(imageURL, nil)

	mockBannerRepo.
		On("CreateBanner", mock.AnythingOfType("*entities.Banner")).
		Return(nil)

	err := bannerService.SaveBanner(company, link, nil, fileName)

	require.NoError(t, err)

	mockBannerRepo.AssertExpectations(t)
	mockFileService.AssertExpectations(t)
}

// TestGetBanners тестирует получение нескольких случайных баннеров
func TestGetBanners(t *testing.T) {

	mockBannerRepo := &mockRepositories.MockBannerRepo{}
	mockFileService := &mockServices.MockFileService{}

	bannerService := NewBannerService(mockBannerRepo, mockFileService)

	count := 5
	imageURL := "/image-url"
	baseImageRL := "https://base-url"
	link := "https://some-link"

	banner := entities.Banner{
		ImageURL: imageURL,
		Link:     link,
	}

	banners := []entities.Banner{banner}

	os.Setenv("BASE_URL", baseImageRL)

	mockBannerRepo.
		On("FindBanners", count).
		Return(banners, nil)

	response, err := bannerService.GetBanners(&count)

	require.NoError(t, err)
	require.Equal(t, baseImageRL+imageURL, response.Banners[0].ImageURL)
	require.Equal(t, link, response.Banners[0].Link)

	mockBannerRepo.AssertExpectations(t)
	mockFileService.AssertExpectations(t)
}
