#!/bin/bash
# VERSION: 1.3

TEST_MODE=false
FFMPEG_LIMIT=""

show_help() {
  echo "Usage: ./$(basename "$0") [OPTIONS] INPUT_FILE"
  echo ""
  echo "Options:"
  echo "  -t, --test    Encode only the first 30 seconds for testing."
  echo "  -h, --help    Show this help message."
  echo ""
  echo "Example:"
  echo "  ./$(basename "$0") -t my_video.mp4"
  exit 0
}

while getopts "th" opt; do
  case ${opt} in
    t )
      TEST_MODE=true
      FFMPEG_LIMIT="-ss 00:00:00 -t 00:00:30"
      ;;
    h )
      show_help
      ;;
    \? )
      echo "Invalid option. Use -h for help."
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

INPUT="$1"

if [ -z "$INPUT" ]; then
  echo "❌ Error: Video file is missing."
  echo "Use -h for help."
  exit 1
fi

DIRNAME="$(dirname "$INPUT")"
BASENAME="$(basename "$INPUT")"
FILENAME="${BASENAME%.*}"

TEMP="${DIRNAME}/${FILENAME}_temp.mp4"
TIMESTAMP=$(date +"%Y%m%d_%H%M")

SUFFIX="_HDR_vdtb_v1"
[ "$TEST_MODE" = true ] && SUFFIX="_TEST_30s_HDR"
OUTPUT="${DIRNAME}/${FILENAME}${SUFFIX}_${TIMESTAMP}.mp4"

if [ "$TEST_MODE" = true ]; then
    echo "🧪 TEST MODE ENABLED (30 seconds limit)"
fi

echo "▶️ 1. step: HW encode (VideoToolbox)..."

ffmpeg $FFMPEG_LIMIT -y -i "$INPUT" \
-c:v hevc_videotoolbox \
-profile:v main10 \
-tag:v hvc1 \
-b:v 25M \
-c:a copy \
"$TEMP"

echo "▶️ 2. step: HDR metadata"

ffmpeg -y -i "$TEMP" \
-c copy \
-metadata comment="Script Version: v1.3 (VideoToolbox|5-fix-encoding-for-yt)" \
-color_primaries bt2020 \
-color_trc smpte2084 \
-colorspace bt2020nc \
"$OUTPUT"

rm "$TEMP"

echo "✅ Done: $OUTPUT"