import os
import requests
import re
from sqlmodel import Session, select
from app.models.task import Task
from datetime import datetime


class TaskAgent:
    def __init__(self):
        self.api_key = os.environ.get("GROQ_API_KEY")
        if not self.api_key:
            raise ValueError("GROQ_API_KEY not set")
        
        self.system_prompt = """You are a direct, action-oriented task management assistant. 

RULES:
1. When user asks to add/create a task → IMMEDIATELY create it
2. When user asks to edit/update a task → IMMEDIATELY update it
3. When user asks to delete/remove a task → IMMEDIATELY delete it
4. When user asks to complete/mark done a task → IMMEDIATELY mark it complete
5. Extract details from user's message - don't ask unnecessary questions
6. Respond concisely - NO long explanations

Be direct and helpful!"""

    def chat(self, session: Session, user_id: int, message: str, conversation_history: list) -> str:
        """Process user message and take direct action"""
        
        print(f"\n{'='*60}")
        print(f"🤖 TaskAgent Processing")
        print(f"   User: {user_id}")
        print(f"   Message: {message}")
        print(f"{'='*60}\n")
        
        # Detect intent
        intent = self._detect_intent(message)
        print(f"🎯 Detected Intent: {intent}")
        
        try:
            # Execute action
            if intent == "ADD":
                return self._add_task(session, user_id, message)
            elif intent == "EDIT":
                return self._edit_task(session, user_id, message)
            elif intent == "DELETE":
                return self._delete_task(session, user_id, message)
            elif intent == "COMPLETE":
                return self._complete_task(session, user_id, message)
            elif intent == "LIST":
                return self._list_tasks(session, user_id)
            else:
                return self._general_chat(message, conversation_history)
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            return f"Sorry, I encountered an error: {str(e)}"
    
    def _detect_intent(self, message: str) -> str:
        """Detect user intent"""
        msg = message.lower()
        
        if any(word in msg for word in ["edit", "update", "change", "modify", "rename"]):
            return "EDIT"
        if any(word in msg for word in ["delete", "remove", "cancel"]):
            return "DELETE"
        if any(word in msg for word in ["complete", "done", "finish", "mark done"]):
            return "COMPLETE"
        if any(word in msg for word in ["list", "show", "my tasks", "all tasks"]):
            return "LIST"
        if any(word in msg for word in ["add", "create", "new", "remind"]):
            return "ADD"
        
        return "CHAT"
    
    def _add_task(self, session: Session, user_id: int, message: str) -> str:
        """Add a new task"""
        print("➕ Adding task...")
        
        title = self._extract_task_title(message)
        status = self._extract_status(message)
        priority = self._extract_priority(message)
        
        # Create task without is_deleted field
        task_data = {
            "user_id": user_id,
            "title": title,
            "description": "",
            "status": status,
            "priority": priority
        }
        
        # Only add is_deleted if the field exists
        try:
            new_task = Task(**task_data, is_deleted=False)
        except:
            new_task = Task(**task_data)
        
        session.add(new_task)
        session.commit()
        session.refresh(new_task)
        
        print(f"✅ Task created: {title} (ID: {new_task.id})")
        
        status_emoji = "🔄" if status == "in_progress" else "📋"
        return f"✅ Task added: {title} {status_emoji}"
    
    def _edit_task(self, session: Session, user_id: int, message: str) -> str:
        """Edit existing task"""
        print("✏️ Editing task...")
        
        # Get all tasks (without is_deleted filter)
        tasks = session.exec(
            select(Task).where(Task.user_id == user_id)
        ).all()
        
        if not tasks:
            return "❌ No tasks found"
        
        # Extract old and new titles
        msg = message.lower()
        
        edit_patterns = [
            r'edit\s+(?:task\s+)?(.+?)\s+to\s+(.+)',
            r'update\s+(?:task\s+)?(.+?)\s+to\s+(.+)',
            r'change\s+(?:task\s+)?(.+?)\s+to\s+(.+)',
            r'rename\s+(?:task\s+)?(.+?)\s+to\s+(.+)',
        ]
        
        old_title = None
        new_title = None
        
        for pattern in edit_patterns:
            match = re.search(pattern, msg, re.IGNORECASE)
            if match:
                old_title = match.group(1).strip()
                new_title = match.group(2).strip()
                break
        
        if not old_title or not new_title:
            return "❌ Please use format: 'edit [old name] to [new name]'"
        
        # Find matching task
        matching_task = None
        for task in tasks:
            if old_title in task.title.lower() or task.title.lower() in old_title:
                matching_task = task
                break
        
        if not matching_task:
            return f"❌ Task '{old_title}' not found"
        
        # Update title
        matching_task.title = new_title.capitalize()
        session.commit()
        
        print(f"✅ Task updated to: {new_title}")
        return f"✅ Task updated: {new_title}"
    
    def _delete_task(self, session: Session, user_id: int, message: str) -> str:
        """Delete task"""
        print("🗑️ Deleting task...")
        
        tasks = session.exec(
            select(Task).where(Task.user_id == user_id)
        ).all()
        
        if not tasks:
            return "❌ No tasks found"
        
        # Extract task name
        msg = message.lower()
        for word in ["delete", "remove", "cancel", "task"]:
            msg = msg.replace(word, "")
        title = msg.strip()
        
        if not title:
            return "❌ Please specify task to delete"
        
        # Find task
        matching_task = None
        for task in tasks:
            if title in task.title.lower() or task.title.lower() in title:
                matching_task = task
                break
        
        if not matching_task:
            return f"❌ Task '{title}' not found"
        
        # Delete task (hard delete if is_deleted doesn't exist)
        task_title = matching_task.title
        
        try:
            # Try soft delete first
            matching_task.is_deleted = True
            session.commit()
        except:
            # If is_deleted doesn't exist, hard delete
            session.delete(matching_task)
            session.commit()
        
        print(f"✅ Task deleted: {task_title}")
        return f"🗑️ Task deleted: {task_title}"
    
    def _complete_task(self, session: Session, user_id: int, message: str) -> str:
        """Complete task"""
        print("✅ Completing task...")
        
        tasks = session.exec(
            select(Task).where(Task.user_id == user_id)
        ).all()
        
        if not tasks:
            return "❌ No tasks found"
        
        # Extract task name
        msg = message.lower()
        for word in ["complete", "done", "finish", "mark", "as", "task"]:
            msg = msg.replace(word, "")
        title = msg.strip()
        
        if not title:
            return "❌ Please specify task to complete"
        
        # Find task
        matching_task = None
        for task in tasks:
            if title in task.title.lower() or task.title.lower() in title:
                matching_task = task
                break
        
        if not matching_task:
            return f"❌ Task '{title}' not found"
        
        # Mark completed
        task_title = matching_task.title
        matching_task.status = "completed"
        session.commit()
        
        print(f"✅ Task completed: {task_title}")
        return f"✅ Task completed: {task_title}"
    
    def _list_tasks(self, session: Session, user_id: int) -> str:
        """List tasks"""
        print("📋 Listing tasks...")
        
        tasks = session.exec(
            select(Task).where(Task.user_id == user_id)
        ).all()
        
        if not tasks:
            return "📝 No tasks yet. Add one to get started!"
        
        response = "📋 Your Tasks:\n\n"
        for task in tasks[:10]:
            status_emoji = {
                "pending": "⏳",
                "in_progress": "🔄",
                "completed": "✅"
            }.get(task.status, "📋")
            
            response += f"{status_emoji} {task.title}\n"
        
        if len(tasks) > 10:
            response += f"\n...and {len(tasks) - 10} more"
        
        return response
    
    def _general_chat(self, message: str, conversation_history: list) -> str:
        """General chat"""
        messages = [{"role": "system", "content": self.system_prompt}]
        
        for msg in conversation_history[-5:]:
            messages.append({
                "role": msg.get("role", "user"),
                "content": msg.get("content", "")
            })
        
        messages.append({"role": "user", "content": message})
        
        url = "https://api.groq.com/openai/v1/chat/completions"
        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 300
        }
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        try:
            resp = requests.post(url, json=payload, headers=headers, timeout=30)
            resp.raise_for_status()
            data = resp.json()
            return data["choices"][0]["message"]["content"]
        except Exception as e:
            return f"Sorry, error: {str(e)}"
    
    def _extract_task_title(self, message: str) -> str:
        """Extract clean task title"""
        title = message.lower()
        
        # Remove keywords
        for phrase in ["add task to", "create task to", "remind me to", "add task", "create task", "new task", "add", "create"]:
            title = title.replace(phrase, "")
        
        # Remove status/priority
        for word in ["on progress", "in progress", "high priority", "low priority", "completed", "pending"]:
            title = title.replace(word, "")
        
        # Clean quotes and spaces
        title = title.replace('"', '').replace("'", "")
        title = ' '.join(title.split())
        title = title.strip()
        
        # Capitalize
        if title:
            title = title[0].upper() + title[1:]
        else:
            title = "New Task"
        
        return title
    
    def _extract_status(self, message: str) -> str:
        """Extract status"""
        msg = message.lower()
        if "in progress" in msg or "on progress" in msg:
            return "in_progress"
        elif "completed" in msg:
            return "completed"
        return "pending"
    
    def _extract_priority(self, message: str) -> str:
        """Extract priority"""
        msg = message.lower()
        if "high priority" in msg or "urgent" in msg:
            return "high"
        elif "low priority" in msg:
            return "low"
        return "medium"
