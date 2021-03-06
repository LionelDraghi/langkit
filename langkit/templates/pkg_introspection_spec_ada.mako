## vim: filetype=makoada

with ${ada_lib_name}.Analysis; use ${ada_lib_name}.Analysis;

package ${ada_lib_name}.Introspection is

   Invalid_Field : exception;

   ## In a lot of testcases, there is a single concrete AST node that has no
   ## field. For these, generates a type that has no valid value.
   type Field_Reference is
      % if ctx.sorted_parse_fields:
         (${', '.join(f.introspection_enum_literal
                      for f in ctx.sorted_parse_fields)})
      % else:
         new Integer range 1 .. 0
      % endif
   ;
   --  Enumeration of all AST node fields

   function Field_Name (Field : Field_Reference) return String;
   --  Return a lower-case name for Field

   function Index (Field : Field_Reference) return Positive;
   --  Return the index in AST nodes to access the given --  Field

   function Field_Reference_From_Index
     (Kind : ${root_node_kind_name}; Index : Positive) return Field_Reference;
   --  Return the field reference corresponding to the given Index in AST nodes
   --  of the given Kind. Raise an Invalid_Field if there is no field
   --  corresponding to this index.

   type Field_Reference_Array is array (Positive range <>) of Field_Reference;

   function Fields
     (Kind : ${root_node_kind_name}) return Field_Reference_Array;
   --  Return the list of fields that AST nodes of the given Kind have

end ${ada_lib_name}.Introspection;
