package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/unidoc/unioffice/document"
)

type TableData struct {
	System		string `json:"system"`
	Account		string `json:"account"`
	User		string `json:"user"`
	Privilege	string `json:"privilege"`
	Note		string `json:"note"`
}

func UploadJsonFillFormHandler(w http.ResponseWriter, r *http.Request) {
	err := r.ParseMultipartForm(10 << 20)
	if err != nil {
		http.Error(w, "File too big or malformed", http.StatusBadRequest)
		return
	}

	file, _, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Could not retrieve the file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// content, _ := io.ReadAll(file)
	// log.Print(string(content))
	// file.Seek(0, 0)

	var tableDataArray []TableData
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&tableDataArray)
	log.Print(tableDataArray)
	if err != nil {
		http.Error(w, "Invalid JSON content", http.StatusBadRequest)
		return
	}

	docPath := "./static/files/IS-D-019_帳號清查紀錄表.docx"

	_, err = os.Stat(docPath)
	if os.IsNotExist(err) {
		http.Error(w, "not found", http.StatusNotFound)
		fmt.Println("error path", docPath)
		return
	}

	doc, err := document.Open(docPath)
	if err != nil {
		log.Print(err)
		http.Error(w, "Could not open the document", http.StatusInternalServerError)
		return
	}

	addTableDatasToDocument(doc, tableDataArray)

	outputPath := "./static/tempfiles/output.docx"
	err = doc.SaveToFile(outputPath)
	if err != nil {
		http.Error(w, "Could not save the document", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename=output.docx")
	w.Header().Set("Content-Type", "application/vnd.openxmlformats-officiedocument.wordprecessingml.document")
	http.ServeFile(w, r, outputPath)

}

func addTableDatasToDocument(doc *document.Document, tableDataArray []TableData) {
	tables := doc.Tables()

	table := tables[0]

	for i, rowData := range tableDataArray {
		row := table.AddRow()
		row.AddCell().AddParagraph().AddRun().AddText(strconv.Itoa(i + 1))
		row.AddCell().AddParagraph().AddRun().AddText(rowData.System)
		row.AddCell().AddParagraph().AddRun().AddText(rowData.Account)
		row.AddCell().AddParagraph().AddRun().AddText(rowData.User)
		row.AddCell().AddParagraph().AddRun().AddText(rowData.Privilege)
		row.AddCell().AddParagraph().AddRun().AddText(rowData.Note)
	}
}