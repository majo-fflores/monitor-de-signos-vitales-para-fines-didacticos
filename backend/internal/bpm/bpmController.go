package bpm

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v5"
)

func CreateMeasurement(c *echo.Context) error {
	measurement := new(BpmMeasurement)
	if err := c.Bind(measurement); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request payload"})
	}
	if err := ServiceInstance.CreateMeasurement(measurement); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusCreated, measurement)
}

func GetMeasurement(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}
	measurement, err := ServiceInstance.GetMeasurementByID(uint(id))
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Measurement not found"})
	}
	return c.JSON(http.StatusOK, measurement)
}

func GetSessionMeasurements(c *echo.Context) error {
	sessionID, err := strconv.Atoi(c.Param("sessionId"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid Session ID format"})
	}
	measurements, err := ServiceInstance.GetMeasurementsBySessionID(uint(sessionID))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Could not fetch measurements"})
	}
	return c.JSON(http.StatusOK, measurements)
}

func DeleteMeasurement(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid ID format"})
	}
	if err := ServiceInstance.DeleteMeasurement(uint(id)); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to delete measurement"})
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "Measurement deleted successfully"})
}

func GetUserMeasurements(c *echo.Context) error {
	userID, err := strconv.Atoi(c.Param("userId"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid User ID format"})
	}
	measurements, err := ServiceInstance.GetMeasurementsByUserID(uint(userID))
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, measurements)
}
