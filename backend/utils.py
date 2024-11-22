import hashlib
import json
from typing import List
import os
from models import Item
from pathlib import Path
from docx import Document

def hash_string(text: str, hash_function="sha1") -> str:
    hash_object = getattr(hashlib, hash_function)(text.encode())
    return hash_object.hexdigest()

def get_files(folder_path: str, prefix: str) -> list[str]:
    try:
        files = [
            f.name for f in Path(folder_path).glob(f"{prefix}*") if f.is_file()
        ]
        return files
    except FileNotFoundError:
        print(f"Folder not found: {folder_path}")
        return[]

def merge_data(json_paths: List[str]) -> List[dict]:
    merged_data = []
    for json_path in json_paths:
        try:
            with open(json_path, 'r') as f:
                data = json.load(f)
                if isinstance(data, list):
                    merge_data.extend(data)
                else:
                    print("error")
        except FileNotFoundError:
            print(f"Error File Not Found! {json_path}")
        except json.JSONDecodeError:
            print(f"json decode error")
    return merged_data


def generate_report(template_path: str, json_paths: List[str], output_path: str):
    report = Document(template_path)
    table = report.tables[0]

    jsons = merge_data(json_paths)

    for data in jsons:
        row_cells = table.add_row().cells
        row_cells[0].text = str(data.get("id", ""))
        row_cells[1].text = str(data.get("system", ""))
        row_cells[2].text = str(data.get("account", ""))
        row_cells[3].text = str(data.get("user", ""))
        row_cells[4].text = str(data.get("privilege", ""))
        row_cells[5].text = str(data.get("note", ""))

    report.save(output_path)