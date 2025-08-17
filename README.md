# ComfyUI V6.2.1 (CUDA 12.8) — Symlink fix
- Fix boucle de symlink en mode PERSIST (pas de lien /workspace/ComfyUI -> COMFY_DIR).
- SageAttention construit au runtime (SAGEATTENTION_BUILD=true).
- Manifeste de modèles éditable + pull-models.
- Jupyter optionnel.

ENV typiques (RunPod):
COMFY_PERSIST=true
COMFY_HOME=/workspace/ComfyUI
COMFY_DIR=/opt/ComfyUI
POST_START_ENABLED=true
DATA_DIR=/workspace
MODELS_DIR=/workspace/models
MODELS_MANIFEST=/workspace/models_manifest.txt
ENABLE_JUPYTER=true
JUPYTER_PORT=8888
COMFY_AUTOSTART=true
COMFY_PORT=8188
COMFY_ARGS=--listen 0.0.0.0 --port 8188 --use-sage-attention
SAGEATTENTION_BUILD=true
