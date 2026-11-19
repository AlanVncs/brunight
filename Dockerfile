# Use official Python 3.12 image
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the hybrid.sh script
COPY hybrid.sh .

# Create and activate virtual environment
RUN python3 -m venv .venv

# Upgrade pip, setuptools, wheel
RUN .venv/bin/pip install -U pip setuptools wheel

# Install audio-separator with GPU support and audioread
RUN .venv/bin/pip install "audio-separator[gpu]" audioread

# Make the script executable
RUN chmod +x hybrid.sh

# Create output directory
RUN mkdir -p output models

# Default to bash
CMD ["/bin/bash"]
