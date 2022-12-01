package routes

import (
	"github.com/liamrlawrence/grimoireTV/internal/controllers"
	"github.com/liamrlawrence/grimoireTV/internal/server"
	"github.com/liamrlawrence/grimoireTV/internal/templates"
	"github.com/liamrlawrence/grimoireTV/internal/views"
	"net/http"
)

func SetupEndpoints(s *server.Server) {
	// Pages
	s.Router.Get("/", controllers.StaticTemplateHandler(views.Must(
		views.ParseFS(templates.FS, "layout.gohtml", "hello.gohtml")),
	))
	s.Router.Get("/contact", controllers.StaticTemplateHandler(views.Must(
		views.ParseFS(templates.FS, "layout.gohtml", "contact.gohtml")),
	))
	s.Router.Get("/signup", controllers.StaticTemplateHandler(views.Must(
		views.ParseFS(templates.FS, "layout.gohtml", "signup.gohtml")),
	))

	// Services
	s.Router.Post("/api/auth/signup", HandlerRouteAuthSignUp(s))

	s.Router.Get("/api/gtv/heartbeat", HandlerRouteGtvHeartbeat(s))
	s.Router.Post("/api/gtv/heartbeat", HandlerRouteGtvHeartbeat(s))

	// 404
	s.Router.NotFound(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "Page not found", http.StatusNotFound)
	})
}
