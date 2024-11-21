package handlers

import (
	"encoding/json"
	"net/http"
)

func GreetHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]string {
		"message": "Hello, welcome to webapi!",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}