#!/usr/bin/env python3

import sys
import os.path

import jinja2

ENV = jinja2.Environment(loader=jinja2.PackageLoader("lddtestgen"))

TESTS = [
    {"product_id": "pass1", "test_type":"VALID", "template_file":"binary_table.xml.jinja", "snippet_files":{"survey":"survey_pass1.txt"}},
    {"product_id": "pass2", "test_type":"VALID", "template_file":"binary_table.xml.jinja", "snippet_files":{"survey":"survey_pass2.txt"}},
    {"product_id": "pass3", "test_type":"VALID", "template_file":"binary_table.xml.jinja", "snippet_files":{"survey":"survey_pass3.txt"}},
    {"product_id": "pass4", "test_type":"VALID", "template_file":"2d_image.xml.jinja", "snippet_files":{"survey":"survey_pass4.txt"}},
    {"product_id": "pass5", "test_type":"VALID", "template_file":"2d_image.xml.jinja", "snippet_files":{"survey":"survey_pass5.txt"}},
]

def main():
    for test in TESTS:
        create_test(test["product_id"], test["test_type"], test["template_file"], test["snippet_files"])

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