# Firefox bookmarks

This is an exporter for Firefox bookmarks. It is designed so that I can easily share (some of) my bookmarks on my website.

For my bookmarks, see <https://alifeee.co.uk/bookmarks/>

```bash
# parse bookmarks
cat bookmark_folders.txt | xargs -d '\n' python3 read_bookmarks.py -f
# create html
python3 generate_html.py
```

## To use

In Firefox,

1. Go to `about:support` (`Alt, H, T`)
1. Open `Profile Folder`
1. Copy `places.sqlite` to this repository

Run [`read_bookmarks.py`](./read_bookmarks.py) with the bookmark folders you would like exported. For me, that's

```bash
py read_bookmarks.py -f "TOP 10 personal websites/blogs" "other bookmarks lists" "webrings" "personal websites (with blog)" "personal websites (without blog)" "interesting websites" "Articles (random)" "Articles (programming)" "video playlists/channels" "wordles" "mobile games"
```

You now have `bookmarks.json` which can be used wherever it needs to be used.

## Build HTML

I want this page to be static, so I don't want to make a "frontend" (something that would need to download and parse the JSON). So, here I just make a static `index.html` file to push to my website.

```bash
pip install -r requirements.txt
py generate_html.py
```

It gets build to `index.html`.
