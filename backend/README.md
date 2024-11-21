# Backend Web Api for GSS.ISMS.TOOL

## how to run

1. move to the backend path
1. do `go run cmd/webapi/main.go` command

## API

1. Greet `curl http://localhost:8080/api/greet`
1. Download `curl -O http://localhost:8080/api/download/{filename}`
1. Upload `curl -F "file=@<filename>" http://localhost:8080/api/upload`