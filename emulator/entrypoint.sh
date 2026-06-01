#!/bin/sh
set -e
/app/build.sh
exec node /app/serve.js
