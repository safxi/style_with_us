@echo off
set DATABASE_URL=sqlite:///./test.db
venv_win\Scripts\uvicorn app.main:app --reload --port 8000
