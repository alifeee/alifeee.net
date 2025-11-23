# Mubi lists

From <https://mubi.com/en/lists/edgar-wrights-favorite-movies>, which is annoyingly paginated.

## download

have to do it in batches to not override the API

```bash
# manual entry variables
LIST_URL="https://mubi.com/en/lists/edgar-wrights-favorite-movies"
FILMS=1000
FOLDER="edgar-wrights-favorite-movies"
TITLE="Edgar Wright's 1000 Favorite Movies"
PREAMBLE='<p>This list of personal favorites was assembled by Edgar Wright and myself in July 2016. Films are in chronological order.</p>
<p>Note from Edgar:</p>
<p>“This is a personal and subjective list of 1000 favourite movies from 100 years of cinema. It’s not a set text or intended as any bible of ‘greatest’ films. I decided to put this together as a fluid list for my own enjoyment, amusement and reference. I hope it’s fun for you to pore over and dive into some of the films you haven’t seen or haven’t heard of.</p>
<p>Don’t get all riled up about omissions or which movies you think should be favourites of mine, the truth is I may very well like / not like or not have seen the movies you think are missing. In fact, I like way more than 1000 movies, but any longer and this list would be really insane.</p>
<p>Thanks to Sam DiSalle for helping me put it together. If you feel so inspired, make your own list. Film watching is a life time pursuit and there’s many more films out there for me to see. This site is a great place to start."</p>
<p>Edgar Wright, Aug 2016.</p>'

# mostly automated from here
mkdir -p "${FOLDER}"
LIST_SLUG="${LIST_URL##*/}"
# must add e.g.,   ?page=5&per_page=100
LIST_API_URL="https://api.mubi.com/v4/lists/${LIST_SLUG}/list_films"
html=$(
  curl "${LIST_URL}"
)
# HTML escape
alias normalise='python3 -c "import sys;from html import unescape;print(unescape(sys.stdin.read()).strip(),end=\"\")"'
title=$(
  echo "${html}" \
    | hxnormalize -x -l 240 \
    | hxselect -c h1 \
    | normalise
)
preamble=$(
  echo "${html}" \
    | hxnormalize -x -l 240 \
    | hxselect -c '.css-1ibjfe9.edzcd40 > *' \
    | normalise
)
PER_PAGE="100"
TOTAL_PAGES=$(( ($FILMS - 1) / 100 + 1 ))
# download batches
for i in `seq 1 $TOTAL_PAGES`; do
  fn="${FOLDER}/films_$(( ($i - 1) * $PER_PAGE + 1 ))-$(( $i * $PER_PAGE)).json"
  echo "saving ${fn}"
  http_code=$(
    curl \
     -H 'CLIENT: web' \
     -H 'Client-Country: GB' \
     -w "%{http_code}" \
     -o /tmp/298jtj2.json \
     "${LIST_API_URL}?page=$i&per_page=${PER_PAGE}"
  )
  if [[ "${http_code}" != "200" ]]; then
    echo "error! bad http code: ${http_code}. check /tmp/298jtj2.json"
    break
  fi
  cat /tmp/298jtj2.json > "${fn}"
done
# combine batches
while read -r file; do
  cat "${file}" | jq '.list_films | .[]'
done <<< $(find "${FOLDER}" -type f -name "films_*" | sort -V) \
  | jq -c --slurp '.' \
  > "${FOLDER}/films.json"

# create html page
./build.sh \
  "${FOLDER}/films.json" \
  "${FOLDER}/index.html" \
  "${LIST_URL}" \
  "${TITLE}" \
  "${PREAMBLE}"

echo now run rm \""${FOLDER}/films_\"*"
```
