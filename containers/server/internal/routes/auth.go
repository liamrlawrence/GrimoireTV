package routes

import (
	"context"
	"fmt"
	"github.com/liamrlawrence/grimoireTV/internal/server"
	"log"
	"net/http"
	"regexp"
)

func HandlerRouteAuthSignUp(s *server.Server) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		//r.Body = http.MaxBytesReader(w, r.Body, 1<<20) // TODO: How do I use this to err if size too big? Make middleware?
		err := r.ParseMultipartForm(1 << 20) // Max form size is ~1MB
		if err != nil {
			log.Printf("/api/auth/signup: %v", err)
			http.Error(w, "error parsing multipart/form-data", http.StatusInternalServerError)
		}

		username := r.FormValue("username")
		nickname := r.FormValue("nickname")
		email := r.FormValue("email")
		password := r.FormValue("password")
		log.Printf("/api/auth/signup: %s | %s | %s | %s\n", username, nickname, email, password)

		_, err = s.DB.Exec(context.Background(), "CALL SP_Insert_User($1, $2, $3, $4);", username, nickname, email, password)
		if err != nil {
			log.Printf("/api/auth/signup: SP_Insert_User() FAILED - %v", err)
			re := regexp.MustCompile(`^ERROR:\s(.*)\s\(SQLSTATE \w+\d+\)$`)
			errMsg := re.FindAllStringSubmatch(err.Error(), -1)[0][1]

			switch errMsg {
			// TODO: Update case name to match message name for password length, I like removed
			case "password length must be at least 8 characters":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "passwords must be at least 8 characters"
							}]`)

			case "password length cannot exceed 500 characters":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "passwords cannot exceed 500 characters"
							}]`)

			case "duplicate key value violates unique constraint \"users_username_key\"":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "username already in use"
							}]`)

			case "duplicate key value violates unique constraint \"users_email_key\"":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "email already in use"
							}]`)

			case "new row for relation \"users\" violates check constraint \"users_username_check\"":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "usernames must be 3-30 characters"
							}]`)

			case "new row for relation \"users\" violates check constraint \"users_email_check\"":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "emails must be 3-256 characters"
							}]`)

			case "new row for relation \"users\" violates check constraint \"users_nickname_check\"":
				w.WriteHeader(http.StatusForbidden)
				w.Header().Set("Content-Type", "application/json; charset=utf-8")
				fmt.Fprint(w, `[{
								"status": "error",
								"message": "nicknames cannot exceed 50 characters"
							}]`)

			default:
				http.Error(w, errMsg, http.StatusInternalServerError)
			}

			return
		}

		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		fmt.Fprint(w, `[{
						"status": "success",
						"message": "account created"
					}]`)
	}
}
