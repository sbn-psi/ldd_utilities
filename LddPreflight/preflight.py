#!/usr/bin/env python3

import argparse
import os
from lxml import etree


CASE_EXCEPTIONS = [x.strip() for x in open("case_exceptions.txt")]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file_name")
    args = parser.parse_args()

    e = Enforcer(args.file_name, {"pds": "http://pds.nasa.gov/pds4/pds/v1"})
    e.apply_rules()

class Enforcer:
    def __init__(self, filename, nsmap):
        print (f"Checking {filename}")
        self.doc = doc = etree.parse(filename)
        self.filename = filename
        self.nsmap = nsmap
        self.ns = self.get_text(self.doc, "//pds:namespace_id")

    def apply_rules(self):
        self.apply_rule("//pds:DD_Association/pds:identifier_reference", [self.restrict_pds_references, self.restrict_ns_references])
        self.apply_rule("//pds:DD_Association/pds:local_identifier", [self.restrict_pds_references, self.restrict_ns_references])
        self.apply_rule("//pds:DD_Attribute/pds:name", [self.reserve_names, self.restrict_units])
        self.apply_rule("//pds:DD_Permissible_Value/pds:value", [self.title_case])
        self.apply_rule("//pds:DD_Attribute", [self.require_value_list_for_types, self.nillables_must_be_required, self.attributes_should_be_referenced])
        self.apply_rule("//pds:DD_Class/pds:name", [self.reserve_names])
        self.apply_rule("//pds:DD_Class", [self.elements_cannot_be_contained, self.nonelements_should_be_referenced, self.local_internal_reference_should_have_type, self.internal_reference_should_have_type])


    def apply_rule(self, path, rules):
        for x in self.doc.xpath(path, namespaces=self.nsmap):
            for rule in rules:
                rule(x)

    def title_case(self, element):
        '''
        Ensures that the value of the element isn't obviously not title case. Title-case is a soft definition,
        so this currently applies the following rules:
            no terms that start with a lower case letter
            no terms that are all uppercase
        except for explicit exceptions. These are maintained in an exception file.
        '''
        value = element.text
        #if not(re.match("^[A-Z0-9][a-z0-9]*([ ][A-Z0-9][a-z0-9]*)*$", value)):
        #    print(f"{value} is not in start-case")
        if any([x[0].islower() and x not in CASE_EXCEPTIONS for x in value.split()]):
            self.report(element, f"Enumerated value '{value}' contains a lower-case term", "lower-case-term")
        if any([x.isupper() and len(x) > 1 and x not in CASE_EXCEPTIONS for x in value.split()]):
            self.report(element, f"Enumerated value '{value}' contains an upper-case term", "upper-case-term")

    def restrict_pds_references(self, element):
        '''
        Enures that only specifically allowed references to the PDS namespace are in the system.
        '''
        value = element.text
        EXCEPTIONS=["pds.Internal_Reference", "pds.Local_Internal_Reference", "pds.External_Reference", "pds.local_identifier", "pds.logical_identifier"]
        if value.startswith("pds.") and value not in EXCEPTIONS:
            self.report(element, f"Association '{value}' is a reference to the PDS namespace", "pds-namespace-reference", "ERROR")

    def restrict_ns_references(self, element):
        '''
        Disallows references to external namespaces, other than the PDS namespace
        '''
        value = element.text
        tokens = value.split(".")
        if len(tokens) > 1:
            self.ns = self.get_text(self.doc, "//pds:namespace_id")
            ns = tokens[0]
            if not ns in [self.ns, "pds"]:
                self.report(element, f"Association '{value}' may be an external namespace reference", "external-namespace-reference")


    def reserve_names(self, element):
        '''
        Ensures that classes and attributes don't have names that are reserved for references.
        '''
        value = element.text
        RESERVED_NAMES=["Internal_Reference", "Local_Internal_Reference", "logical_identifier"]
        if value in RESERVED_NAMES:
            self.report(element, f"Class/Attribute '{value}' has a reserved name", "reserved-name", "ERROR")

    def restrict_units(self, element):
        '''
        Ensures that attributes aren't attempting to define units.
        '''
        value = element.text
        if "unit" in value:
            self.report(element, f"Attribute '{value}' attempts to specify a unit", "attribute-is-unit")


    def require_value_list_for_types(self, element):
        '''
        Ensures that any attributes that look like types also have a value list.
        '''
        attribute_element = element.xpath("pds:name", namespaces=self.nsmap)[0]
        attribute_name = attribute_element.text
        if attribute_name.endswith("_type"):
            enum_element = self.get_element(element, "pds:DD_Value_Domain/pds:enumeration_flag")
            if enum_element.text == "false":
                self.report(enum_element, f"{attribute_name} has a name of '_type', but is not an enumeration", "type-isnt-enumeration", "ERROR")
            permissible_values = element.xpath("pds:DD_Value_Domain/pds:DD_Permissible_Value", namespaces=self.nsmap)
            if not permissible_values:
                self.report(enum_element, f"Attribute '{attribute_name}' appears to be a type, but has no permissible values", "type-without-permissible-values", "ERROR")

    def nillables_must_be_required(self, element):
        '''
        Ensures that any attribute that is nillable is also required by a class.
        '''
        nillable = self.get_text(element, "pds:nillable_flag")
        if nillable == "true":
            attribute_name = self.get_text(element, "pds:name")
            local_id = self.get_text(element, "pds:local_identifier")
            required_by = self.get_elements(self.doc,f"//pds:DD_Association[pds:identifier_reference='{local_id}'][pds:minimum_occurrences > 0]")
            if not required_by:
                self.report(element, f"Attribute '{attribute_name}' is nillable, but is not required by any element", "nillable-not-required" ,"ERROR")

    def attributes_should_be_referenced(self, element):
        '''
        Ensures that every attribute is used in a class definition.
        '''
        attribute_name = self.get_text(element, "pds:name")
        local_id = self.get_text(element, "pds:local_identifier")
        referenced_by = self.get_elements(self.doc,f"//pds:DD_Association[pds:identifier_reference='{local_id}']")
        if not referenced_by:
            self.report(element, f"Attribute '{attribute_name}' is never used by any element", "attribute-never-used")

    def elements_cannot_be_contained(self, element):
        '''
        Ensures that any class that is declared as an element is not contained within another class
        '''
        isElement = self.get_text(element, "pds:element_flag")
        if isElement == "true":
            element_name = self.get_text(element, "pds:name")
            local_id = self.get_text(element, "pds:local_identifier")
            containers = self.get_elements(self.doc, f"//pds:DD_Association[pds:identifier_reference='{local_id}' or pds:identifier_reference='{self.ns}.{local_id}']")
            if containers:
                self.report(element, f"Class '{element_name} is an element, but is contained by another class", "element-contained-in-class", "ERROR")

    def nonelements_should_be_referenced(self, element):
        '''
        Ensures that any class that is *not* declared as an element is contained in at least one class.
        '''
        isElement = self.get_text(element, "pds:element_flag")
        if isElement == "false":
            element_name = self.get_text(element, "pds:name")
            local_id = self.get_text(element, "pds:local_identifier")
            containers = self.get_elements(self.doc, f"//pds:DD_Association[pds:identifier_reference='{local_id}' or pds:identifier_reference='{self.ns}.{local_id}']")
            if not containers:
                self.report(element, f"Class '{element_name}' is an not element, but is never used", "unused-non-element")

    def local_internal_reference_should_have_type(self, element):
        '''
        Ensures that every usage of local internal reference has a corresponding schematron rule that presumably
        contains a type list.
        '''
        internal_reference = self.get_element(element, "pds:DD_Association[pds:identifier_reference='pds.Local_Internal_Reference']")
        if internal_reference is not None:
            element_name = self.get_text(element, "pds:name")
            contexts = self.get_elements(element, "//pds:DD_Rule/pds:rule_context")
            target_context = f"{self.ns}:{element_name}/pds:Local_Internal_Reference"
            if not any(target_context in context.text for context in contexts):
                self.report(element, f"Class '{element_name}' contains a Local_Internal_Reference, but has no type list", "local-internal-reference-type-list", "ERROR")

    def internal_reference_should_have_type(self, element):
        '''
        Ensures that every usage of internal reference has a corresponding schematron rule that presumably
        contains a type list.
        '''
        internal_reference = self.get_element(element, "pds:DD_Association[pds:identifier_reference='pds.Internal_Reference']")
        if internal_reference is not None:
            element_name = self.get_text(element, "pds:name")
            contexts = self.get_elements(element, "//pds:DD_Rule/pds:rule_context")
            target_context = f"{self.ns}:{element_name}/pds:Internal_Reference"
            if not any(target_context in context.text in context.text for context in contexts):
                self.report(element, f"Class '{element_name}' contains an Internal_Reference, but has no type list", "internal-reference-type-list", "ERROR")

    def get_text(self, element, path, defaultValue=None):
        element = self.get_element(element, path)
        return element.text if element is not None else defaultValue

    def get_element(self, element, path):
        elements = element.xpath(path, namespaces=self.nsmap)
        return elements[0] if len(elements) else None

    def get_elements(self, element, path):
        return element.xpath(path, namespaces=self.nsmap)

    def report(self, element, message, type, severity='WARNING'):
        print (f'File: {os.path.basename(self.filename)}, Line: {element.sourceline}, [{type}], {severity}: {message}')

if __name__ == '__main__':
    main()