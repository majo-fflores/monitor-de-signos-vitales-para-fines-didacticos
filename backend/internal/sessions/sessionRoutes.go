package sessions

import "github.com/labstack/echo/v5"

func RegisterSessionRoutes(e *echo.Echo) {
	e.POST("/sessions", CreateSession)
	e.GET("/sessions/:id", GetSession)
	e.GET("/sessions/:id/summary", GetSessionSummary)
	e.GET("/sessions/:id/export.csv", ExportSessionCSV)
	e.GET("/sessions/:id/export/csv", ExportSessionCSV)
	e.GET("/users/:userId/sessions", GetUserSessions)
	e.GET("/users/:userId/session-summaries", GetUserSessionSummaries)
	e.PUT("/sessions/:id/end", EndSession)
	e.DELETE("/sessions/:id", DeleteSession)
}
