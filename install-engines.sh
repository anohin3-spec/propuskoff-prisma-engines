#!/bin/bash
set -euo pipefail
cd /var/www/propuskoff
mkdir -p prisma-engines
cd prisma-engines
BASE="https://github.com/anohin3-spec/propuskoff-prisma-engines/releases/download/v1"
curl -L --fail --progress-bar -o schema-engine.gz "$BASE/schema-engine.gz"
curl -L --fail --progress-bar -o libquery_engine.so.node.gz "$BASE/libquery_engine.so.node.gz"
gunzip -f schema-engine.gz
gunzip -f libquery_engine.so.node.gz
chmod +x schema-engine libquery_engine.so.node
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
