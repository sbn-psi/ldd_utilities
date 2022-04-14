#!/usr/bin/env python3

import argparse
import os
import re
import itertools
from lxml import etree


NSMAP = {"pds": "http://pds.nasa.gov/pds4/pds/v1"}
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file_name")
    parser.add_argument("output_file")
    args = parser.parse_args()
    doc = etree.parse(args.file_name)

    classes = findall(doc, "//pds:DD_Class[pds:element_flag='true']")
    lines = itertools.chain.from_iterable(print_class(cls, doc) for cls in classes)
    with open(args.output_file, "w") as dest:
        dest.write("\r\n".join(lines))
    
def print_class(cls, doc):
    cls_name = find(cls, "pds:name").text
    cls_def = element_text(find(cls, "pds:definition"))
    yield(f'{cls_name},,"{cls_def}"')

    class_associations = findall(cls, "pds:DD_Association[pds:reference_type='component_of']")    
    for association in class_associations:
        class_ids = [x.text for x in findall(association, "pds:identifier_reference") if is_usable_reference(x.text)]
        for class_id in class_ids:
            cls2 = find(doc, f"//pds:DD_Class[pds:local_identifier='{class_id}']")
            if cls2 is not None:
                for x in print_class(cls2, doc):
                    yield(x)
            else:
                print(f"Could not find class: {class_id}")

    attribute_associations = findall(cls, "pds:DD_Association[pds:reference_type='attribute_of']")
    for association in attribute_associations:
        attribute_ids = [x.text for x in findall(association, "pds:identifier_reference")]
        for attribute_id in attribute_ids:
            attribute = find(doc, f"//pds:DD_Attribute[pds:local_identifier='{attribute_id}']")
            attribute_name = find(attribute, "pds:name").text
            attribute_def = element_text(find(attribute, "pds:definition"))
        
            yield(f'{cls_name},{attribute_name},"{attribute_def}"')

def is_usable_reference(reference):
    return all(x not in reference for x in [".", "#"])

def find(element, path):
    return element.find(path, namespaces=NSMAP)

def findall(element, path):
    return element.findall(path, namespaces=NSMAP)

def element_text(element):
    return re.sub(" +", " ",element.text.replace("\n", ""))

if __name__ == '__main__':
    main()