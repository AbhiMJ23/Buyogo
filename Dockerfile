# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the entire current directory into the /app directory in the container
COPY . /app

# Combine all RUN commands into one to reduce image layers
RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser && \
    pip install --no-cache-dir -r requirements.txt && \
    chown -R appuser:appgroup /app

# Switch to the new user
USER appuser

# Expose the port on which the Flask app will run
EXPOSE 5000

# Set the environment variable for Flask
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Command to run the Flask application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]

