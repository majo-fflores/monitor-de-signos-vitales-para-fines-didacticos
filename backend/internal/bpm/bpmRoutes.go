package bpm

import "github.com/labstack/echo/v5"

func RegisterBpmRoutes(e *echo.Echo) {
	e.POST("/bpm", CreateMeasurement)
	e.GET("/bpm/:id", GetMeasurement)
	e.GET("/sessions/:sessionId/bpm", GetSessionMeasurements)
	e.DELETE("/bpm/:id", DeleteMeasurement)
}
