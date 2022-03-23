#!/usr/bin/env python3

import sys
import argparse
import json
import os
import os.path

import jinja2


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-file", required=True)
    parser.add_argument("--template-dir", required=True)
    parser.add_argument("--snippet-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    env = jinja2.Environment(loader=jinja2.FileSystemLoader(args.template_dir))

    tests = json.load(open(args.json_file))

    for test in tests:
        create_test(test["product_id"], test["test_type"], test["template_file"], test["snippet_files"], env, args.snippet_dir, args.output_dir)

def create_test(product_id, test_type, template_file, snippet_files, env, snippet_dir, output_dir):
    template = env.get_template(template_file)
    snippets = {name: load_snippet(filename, snippet_dir) for name, filename in snippet_files.items()}
    contents = template.render(product_id=product_id, snippets=snippets)
    os.makedirs(output_dir, exist_ok=True)
    with open(os.path.join(output_dir, f"{product_id}_{test_type}.xml"), "w") as f:
        f.write(contents)


def load_snippet(filename, snippet_dir):
    with open(os.path.join(snippet_dir, filename)) as f:
        return f.read()

if __name__ == "__main__":
    sys.exit(main())