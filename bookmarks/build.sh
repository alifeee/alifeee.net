#!/bin/bash
# build bookmarks.json
# build index.html

echo "not updating bookmarks… do this manually" 2>&1

echo "building index.html" 2>&1
python3 generate_html.py
