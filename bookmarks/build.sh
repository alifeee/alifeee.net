#!/bin/bash
# build bookmarks.json
# build index.html

echo "building bookmarks.json" 2>&1
cat bookmark_folders.txt | xargs -d '\n' python3 read_bookmarks.py -f

echo "building index.html" 2>&1
python3 generate_html.py
