#!/usr/bin/env python3

import argparse
import os
from lxml import etree


NSMAP = {"pds": "http://pds.nasa.gov/pds4/pds/v1"}
CASE_EXCEPTIONS = [x.strip() for x in open("case_exceptions.txt")]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file_name")
    args = parser.parse_args()

    e = Enforcer(args.file_name)
    e.apply_rules()

class Enforcer:
    def __init__(self, filename):
        print (f"Checking {filename}")
        self.doc = doc = etree.parse(filename)
        self.filename = os.path.basename(filename)

    def apply_rules(self):
        self.apply_rule("//pds:DD_Association/pds:identifier_reference", [self.restrict_pds_references])
        self.apply_rule("//pds:DD_Association/pds:local_identifier", [self.restrict_pds_references])
        self.apply_rule("//pds:DD_Attribute/pds:name", [self.reserve_names, self.restrict_units])
        self.apply_rule("//pds:DD_Permissible_Value/pds:value", [self.title_case])
        self.apply_rule("//pds:DD_Attribute", [self.require_value_list_for_types, self.nillables_must_be_required])
        self.apply_rule("//pds:DD_Class/pds:name", [self.reserve_names])
        self.apply_rule("//pds:DD_Class", [self.elements_cannot_be_contained])


    def apply_rule(self, path, rules):
        for x in self.doc.xpath(path, namespaces=NSMAP):
            for rule in rules:
                rule(x)

    def title_case(self, element):
        value = element.text
        #if not(re.match("^[A-Z0-9][a-z0-9]*([ ][A-Z0-9][a-z0-9]*)*$", value)):
        #    print(f"{value} is not in start-case")
        if any([x[0].islower() and x not in CASE_EXCEPTIONS for x in value.split()]):
            self.report(element, f"{value} contains a lower-case term")
        if any([x.isupper() and len(x) > 1 and x not in CASE_EXCEPTIONS for x in value.split()]):
            self.report(element, f"{value} contains an upper-case term")

    def restrict_pds_references(self, element):
        value = element.text
        EXCEPTIONS=["pds.Internal_Reference", "pds.Local_Internal_Reference", "pds.External_Reference", "pds.local_identifier", "pds.logical_identifier"]
        if value.startswith("pds.") and value not in EXCEPTIONS:
            self.report(element, f"{value} is a reference to the PDS namespace", "ERROR")

    def reserve_names(self, element):
        value = element.text
        RESERVED_NAMES=["Internal_Reference", "Local_Internal_Reference", "logical_identifier"]
        if value in RESERVED_NAMES:
            self.report(element, f"{value} is a reserved name", "ERROR")

    def restrict_units(self, element):
        value = element.text
        if "unit" in value:
            self.report(element, f"{value} attempts to specify a unit")


    def require_value_list_for_types(self, element):
        attribute_element = element.xpath("pds:name", namespaces=NSMAP)[0]
        attribute_name = attribute_element.text
        if attribute_name.endswith("_type"):
            enum_element = element.xpath("pds:DD_Value_Domain/pds:enumeration_flag", namespaces=NSMAP)[0]
            if enum_element.text == "false":
                self.report(enum_element, f"{attribute_name} has a name of '_type', but is not an enumeration", "ERROR")
            permissible_values = element.xpath("pds:DD_Value_Domain/pds:DD_Permissible_Value", namespaces=NSMAP)
            if not permissible_values:
                self.report(enum_element, f"{attribute_name} has a name of '_type', but has no permissible values", "ERROR")

    def nillables_must_be_required(self, element):
        nillable = self.get_text(element, "pds:nillable_flag")
        if nillable == "true":
            attribute_name = self.get_text(element, "pds:name")
            local_id = self.get_text(element, "pds:local_identifier")
            required_by = self.doc.xpath(f"//pds:DD_Association[pds:identifier_reference='{local_id}'][pds:minimum_occurrences > 0]", namespaces=NSMAP)
            if not required_by:
                self.report(element, f"{attribute_name} is nillable, but is not required by any element", "ERROR")

    def elements_cannot_be_contained(self, element):
        isElement = self.get_text(element, "pds:element_flag")
        if isElement == "true":
            element_name = self.get_text(element, "pds:name")
            local_id = self.get_text(element, "pds:local_identifier")
            containers = self.doc.xpath(f"//pds:DD_Association[pds:identifier_reference='{local_id}']", namespaces=NSMAP)
            if containers:
                self.report(element, f"{element_name} is an element, but is contained by another class", "ERROR")

    def get_text(self, element, path, defaultValue=None):
        elements = element.xpath(path, namespaces=NSMAP)
        return elements[0].text if elements else defaultValue

    def report(self, element, message, severity='WARNING'):
        print (f'{severity} - File: {self.filename}, Line: {element.sourceline}, {message}')

if __name__ == '__main__':
    main()