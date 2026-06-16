package sessions

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v5"
)

func CreateSession(c *echo.Context) error {
	session := new(Session)
	if err := c.Bind(session); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request payload"})
	}
	if err := ServiceInstance.CreateSession(session); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusCreated, session)
}

func GetSession(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}
	session, err := ServiceInstance.GetSessionByID(uint(id))
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Session not found"})
	}
	return c.JSON(http.StatusOK, session)
}

func GetUserSessions(c *echo.Context) error {
	userID, err := strconv.Atoi(c.Param("userId"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid User ID format"})
	}
	sessionsList, err := ServiceInstance.GetSessionsByUserID(uint(userID))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Could not fetch sessions"})
	}
	return c.JSON(http.StatusOK, sessionsList)
}

func EndSession(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}

	reqBody := struct {
		Notes string `json:"notes"`
	}{}
	_ = c.Bind(&reqBody)

	if err := ServiceInstance.EndSession(uint(id), reqBody.Notes); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to end session"})
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "Session ended successfully"})
}

func DeleteSession(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}
	if err := ServiceInstance.DeleteSession(uint(id)); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to delete session"})
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "Session deleted successfully"})
}
func GetSessionSummary(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}
	summary, err := ServiceInstance.GetSessionSummary(uint(id))
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Session not found or error fetching summary"})
	}
	return c.JSON(http.StatusOK, summary)
}

func ExportSessionCSV(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}

	data, err := ServiceInstance.ExportSessionCSV(uint(id))
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Session not found or error exporting CSV"})
	}

	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("session_%d_%s.csv", id, timestamp)
	c.Response().Header().Set(
		echo.HeaderContentDisposition,
		fmt.Sprintf(`attachment; filename="%s"`, filename),
	)
	return c.Blob(http.StatusOK, "text/csv; charset=utf-8", data)
}

func GetUserSessionSummaries(c *echo.Context) error {
	userID, err := strconv.Atoi(c.Param("userId"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid User ID format"})
	}
	summaries, err := ServiceInstance.GetUserSessionSummaries(uint(userID))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, summaries)
}
