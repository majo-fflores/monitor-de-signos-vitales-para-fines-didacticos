package users

import (
    "net/http"
    "strconv"

    "github.com/labstack/echo/v5"
)

func CreateUser(c *echo.Context) error {
    user := new(User)
    if err := c.Bind(user); err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": "Datos inválidos"})
    }
    if err := ServiceInstance.CreateUser(user); err != nil {
        if err.Error() == "el nombre, el email y un DNI válido son obligatorios" {
            return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
        }
        return c.JSON(http.StatusInternalServerError, map[string]string{"error": "No se pudo crear el usuario o el email/DNI ya existe"})
    }
    return c.JSON(http.StatusCreated, user)
}

func GetUsers(c *echo.Context) error {
    usersList, err := ServiceInstance.GetUsers()
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error al consultar los usuarios"})
    }
    return c.JSON(http.StatusOK, usersList)
}

func GetUser(c *echo.Context) error {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": "ID inválido"})
    }
    user, err := ServiceInstance.GetUser(uint(id))
    if err != nil {
        return c.JSON(http.StatusNotFound, map[string]string{"error": "Usuario no encontrado"})
    }
    return c.JSON(http.StatusOK, user)
}

func DeleteUser(c *echo.Context) error {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": "ID inválido"})
    }
    if err := ServiceInstance.DeleteUser(uint(id)); err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error al eliminar el usuario"})
    }
    return c.JSON(http.StatusOK, map[string]string{"message": "Usuario eliminado correctamente"})
}
