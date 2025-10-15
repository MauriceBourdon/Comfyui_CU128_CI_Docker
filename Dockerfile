FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu22.04

# Install Python + pip + deps
RUN apt-get update && apt-get install -y --no-install-recommends \
RUN pip3 install -U pip setuptools wheel packaging && \
    pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cu128 torch && \

EXPOSE 8188 8888

RUN pip3 install -U pip setuptools wheel packaging && \
    pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cu128 torch && \



# Python env + PyTorch cu128



# Scripts & manifests
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/download_models_async.sh /scripts/download_models_async.sh
COPY scripts/download_models_worker.py /scripts/download_models_worker.py
COPY bin/start-comfyui /usr/local/bin/start-comfyui
COPY bin/start-jupyter /usr/local/bin/start-jupyter
COPY bin/pull-models /usr/local/bin/pull-models
COPY bin/comfy-save /usr/local/bin/comfy-save
COPY bin/comfy-update /usr/local/bin/comfy-update
COPY bin/comfy-reset /usr/local/bin/comfy-reset
COPY bin/comfy-notes /usr/local/bin/comfy-notes
COPY bin/comfy-replay /usr/local/bin/comfy-replay
COPY manifests/ /manifests/

RUN chmod +x /entrypoint.sh /scripts/download_models_async.sh /scripts/download_models_worker.py             /usr/local/bin/start-comfyui /usr/local/bin/start-jupyter             /usr/local/bin/pull-models /usr/local/bin/comfy-save             /usr/local/bin/comfy-update /usr/local/bin/comfy-reset             /usr/local/bin/comfy-notes /usr/local/bin/comfy-replay
RUN pip3 install -U pip setuptools wheel packaging && \
    pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cu128 torch && \

# Defaults

EXPOSE 8188 8888
ENTRYPOINT ["/usr/bin/tini","-s","--","bash","/entrypoint.sh"]
