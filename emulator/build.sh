#!/bin/sh
set -e

SRC=/channel
WORK=/tmp/channel
OUT=/public/channel.zip

rm -rf "$WORK"
mkdir -p "$WORK"
cp -r "$SRC/manifest" "$SRC/source" "$SRC/components" "$SRC/images" "$WORK/"

# If the channel has no jsonUrl, point it at the sample data so there's something to render.
if grep -q 'jsonUrl: ""' "$WORK/components/constants.brs" 2>/dev/null; then
  sed -i 's#jsonUrl: ""#jsonUrl: "http://localhost:6502/movies.json"#' \
      "$WORK/components/constants.brs"
fi

rm -f "$OUT"
( cd "$WORK" && zip -r -q -X "$OUT" manifest source components images \
    -x '*/.*' -x '*.pkg' )
echo "[build] channel.zip -> $(du -h "$OUT" | cut -f1)"
