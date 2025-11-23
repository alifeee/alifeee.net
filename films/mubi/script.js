let sort_ascending = true;
let genre_bool = "AND";

function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
}

function sort_by_data_item(dataitem, ascending) {
  console.log(`sort by ${dataitem} (ascending: ${ascending})`);
  // numbers
  if (
    dataitem == "year" ||
    dataitem == "runtime" ||
    dataitem == "popularity" ||
    dataitem == "rating" ||
    dataitem == "criticrating" ||
    dataitem == "cast"
  ) {
    return function (a, b) {
      return (ascending ? 1 : -1) * (a.dataset[dataitem] - b.dataset[dataitem]);
    };
  }
  // words
  return function (a, b) {
    return (
      (ascending ? 1 : -1) *
      a.dataset[dataitem]
        .toLowerCase()
        .localeCompare(b.dataset[dataitem].toLowerCase())
    );
  };
}

function sortby(sort) {
  let list = document.getElementById("films");
  let els = document.querySelectorAll(".film");
  let new_els = [...els];
  if (sort == "random") {
    shuffleArray(new_els);
  } else {
    new_els = new_els.toSorted(sort_by_data_item(sort, sort_ascending));
  }
  while (list.firstChild) {
    list.removeChild(list.lastChild);
  }
  new_els.forEach((el) => {
    list.appendChild(el);
  });
  document.getElementById("sorted-by").innerText =
    sort + ", " + (sort_ascending ? "ascending" : "descending");
}

function filter_genres() {
  // get current genres
  let genre_cbs = document.querySelectorAll(
    '#filter-genre input[type="checkbox"'
  );
  let genres = [...genre_cbs]
    .filter((cb) => cb.checked)
    .map((cb) => cb.dataset.genre);
  console.log("filter to ", genres);
  // filter
  let films = document.querySelectorAll(".film");
  const INITIAL_DISPLAY = "flex";
  films.forEach((film) => {
    let found = true;
    if (!genres.length) {
      // do nothing, show all
    } else if (genre_bool == "AND") {
      found = genres.every((g) => film.dataset.genres.split(",").includes(g));
    } else if (genre_bool == "OR") {
      found = genres.some((g) => film.dataset.genres.split(",").includes(g));
    }
    film.style.display = found ? INITIAL_DISPLAY : "none";
  });
  document.getElementById("filter-no").innerText = [...films].filter(
    (f) => f.style.display != "none"
  ).length;
}

document.addEventListener("DOMContentLoaded", () => {
  // disable form
  document.querySelectorAll("form").forEach((form) => {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      return false;
    });
  });

  // add events for sort radio buttons
  document.getElementById("sort-direction").addEventListener("change", (e) => {
    sort_ascending = e.target.checked;
    sortby(
      [...document.querySelectorAll('#sort input[type="radio"')].filter(
        (rb) => rb.checked
      )[0].dataset.sort
    );
  });
  document.querySelectorAll('#sort input[type="radio"').forEach((rb) => {
    ["click", "change"].forEach((evt) => {
      rb.addEventListener(evt, (rbe) => {
        sortby(rbe.target.dataset.sort);
      });
    });
  });

  // add events for filter checkboxes
  document.getElementById("genre-AND").addEventListener("change", (e) => {
    if (e.target.checked) genre_bool = "AND";
  });
  document.getElementById("genre-OR").addEventListener("change", (e) => {
    if (e.target.checked) genre_bool = "OR";
  });
  document
    .querySelectorAll('#filter-genre input[type="checkbox"')
    .forEach((cb) => {
      cb.addEventListener("change", (cbe) => {
        console.log(
          "filter changed! " +
            cbe.target.dataset.genre +
            " to " +
            cbe.target.checked
        );
        filter_genres();
      });
    });
});
