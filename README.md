# ComfyUI CUDA 12.8 Docker Template

Dockerfile optimisé pour RunPod, GitHub Actions ou build local.  
Inclut ComfyUI + ComfyUI-Manager avec support complet CUDA 12.8 + PyTorch cu128 + SageAttention + Triton.

## ✅ Inclus

- Python 3.10 avec `pip3` système (pas de venv)
- ComfyUI installé depuis GitHub (`/opt/ComfyUI`)
- ComfyUI-Manager préintégré (si activé dans le repo)
- Support de :
  - `sageattention==1.0.6`
  - `triton==2.2.0`
  - `torch` via PyTorch cu128
  - `jupyterlab`, `safetensors`, `huggingface_hub`, etc.
- Prêt à déployer sur RunPod ou via `docker build .`

## 📦 Ports exposés

| Service     | Port  |
|-------------|-------|
| ComfyUI     | 8188  |
| JupyterLab  | 8888  |

## 🚀 Commande recommandée pour RunPod

**Arguments :**
```
--listen 0.0.0.0 --port 8188 --use-sage-attention
```

**Variables d’environnement RunPod (recommandées) :**
```env
COMFY_PORT=8188
ENABLE_JUPYTER=true
JUPYTER_PORT=8888
COMFY_PERSIST=true
POST_START_ENABLED=true
DATA_DIR=/workspace
COMFY_DIR=/opt/ComfyUI
COMFY_HOME=/workspace/ComfyUI
MODELS_DIR=/workspace/models
MODELS_MANIFEST=/workspace/models_manifest.txt
```

## 🛠 Build local (facultatif)
```bash
docker build -t comfy-cu128:v1 .
docker run -p 8188:8188 -p 8888:8888 comfy-cu128:v1
```

## ✅ Testé sur
- RunPod (Dockerfile from GitHub)
- GitHub Actions (buildx)
- GPU A100 / 4090 / H100