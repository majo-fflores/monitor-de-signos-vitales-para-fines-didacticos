package spo2

import "github.com/labstack/echo/v5"

func RegisterSpo2Routes(e *echo.Echo) {
	e.POST("/spo2", CreateMeasurement)
	e.GET("/spo2/:id", GetMeasurement)
	e.GET("/sessions/:sessionId/spo2", GetSessionMeasurements)
	e.GET("/users/:userId/spo2", GetUserMeasurements)
	e.DELETE("/spo2/:id", DeleteMeasurement)
}
