#!/bin/bash
# Pull ds4 GGUFs straight from HF into ~/ds4/gguf (same files download_model.sh would fetch).
set -u
cd "$HOME/ds4" || exit 1
mkdir -p gguf
export HF_HUB_ENABLE_HF_TRANSFER=1
pull() { # repo file
  echo "[$(date '+%H:%M:%S')] start $2"
  hf download "$1" "$2" --local-dir gguf >>/tmp/ds4_dl_hf.log 2>&1
  echo "[$(date '+%H:%M:%S')] rc=$? $2 $(stat -f %z "gguf/$2" 2>/dev/null) bytes"
}
pull antirez/deepseek-v4-gguf DeepSeek-V4-Flash-Vision-Encoder.gguf
pull antirez/deepseek-v4-gguf DeepSeek-V4-Flash-Vision-Exp-DSpark-support.gguf
pull antirez/deepseek-v4-gguf DeepSeek-V4-Flash-Vision-Exp-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8.gguf
pull antirez/glm-5.3-flash-gguf GLM-5.3-Flash-Q2.gguf
echo "ALL_DONE"
