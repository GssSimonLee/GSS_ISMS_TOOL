package main

import (
	"log"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/GssSimonLee/GSS_ISMS_TOOL/backend/internal/handlers"
)

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/api/greet", handlers.GreetHandler).Methods("GET")

	r.HandleFunc("/api/download/{filename}", handlers.DownloadFileHandler).Methods("GET")

	r.HandleFunc("/api/upload", handlers.UploadFilehandler).Methods("POST")

	r.HandleFunc("/api/upload-fillform", handlers.UploadJsonFillFormHandler).Methods("POST")

	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("./static/files"))))

	port := ":8080"
	log.Printf("Starting server on %s\n", port)
	log.Fatal(http.ListenAndServe(port, r))
}