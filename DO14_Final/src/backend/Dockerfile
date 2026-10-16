FROM python:3.10
WORKDIR /backend

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

WORKDIR /backend/src
EXPOSE 8000
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
