# =========================================================
# ComfyUI + Jupyter (CUDA 12.8, Ubuntu 22.04)
# =========================================================
FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu22.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Bash + pipefail pour des RUN plus fiables
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ---------------------------------------------------------
# 🌍 Envs de base (placés tôt pour être utilisables dans RUN)
# ---------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PATH="/venv/bin:$PATH" \
    # Dossiers & apps
    DATA_DIR=/workspace \
    COMFY_DIR=/opt/ComfyUI \
    MODELS_DIR=/workspace/models \
    MODELS_MANIFEST=/workspace/models_manifest.txt \
    # Services
    ENABLE_JUPYTER=true \
    JUPYTER_PORT=8888 \
    COMFY_AUTOSTART=true \
    COMFY_PORT=8188 \
    COMFY_ARGS="--listen 0.0.0.0 --port 8188 --use-sage-attention" \
    # Pip cache persistant (utile sur RunPod/volumes)
    PIP_CACHE_DIR=/workspace/.pip-cache \
    PIP_NO_CACHE_DIR=0

# --------------------------
# 🔧 Paquets système
# --------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash git git-lfs curl ca-certificates ffmpeg \
      python3 python3-venv python3-pip \
      tini libgl1 libglib2.0-0 jq rsync aria2 \
      build-essential ninja-build python3-dev; \
    git lfs install; \
    rm -rf /var/lib/apt/lists/*

# --------------------------
# 🐍 Python + venv + Torch cu128
# --------------------------

RUN python3 -m venv /venv && \
    /venv/bin/python -m pip install -U pip setuptools wheel packaging && \
    /venv/bin/python -m pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cu128 torch torchvision torchaudio && \
    /venv/bin/python -m pip install --no-cache-dir jupyterlab==4.2.5 huggingface-hub==0.24.6 safetensors==0.4.5 pyyaml tqdm && \
    /venv/bin/python -m pip install --no-cache-dir --upgrade triton==3.5.0 sageattention==1.0.6

# --------------------------
# 🚀 ComfyUI + requirements
# --------------------------
RUN set -eux; \
    git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git "${COMFY_DIR}"; \
    /venv/bin/pip install --no-cache-dir -r "${COMFY_DIR}/requirements.txt"

# --------------------------
# 🧩 ComfyUI-Manager (fallback propre) + reqs
# --------------------------
RUN set -eux; \
  if git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git "${COMFY_DIR}/custom_nodes/ComfyUI-Manager" 2>/dev/null; then \
    echo "Cloned Comfy-Org/ComfyUI-Manager"; \
  else \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Manager.git "${COMFY_DIR}/custom_nodes/ComfyUI-Manager"; \
  fi; \
  if [ -f "${COMFY_DIR}/custom_nodes/ComfyUI-Manager/requirements.txt" ]; then \
    /venv/bin/pip install --no-cache-dir -r "${COMFY_DIR}/custom_nodes/ComfyUI-Manager/requirements.txt"; \
  fi

# --------------------------
# 🗂️ Workspace + symlink models
# --------------------------
RUN set -eux; \
    mkdir -p "${DATA_DIR}" "${MODELS_DIR}"; \
    if [ ! -e "${COMFY_DIR}/models" ]; then ln -s "${MODELS_DIR}" "${COMFY_DIR}/models"; fi

# --------------------------
# 🧰 Scripts + Entrypoints
# --------------------------
RUN mkdir -p /scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/download_models_async.sh /scripts/download_models_async.sh
COPY scripts/download_models_worker.py /scripts/download_models_worker.py

COPY bin/start-comfyui /usr/local/bin/start-comfyui
COPY bin/start-jupyter /usr/local/bin/start-jupyter
COPY bin/pull-models /usr/local/bin/pull-models

COPY manifests/ /manifests/

RUN chmod +x /entrypoint.sh /scripts/download_models_async.sh \
    /usr/local/bin/start-comfyui /usr/local/bin/start-jupyter /usr/local/bin/pull-models

# --------------------------
# 🔓 Réseaux + Workdir + Entrypoint
# --------------------------
EXPOSE 8188 8888
WORKDIR ${COMFY_DIR}
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "bash", "/entrypoint.sh"]