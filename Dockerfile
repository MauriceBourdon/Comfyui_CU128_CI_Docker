FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    git git-lfs curl ffmpeg \
    build-essential ninja-build \
    libgl1 libglib2.0-0 jq rsync aria2 tini && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install -U pip setuptools wheel packaging && \
    pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cu128 torch && \
    pip3 install --no-cache-dir jupyterlab==4.2.5 huggingface-hub==0.24.6 safetensors==0.4.5 pyyaml tqdm && \
    pip3 install --no-cache-dir --upgrade sageattention==1.0.6 triton==2.2.0

# Install ComfyUI
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI && \
    pip3 install --no-cache-dir -r /opt/ComfyUI/requirements.txt

EXPOSE 8188 8888
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "bash", "/entrypoint.sh"]
