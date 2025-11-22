FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy function code and dependencies
COPY main.py .

# Use functions-framework to run the function
ENV PORT=8080
CMD exec functions-framework --target=bb --port=$PORT
