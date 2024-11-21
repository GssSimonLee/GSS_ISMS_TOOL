package handlers

import (
	"net/http"
	"os"
	"path/filepath"
	"log"
	"github.com/gorilla/mux"
)

func DownloadFileHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	fileName := vars["filename"]

	filePath := filepath.Join("./static/files", fileName)
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		log.Printf("path: %s", filePath)
		http.Error(w, "File not found", http.StatusNotFound)
		return
	}

	http.ServeFile(w, r, filePath)
}