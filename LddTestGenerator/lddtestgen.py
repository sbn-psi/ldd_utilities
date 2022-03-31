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

    builder = TestBuilder(env, nsmap, args.snippet_dir, args.output_dir)

    for suite in suites:
        builder.create_suite(suite)

    for test in tests:
        builder.create_test(test)

class TestBuilder:
    def __init__(self, env, nsmap, snippet_dir, output_dir):
        self.env = env
        self.nsmap = nsmap
        self.snippet_dir = snippet_dir
        self.output_dir = output_dir

    def create_suite(self, suite):
        for test in suite["tests"]:
            self.create_test(test, suite=suite)

    def create_test(self, test, suite={}):
        template_file = test.get("template_file", suite.get("template_file"))
        template = self.env.get_template(template_file)

        snippet_list = test.get("snippet_files", suite.get("snippet_files")).items()
        snippets = {name: self.load_snippet(filename) for name, filename in snippet_list}

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
        doc = self.apply_mutations(contents, test.get("mutations", []), self.nsmap)

        os.makedirs(self.output_dir, exist_ok=True)
        filename = os.path.join(self.output_dir, f"{product_id}_{test['test_type']}.xml")
        doc.write(filename, encoding="utf-8", xml_declaration=True, pretty_print=True)


    def load_snippet(self, filename):
        with open(os.path.join(self.snippet_dir, filename)) as f:
            return f.read()

    def apply_mutations(self, contents, mutations, nsmap) -> ElementTree:
        doc = etree.parse(BytesIO(contents.encode('utf-8')))
        for mutation in mutations:
            self.apply_mutation(doc, mutation, nsmap)
        return doc

    def apply_mutation(self, doc:ElementTree, mutation, nsmap):
        xpath = mutation['xpath']
        operation = mutation['operation']        

        for e in doc.findall(xpath, nsmap):
            self.operate(e, operation, mutation)

    def operate(self, e, operation, params):
        if operation == 'delete':
            self.addcomment(e, "Deleted element")
            e.getparent().remove(e)
        if operation == 'changeValue':
            value = params["value"]
            self.addcomment(e, f"Change value from '{e.text}' to '{value}'")
            e.text = value
        if operation == 'changeUnit':
            value = params["value"]
            oldvalue = e.attrib["unit"]
            self.addcomment(e, f"Change unit from '{oldvalue}' to '{value}'")
            e.attrib["unit"] = value

    def addcomment(self, e, message):
        e.getparent().append(etree.Comment(f"lddtestgen:: {e.tag}: {message}"))

if __name__ == "__main__":
    sys.exit(main())