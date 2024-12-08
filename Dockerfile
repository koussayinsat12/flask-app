FROM python:3.11-alpine
LABEL maintainer = "kousai.ghaouari@insat.ucar.tn"

COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["gunicorn --bind 0.0.0.0:8000 src.app:app"]
