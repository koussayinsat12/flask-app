# Use Python 3.9 base image
FROM python:3.9-alpine

# Set the maintainer label
LABEL maintainer="kousai.ghaouari@insat.ucar.tn"

# Set the working directory inside the container
WORKDIR /app

# Copy the app code into the working directory
COPY . /app

# Install required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 8000

# Set the entrypoint for the container to run gunicorn with the correct path
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "src.app:app"]

