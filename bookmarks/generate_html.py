"""load bookmarks and make static html page"""
import json
from pybars import Compiler

TEMPLATE_FILE = "template.html.hbs"
OUTPUT_FILE = "index.html"

compiler = Compiler()

with open(TEMPLATE_FILE, "r", encoding="utf-8") as f:
    template = compiler.compile(f.read())

with open("bookmarks.json", "r", encoding="utf-8") as f:
    data = json.load(f)

output = template(data)

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(output)
