#!/bin/sh
#installs deps each boot, bit slow but keeps us dockerfile-free
# terraform alone can run the show
set -e

#psycopg provides postgres driver, installing here avoids managing requirements.txt
#echo "installing psycopg..."  #debug
pip install --no-cache-dir "psycopg[binary]==3.1.18"

#once deps are ready, hand off to stdlib HTTP server
#might need to add error handling here but seems to work
exec python /app/app.py
