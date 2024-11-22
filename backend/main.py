import json
import os

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List
from pathlib import Path
from models import Item, Source
from utils import hash_string, get_files


app = FastAPI()

STATIC_DIR = Path(__file__).parent / "static"
STATIC_FILES = STATIC_DIR / "files"
STATIC_TEMPFILES = STATIC_DIR / "tempfiles"

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/download/{file}")
async def downloadscript(file):
    if file == "vm":
        filename = "vmscript.ps1"
    elif file == "git":
        filename = "gitscript.ps1"
    else:
        raise HTTPException(statuscode=404, detail="File not found")

    file_path = STATIC_FILES / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    if not file_path.is_relative_to(STATIC_FILES):
        raise HTTPException(status_code=403, detail="Forbidden")
    return FileResponse(file_path, media_type='application/octet-stream', filename=filename)

@app.post("/upload/")
async def upload_file(
    file: UploadFile = File(...),
    session: str = Form(...)):
    if not session:
        raise HTTPException(status_code=400, detail="session is required")
    try:
        contents = await file.read()
        rawdata = json.loads(contents)

        items = [Item(**item) for item in rawdata]
        session_id = hash_string(session)
        session_path = Path(STATIC_TEMPFILES) / session_id
        Path(session_path).mkdir(parents=True, exist_ok=True)
        file_path = Path(session_path) / file.filename

        with open(file_path, "wb") as f:
            f.write(contents)

        print(items)
        return {"message": "Filed uploaded and validated succefully", "items": items}
    
    except json.JSONDecoderError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid data format: {e}")


@app.get("/items/{session}")
async def read_items(session, source=Source.Nil):
    if not session:
        raise HTTPException(status_code=400, detail="session is required")

    if source == Source.Nil:
        raise HTTPException(status_code=404, detail=f"Not Found")
    elif source == Source.Git:
        prefix = "git"
    elif source == Source.VM:
        prefix = "vm"
    else:
        raise HTTPException(status_code=404, detail=f"Not Found")

    session_id = hash_string(session)
    session_path = Path(STATIC_TEMPFILES) / session_id
    if not Path(session_path).exists():
        raise HTTPException(status_code=404, detail=f"Not Found")
        
    files = get_files(session_path, prefix)
    return {"session_id": session, "files": files}

@app.post("/gen_report")
async def generate_report(
    session: str = Form(...),
    files: List[str] = Form(...)):
    if not session:
        raise HTTPException(status_code=400, detail="session is required")
    if not files.count:
        raise HTTPException(status_code=400, detail="session is required")

    session_id = hash_string(session)
    session_path = Path(STATIC_TEMPFILES) / session_id
    json_paths = [session_path.joinpath(filename).exists() for filename in files]
    output_filename = "output.docx"

    template_path = Path(STATIC_FILES) / "isd019.docx"
    output_path = Path(session_path) / output_filename

    generate_report(template_path, json_paths, output_path)

    return FileResponse(output_path, media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document", filename=output_filename)
