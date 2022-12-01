package main

import (
	"fmt"
	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
	"github.com/liamrlawrence/grimoireTV/internal/database"
	"github.com/liamrlawrence/grimoireTV/internal/routes"
	"github.com/liamrlawrence/grimoireTV/internal/server"
	"net/http"
	"path/filepath"
)

func initialize(s *server.Server) error {
	// load environment variables
	var envFiles = [...]string{"database.env"}

	var err error
	for _, ef := range envFiles {
		err = godotenv.Load(filepath.Join("env", ef))
		if err != nil {
			return fmt.Errorf("initialize: %w", err)
		}
	}

	// connect to databases
	s.DB, err = database.ConnectToDatabase()
	if err != nil {
		return fmt.Errorf("initialize: %w", err)
	}

	// setup endpoints for routes
	routes.SetupEndpoints(s)
	return nil
}

func run(s *server.Server) error {

	// Start the HTTP server
	fmt.Println("Starting the server on :3000...")
	return http.ListenAndServe(":3000", s.Router)
}

func main() {
	s := server.Server{
		DB:     nil,
		Router: chi.NewRouter(),
	}

	err := initialize(&s)
	if err != nil {
		panic(err)
	}

	err = run(&s)
	if err != nil {
		panic(err)
	}
}
