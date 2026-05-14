// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// DeepLinkHandler - структура для обработки
// запросов, связанных с Deep Link (открытием в
// приложении на устройстве через ссылку)
type DeepLinkHandler struct{}

// NewDeepLinkHandler - создает и возвращает новый объект DeepLinkHandler
func NewDeepLinkHandler() *DeepLinkHandler {
	return &DeepLinkHandler{}
}

// HandleAssetLinks обрабатывает Asset Link
// для открытия приложения на Android
func (h *DeepLinkHandler) HandleAssetLinks(c *gin.Context) {

	c.Data(http.StatusOK, "application/json", []byte(`[
		{
			"relation": ["delegate_permission/common.handle_all_urls"],
			"target": {
				"namespace": "android_app",
				"package_name": "com.korst.app",
				"sha256_cert_fingerprints": [
					"92:94:0A:7F:41:FC:93:77:8A:A8:71:6B:D9:20:89:2B:A3:F7:6F:E6:71:E1:39:4F:5C:F1:01:2E:57:72:EE:C2"
				]
			}
		}
	]`))
}

// OpenCard отправляет в приложение или скачивает
// его при попытке перейти по Deep Link
func (h *DeepLinkHandler) OpenCard(c *gin.Context) {

	id := c.Param("id")

	c.Header("Content-Type", "text/html")

	c.String(200, `
	<html>
	  <body>
		<script>
		  window.location = "korst://cards/`+id+`";

		  setTimeout(function() {
			window.location = "https://2839bc9a-d491-41f2-94d8-c3c98ffedc32.tunnel4.com/uploads/app/app-release.apk";
		  }, 1500);
		</script>

		<p>Opening app...</p>
	  </body>
	</html>
	`)
}
