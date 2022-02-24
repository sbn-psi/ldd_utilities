# LDDPreflight

This is a supplemental checker that finds LDD problems not known to be currently caught by validate. Some of the problems may also be caught by LDDTool, but this is still useful for quickly checking for those problems before trying to run LDDTool.

The following checks are currently enforced (approximately). Some are enforced better than others, but each one should be reasonably accurate:

* Standards Reference
  * 6E.3.1 Enumerated Attribute Values 
    * Must be ‘title case’ except if an acronym, abbreviation, or carried over from PDS3. Case variations of same word may not be used. That is, title case and all upper case must not be in same enumerated value list.
* Rules based on CCB-203
  * No local dictionary may define a class called Internal_Reference.
  * No local dictionary may define a class called Local_Internal_Reference.
  * No local dictionary may define an attribute called logical_identifier.
  * For local dictionaries that reference the pds:Internal_Reference class, at least one value for pds:reference_type must be defined for each valid local context.
  * For local dictionaries that reference the pds:Local_Internal_Reference class, at least one value for pds:local_reference_type must be defined for each valid local context.
* Rules based on CCB-204
  * Local dictionary attributes named "type" or with names ending in "_type" must have permissible value lists.  In the pds: and discipline namespaces these attributes are associated with search facets as well as value validation.
  * No attribute should be named "unit", "units", "unit_of_measure", or similar, or end in any of those strings. The pds: namespace uses XML attributes and unit classes to define units to enable searching across data from different sources on numeric fields with units of measure.  This also ensures that the unit of measure is directly associated with the attribute value to which it applies.
  * No class defined with `<element_flag>` set to "true" may be a component at any level of another class with `<element_flag>` set to "true".  In other words, if Class_A and Class_B both `<element_flag>` set to "true", then Class_A cannot include Class_B or any class that contains Class_B, and conversely.  This effectively requires that dictionaries define unique "entry points" - specific, high-level classes that act as containers for the dictionary content.
  * An attribute that is defined as "nillable" must be a required attribute of at least one class.  This follows the PDS core namespace design principle that attributes are either optional (and omitted when they do not have a value), or required but nillable (with a required "nilReason" attribute to explain why the value is not present).
* Extra Rules
  * Every non-element class should be referenced by another class
  * Every attribute should be referenced by at least one class.
  * With limited exceptions, the PDS namespace should not be referenced.
  * External namespaces should not be referenced.