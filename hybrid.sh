#!/usr/bin/env bash
# Best-of-both pipeline.
# Usage: ./hybrid.sh <file>
#  Vocals                      <- vocal_clean  (least instrument bleed in the vocal)
#  Instrumental/Drums/Bass/Other <- vocal_full (fullest instrumental), then htdemucs_ft (shifts=4, overlap=0.5)
# Override presets with VOCAL_PRESET=... INST_PRESET=...
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
IN="$1"
VP="${VOCAL_PRESET:-vocal_clean}"
IP="${INST_PRESET:-vocal_full}"
B="$(basename "${IN%.*}")"
OUT="$D/output/$B-hybrid"
mkdir -p "$OUT/.v" "$OUT/.i" "$OUT/.d"
AS="$D/.venv/bin/audio-separator"
COMMON=(--model_file_dir "$D/models" --output_format FLAC)

"$AS" "$IN" --ensemble_preset "$VP" "${COMMON[@]}" --output_dir "$OUT/.v"
"$AS" "$IN" --ensemble_preset "$IP" "${COMMON[@]}" --output_dir "$OUT/.i"
INST="$(ls "$OUT"/.i/*Instrumental*.flac | head -1)"
"$AS" "$INST" --model_filename htdemucs_ft.yaml "${COMMON[@]}" --output_dir "$OUT/.d" \
  --demucs_shifts 4 --demucs_overlap 0.5

mv "$(ls "$OUT"/.v/*Vocals*.flac | head -1)" "$OUT/Vocals.flac"
mv "$INST" "$OUT/Instrumental.flac"
for s in Drums Bass Other; do mv "$OUT"/.d/*"($s)"*.flac "$OUT/$s.flac"; done
find "$OUT/.v" "$OUT/.i" "$OUT/.d" -type f -delete   # leftovers: clean's instrumental, demucs' vocal stem
rmdir "$OUT/.v" "$OUT/.i" "$OUT/.d"
echo "Vocals from $VP, instrumental stems from $IP:"
ls -1 "$OUT"
