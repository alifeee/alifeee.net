"""file to read bookmarks from an sqlite file and return a list of bookmarks"""

import os
import sqlite3
import sys
import shutil
import argparse
from subprocess import check_output
from datetime import datetime
from dataclasses import dataclass
from enum import Enum
from typing import Optional
import json

DB_FILE = "/tmp/places.sqlite"
# YYYY-MM-DDTHH:mm:ss.sssZ
DATE_FORMAT = "%Y-%m-%dT%H:%M:%S.%fZ"

# moz_bookmarks table
# CREATE TABLE moz_bookmarks (
#   id INTEGER PRIMARY KEY,
#   type INTEGER,
#   fk INTEGER DEFAULT NULL,
#   parent INTEGER,
#   position INTEGER,
#   title LONGVARCHAR,
#   keyword_id INTEGER,
#   folder_type TEXT,
#   dateAdded INTEGER,
#   lastModified INTEGER,
#   guid TEXT,
#   syncStatus INTEGER NOT NULL DEFAULT 0,
#   syncChangeCounter INTEGER NOT NULL DEFAULT 1
# );
# CREATE INDEX moz_bookmarks_itemindex ON moz_bookmarks (fk, type);
# CREATE INDEX moz_bookmarks_parentindex ON moz_bookmarks (parent, position);
# CREATE INDEX moz_bookmarks_itemlastmodifiedindex ON moz_bookmarks (fk, lastModified);
# CREATE UNIQUE INDEX moz_bookmarks_guid_uniqueindex ON moz_bookmarks (guid);
# CREATE INDEX moz_bookmarks_dateaddedindex ON moz_bookmarks (dateAdded);


class BookmarkType(Enum):
    BOOKMARK = 1
    FOLDER = 2
    SEPARATOR = 3


@dataclass
class Bookmark:
    id: int
    type: BookmarkType
    url: Optional[str]
    parent: int
    position: int
    title: str
    folder_type: str
    dateAdded: datetime
    lastModified: datetime
    guid: str


def read_bookmarks() -> list[Bookmark]:
    """read bookmarks from an sqlite file and return a list of bookmarks"""
    path = os.path.join(os.path.dirname(__file__), DB_FILE)
    try:
        conn = sqlite3.connect(path)
    except sqlite3.OperationalError:
        print("Error: Could not connect to database.")
        sys.exit(1)

    try:
        bookmarks_sql = conn.execute(
            "SELECT id, type, fk, parent, position, title, folder_type, dateAdded, lastModified, guid FROM moz_bookmarks"
        )
    except sqlite3.OperationalError:
        print("Error: Could not read bookmarks.")
        sys.exit(1)

    # get url from moz_places with fk as id
    bookmarks = []
    for bookmark_sql in bookmarks_sql:
        bookmark = Bookmark(
            id=bookmark_sql[0],
            type=BookmarkType(bookmark_sql[1]),
            url=None,
            parent=bookmark_sql[3],
            position=bookmark_sql[4],
            title=bookmark_sql[5],
            folder_type=bookmark_sql[6],
            dateAdded=datetime.fromtimestamp(bookmark_sql[7] / 1000000),
            lastModified=datetime.fromtimestamp(bookmark_sql[8] / 1000000),
            guid=bookmark_sql[9],
        )
        if bookmark.type == BookmarkType.BOOKMARK:
            try:
                url_sql = conn.execute(
                    "SELECT url FROM moz_places WHERE id = ?", (bookmark_sql[2],)
                )
            except sqlite3.OperationalError:
                print(f"Error: Could not read url for bookmark {bookmark.id}.")
                sys.exit(1)
            bookmark.url = url_sql.fetchone()[0]
        bookmarks.append(bookmark)

    conn.close()
    return bookmarks


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Read bookmarks from an sqlite file and return a list of bookmarks."
    )
    # list of folders to read
    parser.add_argument(
        "-f",
        "--folders",
        help="list of folders to include (id or name)",
        type=str,
        nargs="+",
        default=[],
        dest="folders",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="output file",
        type=str,
        default="bookmarks.json",
        dest="output_file",
    )
    args = parser.parse_args()

    # find and copy bookmarks file
    print("finding bookmark file")
    places = check_output(
        ["find", os.path.expanduser("~/.mozilla/firefox"), "-name", "places.sqlite"],
        encoding="UTF-8",
    ).split()
    print("found: ", places)
    if len(places) != 1:
        raise ValueError(
            "could not find singular bookmark file, maybe too few? maybe too many?"
        )
    shutil.copy(places[0], DB_FILE)

    bookmarks = read_bookmarks()
    print(f"Read {len(bookmarks)} bookmarks.")

    folders: list[Bookmark] = []
    for asked_folder in args.folders:
        if asked_folder.isnumeric():
            # if there is a bookmark with this id
            try:
                folders.append(next(b for b in bookmarks if b.id == int(asked_folder)))
            except StopIteration:
                print(f"Warning: Folder with id {asked_folder} not found.")
        else:
            # if there is a bookmark with this title
            try:
                folders.append(next(b for b in bookmarks if b.title == asked_folder))
            except StopIteration:
                print(f"Warning: Folder with title {asked_folder} not found.")

    data = {
        "last_modified": datetime.now().strftime(DATE_FORMAT),
        "bookmarks": {},
    }

    # sort bookmarks by `position`
    bookmarks.sort(key=lambda x: x.position)

    counter = 0
    for folder in folders:
        folder_bookmarks = []
        for bookmark in bookmarks:
            if bookmark.parent == folder.id and bookmark.type == BookmarkType.BOOKMARK:
                folder_bookmarks.append(
                    {
                        "title": bookmark.title,
                        "url": bookmark.url,
                        "date_added": bookmark.dateAdded.strftime(DATE_FORMAT),
                        # "last_modified": bookmark.lastModified.strftime(DATE_FORMAT),
                    }
                )
                counter += 1
        data["bookmarks"][folder.title] = folder_bookmarks

    print(f"Found {counter} bookmarks in {len(folders)} folders.")

    with open(args.output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

    print(f"Wrote {counter} bookmarks to {args.output_file}.")
