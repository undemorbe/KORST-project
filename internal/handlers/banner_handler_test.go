// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	mockServices "korst-backend/internal/mocks/services"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestSaveBanner проверяет обработку запроса на
// сохранение баннера вместе с его изображением
func TestSaveBanner(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockBannerService := &mockServices.MockBannerService{}
	bannerHandler := NewBannerHandler(mockBannerService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())

	router.POST("/banners", bannerHandler.SaveBanner)

	var body bytes.Buffer
	writer := multipart.NewWriter(&body)

	_ = writer.WriteField("company", "test-company")
	_ = writer.WriteField("link", "https://example.com")

	part, err := writer.CreateFormFile("image", "test.png")
	require.NoError(t, err)

	_, err = part.Write([]byte("fake-image-bytes"))
	require.NoError(t, err)

	writer.Close()

	mockBannerService.
		On("SaveBanner",
			"test-company",
			"https://example.com",
			mock.Anything,
			"test.png",
		).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/banners",
		&body,
	)

	req.Header.Set("Content-Type", writer.FormDataContentType())

	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	require.Equal(t, http.StatusOK, resp.Code)
	mockBannerService.AssertExpectations(t)
}

// TestGetBanners проверяет обработку запроса на
// получение нескольких случайных рекламных баннеров
func TestGetBanners(t *testing.T) {

	mockBannerService := &mockServices.MockBannerService{}
	bannerHandler := NewBannerHandler(mockBannerService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())

	router.GET("/banners", bannerHandler.GetBanners)

	count := 3

	expected := responses.GetBannersResponse{
		Banners: []responses.BannerInfo{
			{
				ImageURL: "url1",
				Link:     "link1",
			},
		},
	}

	mockBannerService.
		On("GetBanners", &count).
		Return(expected, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		fmt.Sprintf("/banners?count=%d", count),
		nil,
	)

	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	require.Equal(t, http.StatusOK, resp.Code)

	var result responses.GetBannersResponse
	err := json.Unmarshal(resp.Body.Bytes(), &result)
	require.NoError(t, err)

	require.Equal(t, expected.Banners[0].ImageURL, result.Banners[0].ImageURL)
	require.Equal(t, expected.Banners[0].Link, result.Banners[0].Link)

	mockBannerService.AssertExpectations(t)
}
