from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import base64
import json

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request model for creating tasks
class TaskCreate(BaseModel):
    title: str
    description: str = ""
    status: str = "pending"
    priority: str = "medium"

@app.get("/")
def root():
    return {"message": "Backend is running!"}

@app.post("/api/auth/login")
def login():
    # Create a fake JWT token with proper structure
    header = base64.urlsafe_b64encode(json.dumps({"alg": "HS256", "typ": "JWT"}).encode()).decode().rstrip("=")
    payload = base64.urlsafe_b64encode(json.dumps({"sub": "1", "email": "user@example.com"}).encode()).decode().rstrip("=")
    signature = "fake-signature"
    token = f"{header}.{payload}.{signature}"
    
    return {"status": "success", "token": token}

@app.get("/api/v1/profile")
def get_profile():
    return {
        "id": 1,
        "email": "user@example.com",
        "name": "Test User",
        "role": "user"
    }

@app.get("/api/tasks")
def get_tasks(sort_order: str = "asc"):
    return {
        "tasks": [
            {
                "id": 1,
                "title": "Sample Task 1",
                "description": "This is a test task",
                "status": "pending",
                "priority": "high",
                "created_at": "2026-01-28T10:00:00Z"
            },
            {
                "id": 2,
                "title": "Sample Task 2",
                "description": "Another test task",
                "status": "completed",
                "priority": "medium",
                "created_at": "2026-01-27T15:30:00Z"
            }
        ],
        "total": 2
    }

@app.post("/api/tasks")
def create_task(task: TaskCreate):
    # Return the created task with an ID
    return {
        "id": 3,
        "title": task.title,
        "description": task.description,
        "status": task.status,
        "priority": task.priority,
        "created_at": "2026-01-28T12:00:00Z"
    }

@app.get("/api/tasks/history")
def get_task_history():
    return {
        "history": [
            {
                "id": 1,
                "task_id": 1,
                "action": "created",
                "timestamp": "2026-01-28T10:00:00Z",
                "user": "Test User"
            },
            {
                "id": 2,
                "task_id": 2,
                "action": "completed",
                "timestamp": "2026-01-27T15:30:00Z",
                "user": "Test User"
            }
        ],
        "total": 2
    }