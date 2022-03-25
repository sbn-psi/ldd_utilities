#!/usr/bin/env python3

import sys
import argparse
import json
import os
import os.path
from io import BytesIO
from xml.etree.ElementTree import ElementTree

import jinja2
from lxml import etree


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-file", required=True)
    parser.add_argument("--template-dir", required=True)
    parser.add_argument("--snippet-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    env = jinja2.Environment(loader=jinja2.FileSystemLoader(args.template_dir))

    config = json.load(open(args.json_file))
    tests = config["tests"]
    nsmap = config["namespaces"]

    for test in tests:
        create_test(test, env, nsmap, args.snippet_dir, args.output_dir)

def create_test(test, env, nsmap, snippet_dir, output_dir):
    
    template = env.get_template(test["template_file"])
    snippets = {name: load_snippet(filename, snippet_dir) for name, filename in test["snippet_files"].items()}
    description = test.get("description", "")
    contents = template.render(product_id=test["product_id"], snippets=snippets, description=description)
    doc = apply_mutations(contents, test.get("mutations", []), nsmap)

    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.join(output_dir, f"{test['product_id']}_{test['test_type']}.xml")
    doc.write(filename, encoding="utf-8", xml_declaration=True, pretty_print=True)


def load_snippet(filename, snippet_dir):
    with open(os.path.join(snippet_dir, filename)) as f:
        return f.read()

def apply_mutations(contents, mutations, nsmap) -> ElementTree:
    doc = etree.parse(BytesIO(contents.encode('utf-8')))
    for mutation in mutations:
        apply_mutation(doc, mutation, nsmap)
    return doc

def apply_mutation(doc:ElementTree, mutation, nsmap):
    xpath = mutation['xpath']
    operation = mutation['operation']

    for e in doc.findall(xpath, nsmap):
        if operation == 'delete':
            e.getparent().remove(e)
        if operation == 'changeValue':
            value = mutation["value"]
            e.text = value
        if operation == 'changeUnit':
            value = mutation["value"]
            e.attrib["unit"] = value

if __name__ == "__main__":
    sys.exit(main())