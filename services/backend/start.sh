#!/bin/sh
#installs deps each boot, bit slow but keeps us dockerfile-free
# terraform alone can run the show
set -e

#psycopg provides postgres driver, installing here avoids managing requirements.txt
pip install --no-cache-dir "psycopg[binary]==3.1.18"

#once deps are ready, hand off to stdlib HTTP server
exec python /app/app.py
