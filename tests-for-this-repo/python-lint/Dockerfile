FROM python:3.7-alpine

COPY requirements.txt .
COPY constraints.txt .
RUN pip install --no-cache-dir -r requirements.txt -c constraints.txt
VOLUME ["/mnt"]
WORKDIR /mnt
ENTRYPOINT pytest --flake8 --junit-xml junit.xml