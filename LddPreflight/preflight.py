#!/usr/bin/env python3

import argparse
from lxml import etree


NSMAP = {"pds": "http://pds.nasa.gov/pds4/pds/v1"}
CASE_EXCEPTIONS = [x.strip() for x in open("case_exceptions.txt")]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file_name")
    args = parser.parse_args()

    print (f"Checking {args.file_name}")
    doc = etree.parse(args.file_name)
    
    #apply_rule(doc, "//pds:DD_Permissible_Value/pds:value", [title_case])
    apply_rule(doc, "//pds:DD_Association/pds:identifier_reference", [restrict_pds_references])
    apply_rule(doc, "//pds:DD_Association/pds:local_identifier", [restrict_pds_references])
    apply_rule(doc, "//pds:DD_Attribute/pds:name", [reserve_names, restrict_units])
    apply_rule(doc, "//pds:DD_Permissible_Value/pds:value", [title_case])
    apply_rule(doc, "//pds:DD_Attribute", [require_value_list_for_types, nillables_must_be_required])
    apply_rule(doc, "//pds:DD_Class/pds:name", [reserve_names])
    apply_rule(doc, "//pds:DD_Class", [elements_cannot_be_contained])

def apply_rule(doc, path, rules):
    for x in doc.xpath(path, namespaces=NSMAP):
        for rule in rules:
            rule(doc, x)

def title_case(doc, element):
    value = element.text
    #if not(re.match("^[A-Z0-9][a-z0-9]*([ ][A-Z0-9][a-z0-9]*)*$", value)):
    #    print(f"{value} is not in start-case")
    if any([x[0].islower() and x not in CASE_EXCEPTIONS for x in value.split()]):
        violation(element, f"{value} contains a lower-case term")
    if any([x.isupper() and len(x) > 1 and x not in CASE_EXCEPTIONS for x in value.split()]):
        violation(element, f"{value} contains an upper-case term")

def restrict_pds_references(doc, element):
    value = element.text
    EXCEPTIONS=["pds.Internal_Reference", "pds.Local_Internal_Reference", "pds.External_Reference", "pds.local_identifier", "pds.logical_identifier"]
    if value.startswith("pds.") and value not in EXCEPTIONS:
        violation(element, f"{value} is a reference to the PDS namespace", "ERROR")

def reserve_names(doc, element):
    value = element.text
    RESERVED_NAMES=["Internal_Reference", "Local_Internal_Reference", "logical_identifier"]
    if value in RESERVED_NAMES:
        violation(element, f"{value} is a reserved name", "ERROR")

def restrict_units(doc, element):
    value = element.text
    if "unit" in value:
        violation(element, f"{value} attempts to specify a unit")


def require_value_list_for_types(doc, element):
    attribute_element = element.xpath("pds:name", namespaces=NSMAP)[0]
    attribute_name = attribute_element.text
    if attribute_name.endswith("_type"):
        enum_element = element.xpath("pds:DD_Value_Domain/pds:enumeration_flag", namespaces=NSMAP)[0]
        if enum_element.text == "false":
            violation(enum_element, f"{attribute_name} has a name of '_type', but is not an enumeration", "ERROR")
        permissible_values = element.xpath("pds:DD_Value_Domain/pds:DD_Permissible_Value", namespaces=NSMAP)
        if not permissible_values:
            violation(enum_element, f"{attribute_name} has a name of '_type', but has no permissible values", "ERROR")

def nillables_must_be_required(doc, element):
    nillable = get_text(element, "pds:nillable_flag")
    if nillable == "true":
        attribute_name = get_text(element, "pds:name")
        local_id = get_text(element, "pds:local_identifier")
        required_by = doc.xpath(f"//pds:DD_Association[pds:identifier_reference='{local_id}'][pds:minimum_occurrences > 0]", namespaces=NSMAP)
        if not required_by:
            violation(element, f"{attribute_name} is nillable, but is not required by any element", "ERROR")

def elements_cannot_be_contained(doc, element):
    isElement = get_text(element, "pds:element_flag")
    if isElement == "true":
        element_name = get_text(element, "pds:name")
        local_id = get_text(element, "pds:local_identifier")
        containers = doc.xpath(f"//pds:DD_Association[pds:identifier_reference='{local_id}']", namespaces=NSMAP)
        if containers:
            violation(element, f"{element_name} is an element, but is contained by another class", "ERROR")

def get_text(element, path, defaultValue=None):
    elements = element.xpath(path, namespaces=NSMAP)
    return elements[0].text if elements else defaultValue

def violation(element, message, severity='WARNING'):
    print (f'{severity}: Line {element.sourceline}: {message}')

if __name__ == '__main__':
    main()