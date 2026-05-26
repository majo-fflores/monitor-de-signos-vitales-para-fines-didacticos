# Recetas de just para el backend

# Ejecuta el backend en modo desarrollo
run-backend:
    cd backend && go run cmd/app/main.go

# Compila el backend
build:
    cd backend && go build ./...

# Compila y ejecuta el binario del backend
start: build
    cd backend && ./server

# Organiza y descarga las dependencias de Go
tidy:
    cd backend && go mod tidy
setup:
    cp backend/.env.example backend/.env
    cd backend && go build -o server cmd/app/main.go
    cd backend && go mod tidy


# Ejecuta las pruebas del backend
test:
    cd backend && go test ./...

# Limpia los archivos compilados generados
clean:
    rm -f backend/server
