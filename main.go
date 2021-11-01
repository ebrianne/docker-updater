package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/ebrianne/docker-updater/pkg/config"
	"github.com/ebrianne/docker-updater/pkg/server"
)

const (
	name = "updater-go"
)

var (
	s *server.Server
)

func main() {
	conf := config.Load()

	initHttpServer(conf.ServerPort)

	handleExitSignal()
}

func initHttpServer(port string) {
	s = server.NewServer(port)
	go s.ListenAndServe()
}

func handleExitSignal() {
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	<-stop

	s.Stop()
	fmt.Println(fmt.Sprintf("\n%s HTTP server stopped", name))
}
