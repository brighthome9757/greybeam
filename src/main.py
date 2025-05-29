from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routes.query import router as query_router

app = FastAPI(
    title="SQL Query Transpilation API",
    description="API for transpiling SQL queries between different dialects",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(query_router)

@app.get("/")
async def root():
    return {"message": "Welcome to the SQL Query Transpilation API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
