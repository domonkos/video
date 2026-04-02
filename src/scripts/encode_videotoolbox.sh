#!/bin/bash
# VERSION: 1.1
INPUT="$1"

if [ -z "$INPUT" ]; then
  echo "Video file is missing"
  exit 1
fi

DIRNAME="$(dirname "$INPUT")"
BASENAME="$(basename "$INPUT")"
FILENAME="${BASENAME%.*}"

TEMP="${DIRNAME}/${FILENAME}_temp.mp4"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
OUTPUT="${DIRNAME}/${FILENAME}_HDR_vdtb_v1_${TIMESTAMP}.mp4"

echo "▶️ 1. step: HW encode (VideoToolbox)..."

ffmpeg -ss 00:00:00 -t 00:00:30 -y -i "$INPUT" \
-c:v hevc_videotoolbox \
-profile:v main10 \
-q:v 70 \
-tag:v hvc1 \
-c:a copy \
"$TEMP"

echo "▶️ 2. step: HDR metadata"

ffmpeg -y -i "$TEMP" \
-c copy \
-metadata comment="Script Version: v1.1 (VideoToolbox)" \
-color_primaries bt2020 \
-color_trc smpte2084 \
-colorspace bt2020nc \
"$OUTPUT"

rm "$TEMP"

echo "✅ Done: $OUTPUT"