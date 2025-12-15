#!/bin/bash
# build all dynamic parts of website

echo "===== changelog ====="
./changelog_build.sh

echo "===== linktree ====="
./linktree_build.sh

echo "===== sheffield ====="
(cd sheffield; ./build.sh)

echo "===== favourites ====="
(cd favourites; ./build.sh)

echo "===== bookmarks ====="
(cd bookmarks; ./build.sh)

echo ""
echo "done! 👹️"
