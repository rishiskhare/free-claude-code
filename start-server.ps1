$env:Path = "C:\Users\Administrator\.local\bin;$env:Path"
Set-Location "C:\Users\Administrator\Downloads\free-claude-code"
uv run uvicorn server:app --host 0.0.0.0 --port 8082
