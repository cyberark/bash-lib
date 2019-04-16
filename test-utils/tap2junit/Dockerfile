FROM python:3.7-alpine
ENTRYPOINT python tap2junit.py
COPY requirements.txt constraints.txt tap2junit.py /
RUN pip install --no-cache-dir -r requirements.txt -c constraints.txt