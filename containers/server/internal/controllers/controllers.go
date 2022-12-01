package controllers

import (
	"github.com/liamrlawrence/grimoireTV/internal/views"
	"net/http"
)

func StaticTemplateHandler(tpl views.Template) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tpl.Execute(w, nil)
	}
}

//func StaticServerHandler(s *server.Server) http.HandlerFunc {
//	return func(w http.ResponseWriter, r *http.Request) {
//		tpl.Execute(w, nil)
//	}
//}
