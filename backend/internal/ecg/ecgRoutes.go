package ecg

import "github.com/labstack/echo/v5"

func RegisterEcgRoutes(e *echo.Echo) {
	e.POST("/ecg", CreateMeasurement)
	e.GET("/ecg/:id", GetMeasurement)
	e.GET("/sessions/:sessionId/ecg", GetSessionMeasurements)
	e.GET("/users/:userId/ecg", GetUserMeasurements)
	e.DELETE("/ecg/:id", DeleteMeasurement)
}
