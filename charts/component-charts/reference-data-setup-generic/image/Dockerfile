FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY reference_data_extractor.py reference_data_extractor.py
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["python", "./reference_data_extractor.py"]