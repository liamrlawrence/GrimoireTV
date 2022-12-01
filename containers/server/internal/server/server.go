package server

import (
	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5"
)

type Server struct {
	DB     *pgx.Conn
	Router *chi.Mux
}
