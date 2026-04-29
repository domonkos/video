# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Shell script to convert Xbox Game DVR clips into YouTube-compatible 4K HDR video using Apple's VideoToolbox hardware encoder on macOS.

## Usage

```bash
# Full encode
./src/scripts/encode_videotoolbox.sh INPUT_FILE

# Test encode (first 30 seconds only)
./src/scripts/encode_videotoolbox.sh -t INPUT_FILE
```

## How the script works

The encoding is a two-step pipeline:

1. **HW encode** — re-encodes the video using `hevc_videotoolbox` (Apple Silicon/AMD GPU), targeting HEVC Main10 profile at 25 Mbps, audio copied as-is, written to a temp file.
2. **HDR metadata** — passes the temp file through `ffmpeg -c copy` to inject BT.2020/PQ color metadata (`bt2020`, `smpte2084`, `bt2020nc`) and a version comment, then removes the temp file.

Output filename format: `<input_dir>/<input_name><SUFFIX>_<YYYYMMDD_HHMM>.mp4`
- Normal: `_HDR_vdtb_v1_<timestamp>.mp4`
- Test: `_TEST_30s_HDR_<timestamp>.mp4`

## Script versioning

The script version is tracked in two places and must be kept in sync when bumping:
- Comment at the top: `# VERSION: x.x`
- Metadata string in the ffmpeg command: `"Script Version: vx.x (VideoToolbox|<branch>)"`

## Dependencies

- `ffmpeg` with `hevc_videotoolbox` support (macOS only — requires Apple hardware encoder)
