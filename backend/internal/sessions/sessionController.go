package sessions

import (
	"net/http"
	"strconv"

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
