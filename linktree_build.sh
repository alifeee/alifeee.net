#!/bin/bash
# generate HTML from yaml,
#  then replace all lines between START_CONTENT and END_CONTENT with this HTML
#  in the file INDEX_FILE
#  and rewrite RSS_FILE
# requires jq and toml2json
#   https://github.com/woodruffw/toml2json/releases/tag/v1.3.2
#   https://github.com/jqlang/jq
# example:
#   ./linktree_build.sh

set -e
date >&2
LINKTREE="linktree.toml"
INDEX_FILE="index.html"
START_CONTENT="<!-- !!start linktree!! -->"
END_CONTENT="<!-- !!end linktree!! -->"

TEMP_FILE="/tmp/index29ut8ghj98i2j.html"

# check installed
if ! command -v jq >/dev/null 2>&1; then
    echo "jq could not be found" && exit 1
fi
if ! command -v toml2json >/dev/null 2>&1; then
    echo "toml2json could not be found (pip install toml2json)" && exit 1
fi

# parse
json=$(
  cat linktree.toml \
    | toml2json
)
nlinks=$(echo "${json}" | jq '.links | length')
echo "got ${nlinks} links from TOML" >&2

# create HTML
html=$(
  echo "${json}" | jq -r '
  .links | .[] | (
      if ((.icon == null) or (.icon == "")) then
        "icons/linktree/profile.svg"
      elif (.icon | startswith("http")) then
        .icon
      elif (.icon | startswith("/")) then
        "icons\(.icon)"
      else
        "icons/linktree/\(.icon).svg"
      end
    ) as $icon | (
      if ((.url == null) or (.url == "")) then
        "div"
      else
        "a"
      end
    ) as $a | (
    "<div>"
    + "<\($a) href=\"\(.url)\">"
    + "<img src=\"\($icon)\" alt=\"\(.icon) icon\">"
    + "<span>\(.name)</span>"
    + "</\($a)>"
    + "</div>"
  )'
)
nelements=$(echo "${html}" | wc -l)
echo "got ${nelements} parsed elements" >&2

# put into HTML
original_html=$(cat $INDEX_FILE)
# get line numbers of START_CONTENT and END_CONTENT
start=$(echo "${original_html}" | grep -n "${START_CONTENT}" | cut -d : -f1)
end=$(echo "${original_html}" | grep -n "${END_CONTENT}" | cut -d : -f1)
if [ -z $start ] || [ -z $end ]; then
  echo "could not find start/end content tags" >> /dev/stderr
  echo "start: <$start>, end: <$end>" >> /dev/stderr
  exit 1
fi
rm -f $TEMP_FILE
echo "${original_html}" | awk 'NR <= '"${start}"'' >> $TEMP_FILE
echo "${html}" >> $TEMP_FILE
echo "${original_html}" | awk 'NR >= '"${end}"'' >> $TEMP_FILE

cat $TEMP_FILE > $INDEX_FILE
rm -f $TEMP_FILE

echo "done! saved to ${INDEX_FILE} 🚀" >> /dev/stderr
