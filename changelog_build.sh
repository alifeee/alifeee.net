#!/bin/bash
# generate HTML and RSS from markdown,
#  then replace all lines between START_CONTENT and END_CONTENT with this HTML
#  in the file INDEX_FILE
#  and rewrite RSS_FILE
# requires python markdown extension
#  pip3 install --user markdown
#  example:
#    python3 -m markdown -x def_list images.md
# usage:
#  ./changelog_build.sh
# changelog should look like a markdown definition-list file with
#   dates followed by definitions, separated by a blank line, like:
# 
# ```md
# 2025-02-09
# : changed this thing
# 
# 2025-02-09 09:15
# : changed this other thing, see [link](./page.html)
# ```

CHANGELOG="changelog.md"

INDEX_FILE="index.html"
START_CONTENT="<!-- !!start changelog!! -->"
END_CONTENT="<!-- !!end changelog!! -->"

RSS_FILE="changelog.xml"

TEMP_FILE="/tmp/index8912utgj.html"

set -e

date >> /dev/stderr

# check markdown is installed
python3 -c "import markdown" && echo "python markdown is instaled!" > /dev/stderr || (echo "markdown not installed, run: pip3 install --user markdown" && exit 1)

# if there are any triple-new-lines, this script probably breaks
bad=$((cat changelog.md; echo; echo) | awk 'n>1 {print "oh no"} /^$/ {n+=1; next;} {n=0}')
[[ -n "${bad}" ]] && (echo "triple newline spotted! get rid!" >> /dev/stderr && exit 1)
# if there is no final newline, it breaks too also, but we can just add that ourselves
bad=$((cat changelog.md; echo) | awk '/^$/ {a=1;next} {a=2} END {if (a==2) {print "bad"}}')
[[ -n "${bad}" ]] && (echo "no terminating newline! adding one..." >> /dev/stderr && echo "" >> "${CHANGELOG}")

original_html=$(cat $INDEX_FILE)

# 1. reverse with tac
# 2. turn into markdown with markdown
# 3. add ids to <dt> tags with awk
html=$((cat "${CHANGELOG}"; echo) | tac -s $'\n\n' | python3 -m markdown -x def_list | awk -F '>|<' '/<dt>.*<\/dt>/ {printf "<dt id=\"%s\">%s</dt>\n", $3, $3; next} {print}')

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





echo "generating RSS from changelog" >> /dev/stderr
reverse_cl=$((cat "${CHANGELOG}"; echo) | tac -s $'\n\n')

printf "" > $RSS_FILE

last_date_str=$(echo "${reverse_cl}" | head -n1)
last_date_rfc3339=$(date --date="${last_date_str}" --rfc-3339="seconds" | sed 's/ /T/')

cat >> $RSS_FILE << EOF
<?xml version='1.0' encoding='UTF-8'?>
<?xml-stylesheet href="/feed.xsl" type="text/xsl"?>
<feed xmlns="http://www.w3.org/2005/Atom">

<title>alifeee's website changelog</title>
<link href='https://alifeee.net/changelog.xml' rel='self' />
<updated>${last_date_rfc3339}</updated>
<author>
  <name>alifeee</name>
</author>
<id>https://alifeee.net/</id>
<icon>https://alifeee.net/profile-picture.png</icon>
EOF

printf "<entry>" >> $RSS_FILE
while read -r line; do
  if [[ "${line}" =~ ^[0-9]{4}- ]]; then
    date_rfc3339=$(date --date="${line}" --rfc-3339="seconds" | sed 's/ /T/')
    date_str=$(echo "${line}")
    date_esc=$(echo "${line}" | sed 's/ /%20/g')

    cat >> $RSS_FILE << EOF

    <title>update ${date_str}</title>
    <link href="https://alifeee.net/#${date_esc}" />
    <id>https://alifeee.net/#${date_esc}</id>
    <updated>${date_rfc3339}</updated>
    <summary>
EOF
  elif [[ "${line}" =~ ^$ ]]; then
    echo "  </summary>" >> $RSS_FILE
    echo "</entry>" >> $RSS_FILE
    printf "<entry>" >> $RSS_FILE
  else
    echo "${line}" | sed 's/^: //' \
      | python3 -c 'import sys;from html import escape;print(escape(sys.stdin.read()),end="")' \
      >> $RSS_FILE
  fi
done <<< "${reverse_cl}"
echo "    </summary>" >> $RSS_FILE
echo "  </entry>" >> $RSS_FILE
echo "</feed>" >> $RSS_FILE

echo "rss done! saved to ${RSS_FILE} 🚀" >> /dev/stderr

