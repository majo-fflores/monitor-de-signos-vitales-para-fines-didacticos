package sessions

import "github.com/labstack/echo/v5"

func RegisterSessionRoutes(e *echo.Echo) {
	e.POST("/sessions", CreateSession)
	e.GET("/sessions/:id", GetSession)
	e.GET("/sessions/:id/summary", GetSessionSummary)
	e.GET("/users/:userId/sessions", GetUserSessions)
	e.PUT("/sessions/:id/end", EndSession)
	e.DELETE("/sessions/:id", DeleteSession)
}
