#!/bin/bash
# Start DwarfStar (ds4) serving DeepSeek V4 Flash Vision-Exp q2 + DSpark on a 128 GB Mac.
# Frees RAM first: ds4 needs ~82 GiB resident. Adjust the kill list to your machine.
set -u
cd "$HOME/ds4" || exit 1

# 1) free unified memory (anything holding >1 GB will hurt)
brew services stop omlx 2>/dev/null
pkill -f "mlx_lm.server" 2>/dev/null
osascript -e 'quit app "LM Studio"' 2>/dev/null
sleep 2
vm_stat | awk '/Pages free/{f=$3}/Pages inactive/{i=$3}/Pages purgeable/{p=$3}END{printf "headroom before load: %.1f GB\n",(f+i+p)*16384/1073741824}'

# 2) serve
exec ./ds4-server \
  -m gguf/DeepSeek-V4-Flash-Vision-Exp-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8.gguf \
  --vision gguf/DeepSeek-V4-Flash-Vision-Encoder.gguf \
  --dspark --mtp-model gguf/DeepSeek-V4-Flash-Vision-Exp-DSpark-support.gguf \
  --ctx 32768 --host 0.0.0.0 --port 8000
