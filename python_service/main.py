from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from pydantic import BaseModel
from deepface import DeepFace
import numpy as np
import shutil
import os
import json
from typing import List, Optional

app = FastAPI()

TEMP_DIR = "temp_images"
os.makedirs(TEMP_DIR, exist_ok=True)

class VerifyRequest(BaseModel):
    known_embedding: str # Chuỗi JSON của vector đã lưu trong DB

@app.get("/")
def read_root():
    return {"status": "AI Service is running"}

@app.post("/represent")
async def get_embedding(file: UploadFile = File(...)):
    """
    Nhận 1 ảnh khuôn mặt, trả về vector (embedding) để lưu vào DB.
    Dùng cho chức năng Đăng ký.
    """
    file_location = f"{TEMP_DIR}/{file.filename}"
    try:
        # Lưu file tạm
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Dùng DeepFace trích xuất đặc trưng
        # Model: Facenet512 (độ chính xác cao, vector 512 chiều)
        embedding_objs = DeepFace.represent(img_path=file_location, model_name="Facenet512", enforce_detection=False)
        
        if not embedding_objs:
             raise HTTPException(status_code=400, detail="No face detected")

        # Lấy vector đầu tiên (giả sử chỉ có 1 mặt)
        vector = embedding_objs[0]["embedding"]
        
        return {
            "status": True,
            "embedding": json.dumps(vector) # Trả về chuỗi JSON để lưu vào MySQL
        }

    except Exception as e:
        return {"status": False, "error": str(e)}
    finally:
        # Xóa file tạm
        if os.path.exists(file_location):
            os.remove(file_location)

@app.post("/verify")
async def verify_face(
    known_embedding: str = Form(...), 
    file: UploadFile = File(...)
):
    """
    Nhận 1 ảnh mới + vector cũ đã lưu.
    So sánh xem có khớp không.
    Dùng cho chức năng Check-in.
    """
    file_location = f"{TEMP_DIR}/{file.filename}"
    try:
        # 1. Lưu ảnh mới vào temp
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # 2. Tính vector của ảnh mới
        embedding_objs = DeepFace.represent(img_path=file_location, model_name="Facenet512", enforce_detection=False)
        
        if not embedding_objs:
             return {"status": False, "message": "Không tìm thấy khuôn mặt trong ảnh gửi lên"}
             
        new_vector = embedding_objs[0]["embedding"]
        
        # 3. Parse vector cũ từ chuỗi
        known_vector = json.loads(known_embedding)
        
        # 4. Tính khoảng cách Cosine
        a = np.array(known_vector)
        b = np.array(new_vector)
        
        # Cosine distance = 1 - Cosine Similarity
        cosine_distance = 1 - (np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))
        
        # Ngưỡng (Threshold) cho Facenet512 thường là 0.30 (theo DeepFace wiki)
        threshold = 0.30
        is_match = cosine_distance < threshold
        
        return {
            "status": True,
            "match": bool(is_match),
            "distance": float(cosine_distance),
            "threshold": threshold
        }

    except Exception as e:
        return {"status": False, "error": str(e)}
    finally:
        if os.path.exists(file_location):
            os.remove(file_location)
