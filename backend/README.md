# Guía de Comandos Go - Proyecto Echo + GORM

Este archivo contiene los comandos esenciales de Go utilizados para inicializar, gestionar dependencias, compilar y ejecutar este proyecto, junto con una explicación detallada de cada uno de ellos.

---

## 1. Inicialización y Gestión de Módulos

### `go mod init <nombre-del-modulo>`
Inicializa un nuevo módulo Go en el directorio actual, creando el archivo `go.mod`. Este archivo define la ruta de importación de tu módulo y las dependencias que requiere.
*   **Ejemplo utilizado**:
    ```bash
    go mod init backend
    ```

### `go mod tidy`
Asegura que los archivos `go.mod` y `go.sum` coincidan exactamente con el código fuente del proyecto. Este comando:
*   Añade cualquier dependencia necesaria para compilar los paquetes del módulo.
*   Remueve dependencias que ya no se utilizan en el código.
*   Actualiza el archivo de suma de verificación (`go.sum`) para garantizar que las descargas futuras sean idénticas y seguras.
*   **Uso común**: Se ejecuta siempre que agregas o eliminas importaciones en tus archivos `.go`.
    ```bash
    go mod tidy
    ```

---

## 2. Gestión de Dependencias

### `go get <ruta-del-paquete>`
Descarga e instala paquetes de terceros (junto con sus dependencias) en tu entorno de desarrollo y los añade a `go.mod` como requerimientos.
*   **Ejemplos utilizados**:
    ```bash
    # Para instalar el framework web Echo v5
    go get github.com/labstack/echo/v5

    # Para instalar el ORM GORM
    go get gorm.io/gorm

    # Para instalar el driver de base de datos SQLite para GORM
    go get gorm.io/driver/sqlite
    ```

---

## 3. Ejecución y Desarrollo

### `go run <archivo-o-directorio>`
Compila temporalmente el código en memoria y ejecuta la aplicación de forma inmediata. Es ideal para la etapa de desarrollo rápido.
*   **Uso en el proyecto**:
    ```bash
    # Ejecuta el punto de entrada principal
    go run cmd/app/main.go
    ```

### `go fmt ./...`
Formatea automáticamente el código fuente de todos los archivos del proyecto según las pautas de estilo estándar de Go (espaciado, tabulaciones, orden de importaciones, etc.).
*   **Uso recomendado**: Ejecutarlo antes de realizar cualquier commit para mantener un estilo homogéneo y limpio.
    ```bash
    go fmt ./...
    ```

---

## 4. Compilación y Despliegue

### `go build -o <nombre-binario> <punto-de-entrada>`
Compila el código de tu aplicación y genera un archivo ejecutable binario nativo y optimizado, listo para ser ejecutado o desplegado en producción sin requerir tener Go instalado en la máquina destino.
*   **Ejemplo utilizado**:
    ```bash
    # Compila main.go y genera un ejecutable llamado "server" en la raíz
    go build -o server cmd/app/main.go
    ```
*   **Para ejecutar el binario generado**:
    ```bash
    ./server
    ```

---

## 5. Pruebas y Calidad de Código

### `go test ./...`
Busca y ejecuta todas las funciones de prueba recursivamente dentro del proyecto (cualquier función que empiece con `Test` en archivos que terminen en `_test.go`).
*   **Uso común**:
    ```bash
    go test ./...
    ```

### `go vet ./...`
Examina el código fuente de Go y reporta posibles errores sospechosos que el compilador no detecta, como argumentos incorrectos en funciones de formato (`Printf`), variables no utilizadas, o problemas de sincronización de hilos.
*   **Uso común**:
    ```bash
    go vet ./...
    ```
