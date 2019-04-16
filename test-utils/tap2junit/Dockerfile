FROM python:3.7-alpine

COPY requirements.txt .
COPY constraints.txt .
COPY tap2junit.py .
RUN pip install --no-cache-dir -r requirements.txt -c constraints.txt
ENTRYPOINT python tap2junit.py