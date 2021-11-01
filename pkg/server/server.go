package server

import (
	"context"
	_ "embed"
	"net/http"
	"strings"
	"time"

	"github.com/ebrianne/docker-updater/pkg/log"
)

// Server is the struct for the HTTP server.
type Server struct {
	httpServer *http.Server
}

var (
	//go:embed index.html
	index []byte
	//go:embed favicon.ico
	favicon []byte
)

// NewServer method initializes a new HTTP server instance and associates
// the different routes that will be used to trigger an update
func NewServer(port string) *Server {
	mux := http.NewServeMux()
	httpServer := &http.Server{Addr: ":" + port, Handler: mux}

	s := &Server{
		httpServer: httpServer,
	}

	mux.Handle("/api/v1/update", s.updateHandler())
	mux.Handle("/api/v1/logs", s.handleLogs())
	mux.Handle("/favicon.ico", s.handleFavicon())
	mux.Handle("/", s.handleRoot())

	return s
}

// ListenAndServe method serves HTTP requests.
func (s *Server) ListenAndServe() {
	err := s.httpServer.ListenAndServe()
	if err != nil {
		// log.Printf("Failed to start serving HTTP requests: %v", err)
	}
}

// Stop method stops the HTTP server (so the exporter become unavailable).
func (s *Server) Stop() {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	s.httpServer.Shutdown(ctx)
}

func (s *Server) handleRoot() http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if s.isReady() {
			w.Header().Set("Content-Type", "text/html")
			_, _ = w.Write(index)
		} else {
			w.WriteHeader(http.StatusNotFound)
		}
	})
}

func (s *Server) handleFavicon() http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if s.isReady() {
			w.Header().Set("Content-Type", "image/x-icon")
			_, _ = w.Write(favicon)
		} else {
			w.WriteHeader(http.StatusNotFound)
		}
	})
}

func (s *Server) handleLogs() http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if s.isReady() {
			_, _ = w.Write([]byte(strings.Join(log.Logs(), "")))
		} else {
			w.WriteHeader(http.StatusNotFound)
		}
	})
}

func (s *Server) updateHandler() http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if s.isReady() {

		} else {
			w.WriteHeader(http.StatusNotFound)
		}
	})
}

func (s *Server) isReady() bool {
	return s.httpServer != nil
}
