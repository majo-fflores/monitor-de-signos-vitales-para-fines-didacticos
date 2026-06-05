package air

import "github.com/labstack/echo/v5"

func RegisterAirRoutes(e *echo.Echo) {
	e.POST("/air", CreateMeasurement)
	e.GET("/air/:id", GetMeasurement)
	e.GET("/sessions/:sessionId/air", GetSessionMeasurements)
	e.GET("/users/:userId/air", GetUserMeasurements)
	e.DELETE("/air/:id", DeleteMeasurement)
}
