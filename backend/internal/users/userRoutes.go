package users

import "github.com/labstack/echo/v5"

// RegisterUserRoutes registers the user‑related HTTP routes on the provided Echo instance.
func RegisterUserRoutes(e *echo.Echo) {
    e.POST("/users", CreateUser)
    e.GET("/users", GetUsers)
    e.GET("/users/:id", GetUser)
}
