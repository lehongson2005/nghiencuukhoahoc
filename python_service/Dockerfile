FROM python:3.10-slim

WORKDIR /app

# Cài đặt các thư viện hệ thống cần thiết cho OpenCV và Deep Learning
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Cài đặt thư viện Python (Thêm --no-cache-dir để giảm dung lượng image)
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose port 5000
EXPOSE 5000

# Chạy server uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
