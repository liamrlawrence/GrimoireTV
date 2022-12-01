package database

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
	"log"
	"os"
)

func psqlConnectionString() string {
	var username = os.Getenv("PSQL_DB_USERNAME")
	var password = os.Getenv("PSQL_DB_PASSWORD")
	var hostname = os.Getenv("PSQL_DB_HOST")
	var port = os.Getenv("PSQL_DB_PORT")
	var database = os.Getenv("PSQL_DB_DATABASE")
	var config = os.Getenv("PSQL_DB_CONFIG")

	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s%s", username, password, hostname, port, database, config)
}

func ConnectToDatabase() (*pgx.Conn, error) {
	conn, err := pgx.Connect(context.Background(), psqlConnectionString())
	if err != nil {
		log.Printf("connect to database: %v", err)
		return conn, fmt.Errorf("connect to database: %v", err)
	}

	return conn, nil
}
