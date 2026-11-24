# ROCm base: provides torch built for AMD GPUs (HIP) and the ROCm runtime.
FROM rocm/pytorch:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY hybrid.sh .

# Inherit the ROCm torch from the base image so pip does not replace it with a CPU/CUDA wheel.
RUN python3 -m venv --system-site-packages .venv \
    && .venv/bin/pip install -U pip setuptools wheel

# audio-separator pulls in CPU onnxruntime; replace it with the ROCm build.
RUN .venv/bin/pip install audio-separator audioread \
    && .venv/bin/pip uninstall -y onnxruntime \
    && .venv/bin/pip install "onnxruntime-rocm==1.22.2.post3"

RUN chmod +x hybrid.sh \
    && mkdir -p output models

CMD ["/bin/bash"]
