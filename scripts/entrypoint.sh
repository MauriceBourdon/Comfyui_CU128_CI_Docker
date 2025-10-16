#!/usr/bin/env bash
set -euo pipefail
export PATH="/venv/bin:$PATH"

DATA_DIR="${DATA_DIR:-/workspace}"
SEED_DIR="/opt/ComfyUI"
COMFY_PERSIST="${COMFY_PERSIST:-true}"
COMFY_HOME="${COMFY_HOME:-/workspace/ComfyUI}"
COMFY_DIR="${COMFY_DIR:-/opt/ComfyUI}"
MODELS_DIR="${MODELS_DIR:-/workspace/models}"
MODELS_MANIFEST="${MODELS_MANIFEST:-/workspace/models_manifest.txt}"
POST_START_ENABLED="${POST_START_ENABLED:-true}"

# Persist mode
if [[ "${COMFY_PERSIST}" == "true" ]]; then
  if [[ ! -d "${COMFY_HOME}/.bootstrapped" ]]; then
    mkdir -p "${COMFY_HOME}"
    rsync -a --delete "${SEED_DIR}/" "${COMFY_HOME}/"
    mkdir -p "${COMFY_HOME}/.bootstrapped"
  fi
  export COMFY_DIR="${COMFY_HOME}"
  echo "[comfy] mode = PERSIST (COMFY_DIR=${COMFY_DIR})"
else
  echo "[comfy] mode = IMAGE   (COMFY_DIR=${COMFY_DIR})"
fi

# Dirs
mkdir -p "${DATA_DIR}" "${MODELS_DIR}"/DWPose "${MODELS_DIR}"/GFPGAN "${MODELS_DIR}"/LLM "${MODELS_DIR}"/Moge "${MODELS_DIR}"/RealESRGAN "${MODELS_DIR}"/animatediff_models "${MODELS_DIR}"/animatediff_motion_lora "${MODELS_DIR}"/aurasr "${MODELS_DIR}"/checkpoints "${MODELS_DIR}"/clip_vision "${MODELS_DIR}"/depthanything "${MODELS_DIR}"/detection "${MODELS_DIR}"/diffusers "${MODELS_DIR}"/diffusion_models "${MODELS_DIR}"/embeddings "${MODELS_DIR}"/facedetection "${MODELS_DIR}"/facerestore_models "${MODELS_DIR}"/gligen "${MODELS_DIR}"/grounding-dino "${MODELS_DIR}"/hypernetworks "${MODELS_DIR}"/inpaint "${MODELS_DIR}"/insightface "${MODELS_DIR}"/ipadapter "${MODELS_DIR}"/liveportrait "${MODELS_DIR}"/loras "${MODELS_DIR}"/mmaudio "${MODELS_DIR}"/mmdets "${MODELS_DIR}"/model_patches "${MODELS_DIR}"/onnx "${MODELS_DIR}"/openpose "${MODELS_DIR}"/openunmix "${MODELS_DIR}"/photomaker "${MODELS_DIR}"/rembg "${MODELS_DIR}"/sam2 "${MODELS_DIR}"/sams "${MODELS_DIR}"/style_models "${MODELS_DIR}"/text_encoders "${MODELS_DIR}"/ultralytics "${MODELS_DIR}"/unet "${MODELS_DIR}"/upscale_models "${MODELS_DIR}"/vae "${MODELS_DIR}"/vae_approx
mkdir -p "${COMFY_DIR}/user/default/workflows" "${COMFY_DIR}/input" "${COMFY_DIR}/output"

# extra_model_paths.yaml
cat >"${COMFY_DIR}/extra_model_paths.yaml" <<'YAML'
models:
  DWPose: /workspace/models/DWPose
  GFPGAN: /workspace/models/GFPGAN
  LLM: /workspace/models/LLM
  Moge: /workspace/models/Moge
  RealESRGAN: /workspace/models/RealESRGAN
  animatediff_models: /workspace/models/animatediff_models
  animatediff_motion_lora: /workspace/models/animatediff_motion_lora
  aurasr: /workspace/models/aurasr
  checkpoints: /workspace/models/checkpoints
  clip: /workspace/models/clip
  clip_vision: /workspace/models/clip_vision
  controlnet: /workspace/models/controlnet
  depthanything: /workspace/models/depthanything
  detection: /workspace/models/detection
  diffusers: /workspace/models/diffusers
  diffusion_models: /workspace/models/diffusion_models
  embeddings: /workspace/models/embeddings
  facedetection: /workspace/models/facedetection
  facerestore_models: /workspace/models/facerestore_models
  gligen: /workspace/models/gligen
  grounding-dino: /workspace/models/grounding-dino
  hypernetworks: /workspace/models/hypernetworks
  inpaint: /workspace/models/inpaint
  insightface: /workspace/models/insightface
  ipadapter: /workspace/models/ipadapter
  liveportrait: /workspace/models/liveportrait
  loras: /workspace/models/loras
  mmaudio: /workspace/models/mmaudio
  mmdets: /workspace/models/mmdets
  model_patches: /workspace/models/model_patches
  onnx: /workspace/models/onnx
  openpose: /workspace/models/openpose
  openunmix: /workspace/models/openunmix
  photomaker: /workspace/models/photomaker
  rembg: /workspace/models/rembg
  sam2: /workspace/models/sam2
  sams: /workspace/models/sams
  style_models: /workspace/models/style_models
  text_encoders: /workspace/models/text_encoders
  ultralytics: /workspace/models/ultralytics
  unet: /workspace/models/unet
  upscale_models: /workspace/models/upscale_models
  vae: /workspace/models/vae
  vae_approx: /workspace/models/vae_approx
YAML

# Symlinks (avoid self-link in persist mode)
safe_link() {
  local link="$1" target="$2"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    mv "$link" "${link}.bak.$(date +%s)"
  fi
  ln -sfnT "$target" "$link"
}
# Only create /workspace/ComfyUI -> COMFY_DIR when NOT in persist mode
if [[ "${COMFY_PERSIST}" != "true" ]]; then
  safe_link "${DATA_DIR}/ComfyUI" "${COMFY_DIR}"
fi
safe_link "${COMFY_DIR}/models"   "${MODELS_DIR}"
safe_link "${DATA_DIR}/workflows" "${COMFY_DIR}/user/default/workflows"
safe_link "${DATA_DIR}/input"     "${COMFY_DIR}/input"
safe_link "${DATA_DIR}/output"    "${COMFY_DIR}/output"

# Seed manifests / hooks
if [[ ! -f "${MODELS_MANIFEST}" && -f "/manifests/models_manifest.txt" ]]; then
  cp -n "/manifests/models_manifest.txt" "${MODELS_MANIFEST}"
fi
POST_DIR="${POST_START_DIR:-/workspace/post_start.d}"
if [[ ! -d "$POST_DIR" && -d "/manifests/post_start.d" ]]; then
  mkdir -p "$POST_DIR"
  cp -n /manifests/post_start.d/*.sh "$POST_DIR" 2>/dev/null || true
fi

# Post-start hooks (toggle)
disable_rx='^(false|0|no|off)$'
if [[ "${POST_START_ENABLED}" =~ $disable_rx ]]; then
  echo "[post-start] disabled by POST_START_ENABLED=${POST_START_ENABLED}"
else
  POST_SH="${POST_START_SCRIPT:-/workspace/post_start.sh}"
  if [[ -f "$POST_SH" ]]; then
    echo "[post-start] Run $POST_SH"
    bash "$POST_SH" >> "${DATA_DIR}/post_start.log" 2>&1 || true
  fi
  if [[ -d "$POST_DIR" ]]; then
    for f in "$POST_DIR"/*.sh; do
      [[ -f "$f" ]] || continue
      echo "[post-start] Run $f"
      bash "$f" >> "${DATA_DIR}/post_start.log" 2>&1 || true
    done
  fi
fi

# Jupyter
if [[ "${ENABLE_JUPYTER:-true}" == "true" ]]; then
  nohup /usr/local/bin/start-jupyter > "${DATA_DIR}/jupyter.log" 2>&1 &
fi

# Model downloads (async)
if [[ -f "${MODELS_MANIFEST}" ]]; then
  nohup bash /scripts/download_models_async.sh \
    "${MODELS_MANIFEST}" "${MODELS_DIR}" \
    > "${DATA_DIR}/models_download.log" 2>&1 &
fi

# Start ComfyUI
exec /usr/local/bin/start-comfyui