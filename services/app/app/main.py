from fastapi import FastAPI

app = FastAPI(version="0.1.0")

@app.get("/health", include_in_schema=False)
def health():
    return {"status": "ok"}
