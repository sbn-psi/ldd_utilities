#!/usr/bin/env python3

import sys
import argparse
import json
import os
import os.path
import textwrap
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
    tests = config.get("tests", [])
    nsmap = config.get("namespaces", {})
    suites = config.get("suites", [])

    for suite in suites:
        create_suite(suite, env, nsmap, args.snippet_dir, args.output_dir)

    for test in tests:
        create_test(test, env, nsmap, args.snippet_dir, args.output_dir)

def create_suite(suite, env, nsmap, snippet_dir, output_dir):
    for test in suite["tests"]:
        create_test(test, env, nsmap, snippet_dir, output_dir, suite=suite)

def create_test(test, env, nsmap, snippet_dir, output_dir, suite={}):
    template_file = test.get("template_file", suite.get("template_file"))
    template = env.get_template(template_file)

    snippet_list = test.get("snippet_files", suite.get("snippet_files")).items()
    snippets = {name: load_snippet(filename, snippet_dir) for name, filename in snippet_list}

    suite_description = "\n".join(textwrap.wrap(suite.get("description", "")))
    test_description = "\n".join(textwrap.wrap(test.get("description", "")))
    suite_id = suite.get("id", "")
    test_id = test.get("id", "")

    product_id = "_".join(x for x in [suite_id, test_id] if x)
    
    contents = template.render(
        product_id=product_id, 
        snippets=snippets, 
        test_description=test_description, 
        suite_description=suite_description,
        test_id=test_id,
        suite_id=suite_id)
    doc = apply_mutations(contents, test.get("mutations", []), nsmap)

    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.join(output_dir, f"{product_id}_{test['test_type']}.xml")
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
            addcomment(e, "Deleted element")
            e.getparent().remove(e)
        if operation == 'changeValue':
            value = mutation["value"]
            addcomment(e, f"Change value from '{e.text}' to '{value}'")
            e.text = value
        if operation == 'changeUnit':
            value = mutation["value"]
            oldvalue = e.attrib["unit"]
            addcomment(e, f"Change unit from '{oldvalue}' to '{value}'")
            e.attrib["unit"] = value

def addcomment(e, message):
    e.getparent().append(etree.Comment(f"lddtestgen:: {e.tag}: {message}"))

if __name__ == "__main__":
    sys.exit(main())