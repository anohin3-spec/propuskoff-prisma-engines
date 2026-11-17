#!/bin/bash
set -euo pipefail
cd /var/www/propuskoff
mkdir -p prisma-engines
cd prisma-engines

download() {
  local url="$1" out="$2"
  echo "TRY $url"
  curl -L --fail --connect-timeout 20 --max-time 300 --progress-bar -o "$out" "$url"
}

# jsDelivr CDN first (often works when github.com is blocked)
BASE_JS="https://cdn.jsdelivr.net/gh/anohin3-spec/propuskoff-prisma-engines@main"
BASE_GH="https://github.com/anohin3-spec/propuskoff-prisma-engines/releases/download/v1"
BASE_NPM="https://registry.npmmirror.com/-/binary/prisma/all_commits/2ba551f319ab1df4bc874a89965d8b3641056773/debian-openssl-3.0.x"

if ! download "$BASE_JS/schema-engine.gz" schema-engine.gz; then
  if ! download "$BASE_GH/schema-engine.gz" schema-engine.gz; then
    download "$BASE_NPM/schema-engine.gz" schema-engine.gz
  fi
fi

if ! download "$BASE_JS/libquery_engine.so.node.gz" libquery_engine.so.node.gz; then
  if ! download "$BASE_GH/libquery_engine.so.node.gz" libquery_engine.so.node.gz; then
    download "$BASE_NPM/libquery_engine.so.node.gz" libquery_engine.so.node.gz
  fi
fi

gunzip -f schema-engine.gz
gunzip -f libquery_engine.so.node.gz
chmod +x schema-engine libquery_engine.so.node
mkdir -p ../node_modules/@prisma/engines
cp -f schema-engine ../node_modules/@prisma/engines/schema-engine
cp -f libquery_engine.so.node ../node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node
chmod +x ../node_modules/@prisma/engines/schema-engine ../node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node
export PRISMA_QUERY_ENGINE_LIBRARY="/var/www/propuskoff/node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node"
export PRISMA_SCHEMA_ENGINE_BINARY="/var/www/propuskoff/node_modules/@prisma/engines/schema-engine"
export PRISMA_ENGINES_CHECKSUM_IGNORE=1
cd /var/www/propuskoff
./node_modules/.bin/prisma generate
echo "OK: prisma generate done"
ls -la node_modules/.prisma/client/index.js
