package users

import "github.com/labstack/echo/v5"

func RegisterUserRoutes(e *echo.Echo) {
    e.POST("/users", CreateUser)
    e.GET("/users", GetUsers)
    e.GET("/users/:id", GetUser)
    e.DELETE("/users/:id", DeleteUser)
}
