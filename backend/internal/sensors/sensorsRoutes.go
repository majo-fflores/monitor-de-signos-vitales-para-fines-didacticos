package sensors

import (
	"log"
	"net/http"

	"github.com/labstack/echo/v5"
	"golang.org/x/net/websocket"
)

func RegisterSensorRoutes(e *echo.Echo) {
	wsServer := websocket.Server{
		Handler: websocket.Handler(wsSensorHandler),
		Handshake: func(config *websocket.Config, req *http.Request) error {
			// Temporal
			return nil
		},
	}
	e.GET("/ws/sensors", echo.WrapHandler(wsServer))
}

func wsSensorHandler(ws *websocket.Conn) {
	defer ws.Close()

	if GlobalManager == nil {
		log.Println("GlobalManager no inicializado")
		return
	}

	ch := make(chan WsPacket, 100)

	GlobalManager.Subscribe(ch)
	defer GlobalManager.Unsubscribe(ch)

	log.Println("Cliente WebSocket conectado a sensores")

	for packet := range ch {
		err := websocket.JSON.Send(ws, packet)
		if err != nil {
			log.Printf("Error enviando datos por WS (cliente desconectado?): %v\n", err)
			break
		}
	}
	log.Println("Cliente WebSocket desconectado")
}