# ComfyUI CU128 Docker Template

Template Docker complet pour ComfyUI (CUDA 12.8, PyTorch cu128, multi-dossiers de modèles, ComfyUI-Manager, Jupyter, etc.)

## ✅ Inclus
- ComfyUI avec `--use-sage-attention`
- Manager de nodes custom (`ComfyUI-Manager`)
- Support complet des sous-dossiers `models/`
- Synchronisation des workflows entre ComfyUI et `/workspace/workflows`
- Scripts CLI (`bin/`) pour :
  - `comfy-save`, `comfy-update`, `comfy-reset`
  - `pull-models`, `comfy-notes`, `comfy-replay`
- JupyterLab activé (port 8888)

## 🚀 Usage avec RunPod
1. **Mode GitHub (recommandé)** :
   - Source: GitHub Repo
   - Dockerfile path: `Dockerfile`

2. **Mode Docker Hub (optionnel)** :
   ```bash
   docker build -t yourname/comfyui-cu128:latest .
   docker push yourname/comfyui-cu128:latest
   ```

## 📂 Arborescence
```
.
├── Dockerfile
├── README.md
├── .gitignore
├── bin/
├── scripts/
├── manifests/
└── .github/
```

## 🧠 Variables importantes
- `COMFY_DIR`, `COMFY_HOME`, `DATA_DIR`
- `MODELS_MANIFEST=/workspace/models_manifest.txt`
- `COMFY_ARGS=--listen 0.0.0.0 --port 8188 --use-sage-attention`