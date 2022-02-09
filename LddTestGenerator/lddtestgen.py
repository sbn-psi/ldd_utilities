#!/usr/bin/env python3

import sys
import os.path

import jinja2

ENV = jinja2.Environment(loader=jinja2.PackageLoader("lddtestgen"))

def main():
    create_test("pass1", "VALID", "binary_table.xml.jinja", {"survey":"survey_pass1.txt"})

def create_test(product_id, test_type, template_file, snippet_files):
    template = ENV.get_template(template_file)
    snippets = {name: load_snippet(filename) for name, filename in snippet_files.items()}
    contents = template.render(product_id=product_id, snippets=snippets)
    with open(os.path.join("output", f"{product_id}_{test_type}.xml"), "w") as f:
        f.write(contents)


def load_snippet(filename):
    with open(os.path.join("snippets", filename)) as f:
        return f.read()

if __name__ == "__main__":
    sys.exit(main())