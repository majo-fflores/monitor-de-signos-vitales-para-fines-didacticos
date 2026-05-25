package users

import (
	"net/http"
	"sist-inteligentes/cmd/database"
	"strconv"

	"github.com/labstack/echo/v5"
)

// CreateUser maneja la creación de un nuevo usuario.
func CreateUser(c *echo.Context) error {
	user := new(User)
	if err := c.Bind(user); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Datos inválidos"})
	}

	if user.Name == "" || user.Email == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "El nombre y el email son obligatorios"})
	}

	// Guardar en la base de datos
	if err := database.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "No se pudo crear el usuario o el email ya existe"})
	}

	return c.JSON(http.StatusCreated, user)
}

// GetUsers retorna la lista de todos los usuarios.
func GetUsers(c *echo.Context) error {
	var usersList []User
	if err := database.DB.Find(&usersList).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error al consultar los usuarios"})
	}

	return c.JSON(http.StatusOK, usersList)
}

// GetUser retorna un usuario por su ID.
func GetUser(c *echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "ID inválido"})
	}

	var user User
	if err := database.DB.First(&user, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Usuario no encontrado"})
	}

	return c.JSON(http.StatusOK, user)
}
