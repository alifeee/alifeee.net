#!/bin/bash
# build HTML from JSON objects

FILMFILE="${1:-films.json}"
OUTFILE="${2:-index.html}"
LIST_URL="${3:-https://mubi.com/en/lists/edgar-wrights-favorite-movies}"
LIST_NAME="${4:-"Edgar Wright's 1000 Favorite Movies"}"
LIST_PREAMBLE="${5:-'<p>This list of personal favorites was assembled by Edgar Wright and myself in July 2016. Films are in chronological order.</p>
<p>Note from Edgar:</p>
<p>“This is a personal and subjective list of 1000 favourite movies from 100 years of cinema. It’s not a set text or intended as any bible of ‘greatest’ films. I decided to put this together as a fluid list for my own enjoyment, amusement and reference. I hope it’s fun for you to pore over and dive into some of the films you haven’t seen or haven’t heard of.</p>
<p>Don’t get all riled up about omissions or which movies you think should be favourites of mine, the truth is I may very well like / not like or not have seen the movies you think are missing. In fact, I like way more than 1000 movies, but any longer and this list would be really insane.</p>
<p>Thanks to Sam DiSalle for helping me put it together. If you feel so inspired, make your own list. Film watching is a life time pursuit and there’s many more films out there for me to see. This site is a great place to start."</p>
<p>Edgar Wright, Aug 2016.</p>'}"

tempfile="/tmp/index2828.html"

totalfilms=$(cat "${FILMFILE}" | jq -r 'length')

cat > "${tempfile}" << EOHTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
EOHTML

cat "style.css" >> "${tempfile}"

cat >> "${tempfile}" << EOHTML
</style>
<script>
EOHTML

cat "script.js" >> "${tempfile}"

cat >> "${tempfile}" << EOHTML
</script>
<script>
</script>
</head>
<body>
<header>
<h1>${LIST_NAME}</h1>
<p>
  Pulled from the <a href="${LIST_URL}">Mubi list</a> of the same name by <a href="https://alifeee.net">alifeee</a> on $(date). see raw <a href="films.json">films.json</a>. <a href="../..">back</a>
</p>
<hr>
<details class="preamble"><summary>Preamble from Mubi</summary>
  ${LIST_PREAMBLE}
</details>
<hr>
<details id="sortfilter"><summary>SORT/FILTER – <span id="filter-no">${totalfilms}</span> of ${totalfilms} showing, sorted by <span id="sorted-by">year, ascending</span></summary>
<form autocomplete="off">
<p id="sort">
  Sort by: (<input type="checkbox" id="sort-direction" checked>
  <label for="sort-direction">ascending</label>)
  <br>
  <label for="sort-year">
    <input type="radio" name="sort" id="sort-year" data-sort="year" checked>
    year
  </label>
  <label for="sort-title">
    <input type="radio" name="sort" id="sort-title" data-sort="title">
    title
  </label>
  <label for="sort-runtime">
    <input type="radio" name="sort" id="sort-runtime" data-sort="runtime">
    runtime
  </label>
  <label for="sort-popularity">
    <input type="radio" name="sort" id="sort-popularity" data-sort="popularity">
    popularity
  </label>
  <label for="sort-rating">
    <input type="radio" name="sort" id="sort-rating" data-sort="rating">
    rating
  </label>
  <label for="sort-criticrating">
    <input type="radio" name="sort" id="sort-criticrating" data-sort="criticrating">
    critic rating
  </label>
  <label for="sort-cast">
    <input type="radio" name="sort" id="sort-cast" data-sort="cast">
    cast members
  </label>
  <label for="sort-random">
    <input type="radio" name="sort" id="sort-random" data-sort="random">
    random
  </label>
</p>
<hr>
<p id="filter-genre">
  Filter by genre:
  (match <input type="radio" name="genre-BOOL" id="genre-AND" checked><label for="genre-AND">all</label>
  <input type="radio" name="genre-BOOL" id="genre-OR"><label for="genre-OR">any</label>
  )
  <br>
EOHTML

genres=$(
  cat "${FILMFILE}" \
    | jq -r '.[] | .film.genres | .[]' \
    | sort | uniq -c | sort -V \
    | sed -E 's+^ *++;s+^([0-9]*) +\1\t+'
)
echo "${genres}" | awk -F'\t' '{
  printf "<label for=\"genre-%s\"><input type=\"checkbox\" id=\"genre-%s\" data-genre=\"%s\">%s (%s)</label>\n", $2, $2, $2, $2, $1
}' >> "${tempfile}"

cat >> "${tempfile}" << EOHTML
</p>
</form>
</details>
<hr>
</header>
<main>
<section id="films">
EOHTML

cat "${FILMFILE}" | jq -r '.[] |
  .position as $position |
  .film.title as $title |
  .film.year as $year |
  .film.still_url as $poster |
  .film.web_url as $url |
  .film.duration as $runtime |
  .film.average_colour_hex as $colour |
  .film.short_synopsis_html as $synopsis_html |
  .film.average_rating as $rating |
  .film.number_of_ratings as $nratings |
  (.film.critic_review_rating*100|round/100) as $criticrating |
  .film.popularity as $popularity |
  .film.cast_members_count as $cast |
  (.film.genres | join(",")) as $genres |
  (.film.genres | join(", ")) as $genres_spaced |
  ([.film.directors | .[] | .name] | join(", ")) as $directors |
  "<details
    name=\"film\"
    style=\"--bg:url(\($poster)); --bc:#\($colour)\"
    class=\"film\"
    data-year=\"\($year)\"
    data-title=\"\($title)\"
    data-runtime=\"\($runtime)\"
    data-popularity=\"\($popularity)\"
    data-rating=\"\($rating)\"
    data-criticrating=\"\($criticrating)\"
    data-genres=\"\($genres)\"
    data-cast=\"\($cast)\"
  >
    <summary>
      <span>\($position)</span>
      <span>\($title) (\($year))</span>
      <span>\($runtime) m</span>
    </summary>
    <div class=\"more\">
      <span class=\"text rating\">
        \($rating)/5 (\($nratings))
      </span>
      <span class=\"text directors\">
        \($directors)
      </span>
      <div class=\"text synopsis\">
        \($synopsis_html)
      </div>
      <span class=\"text genres\">
        \($genres_spaced)
      </span>
      <span class=\"text extra\">
        popularity: \($popularity).
        critics: \($criticrating)/5.
        cast members: \($cast)
      </span>
      <a target=_blank class=mubi href=\"\($url)\"><img src=\"../mubi.svg\" alt=\"mubi logo\"></a>
    </div>
  </details>"
' >> "${tempfile}"

cat >> "${tempfile}" << EOHTML
</section>
</main>
<hr>
</body>
</html>
<!--
GENERATED WITH
FILMFILE=${FILMFILE}
OUTFILE=${OUTFILE}
LIST_URL=${LIST_URL}
LIST_NAME=${LIST_NAME}
LIST_PREAMBLE=${LIST_PREAMBLE}
-->
EOHTML

cat "${tempfile}" > "${OUTFILE}"

echo "built ${OUTFILE}!"
