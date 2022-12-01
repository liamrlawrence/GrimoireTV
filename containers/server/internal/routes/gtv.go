package routes

import (
	"fmt"
	"github.com/liamrlawrence/grimoireTV/internal/server"
	"net/http"
)

func HandlerServiceGtv(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	fmt.Fprint(w, "[{\"msg\": \"Ok!\"}]")
}

func HandlerRouteGtvHeartbeat(s *server.Server) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		fmt.Fprint(w, "[{\"msg\": \"Ok!\", \"val\": 1}]")
		return
	}
}
