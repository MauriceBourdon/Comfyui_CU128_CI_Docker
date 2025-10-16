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

# Install ComfyUI
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip3 install --no-cache-dir -r /opt/ComfyUI/requirements.txt

EXPOSE 8188 8888

# Copy entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Copy bin scripts into /usr/local/bin
COPY bin/start-comfyui /usr/local/bin/start-comfyui
COPY bin/start-jupyter /usr/local/bin/start-jupyter
COPY bin/pull-models /usr/local/bin/pull-models
COPY bin/comfy-save /usr/local/bin/comfy-save
COPY bin/comfy-update /usr/local/bin/comfy-update
COPY bin/comfy-reset /usr/local/bin/comfy-reset
COPY bin/comfy-notes /usr/local/bin/comfy-notes
COPY bin/comfy-replay /usr/local/bin/comfy-replay
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/bin/tini", "-s", "--", "bash", "/entrypoint.sh"]
