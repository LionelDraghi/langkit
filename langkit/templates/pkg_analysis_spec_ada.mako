## vim: filetype=makoada

with Ada.Containers.Hashed_Maps;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;

with Langkit_Support.Bump_Ptr;           use Langkit_Support.Bump_Ptr;
with Langkit_Support.Diagnostics;        use Langkit_Support.Diagnostics;
with Langkit_Support.Symbols;            use Langkit_Support.Symbols;
with Langkit_Support.Token_Data_Handler; use Langkit_Support.Token_Data_Handler;

with ${_self.ada_api_settings.lib_name}.Analysis_Interfaces;
use ${_self.ada_api_settings.lib_name}.Analysis_Interfaces;
with ${_self.ada_api_settings.lib_name}.AST;
use ${_self.ada_api_settings.lib_name}.AST;

--  This package provides types and primitives to analyze source files as
--  analysis units.
--
--  This is the entry point to parse and process an unit: first create an
--  analysis context with Create, then get analysis units out of it using
--  Get_From_File and/or Get_From_Buffer.

package ${_self.ada_api_settings.lib_name}.Analysis is

   ----------------------
   -- Analysis context --
   ----------------------

   type Analysis_Context is private;
   ${ada_doc('langkit.analysis_context_type', 3)}

   type Analysis_Unit is private;
   ${ada_doc('langkit.analysis_unit_type', 3)}

   type Grammar_Rule is (
      % for i, name in enumerate(_self.user_rule_names):
         % if i > 0:
            ,
         % endif
         ${Name.from_lower(name)}_Rule
      % endfor
   );
   ${ada_doc('langkit.grammar_rule_type')}

   function Create
     (Charset : String := ${string_repr(_self.default_charset)})
      return Analysis_Context;
   ${ada_doc('langkit.create_context', 3)}

   function Get_From_File
     (Context     : Analysis_Context;
      Filename    : String;
      Charset     : String := "";
      Reparse     : Boolean := False;
      With_Trivia : Boolean := False;
      Rule        : Grammar_Rule :=
         ${Name.from_lower(_self.main_rule_name)}_Rule)
      return Analysis_Unit;
   ${ada_doc('langkit.get_unit_from_file', 3)}

   function Get_From_Buffer
     (Context     : Analysis_Context;
      Filename    : String;
      Charset     : String := "";
      Buffer      : String;
      With_Trivia : Boolean := False;
      Rule        : Grammar_Rule :=
         ${Name.from_lower(_self.main_rule_name)}_Rule)
      return Analysis_Unit;
   ${ada_doc('langkit.get_unit_from_buffer', 3)}

   procedure Remove (Context   : Analysis_Context;
                     File_Name : String);
   ${ada_doc('langkit.remove_unit', 3)}

   procedure Destroy (Context : in out Analysis_Context);
   ${ada_doc('langkit.destroy_context', 3)}

   procedure Inc_Ref (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_incref')}

   procedure Dec_Ref (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_decref')}

   procedure Reparse (Unit : Analysis_Unit; Charset : String := "");
   ${ada_doc('langkit.unit_reparse_file', 3)}

   procedure Reparse
     (Unit    : Analysis_Unit;
      Charset : String := "";
      Buffer  : String);
   ${ada_doc('langkit.unit_reparse_buffer', 3)}

   procedure Populate_Lexical_Env (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_populate_lexical_env')}

   function Has_Diagnostics (Unit : Analysis_Unit) return Boolean;
   ${ada_doc('langkit.unit_has_diagnostics', 3)}

   function Diagnostics (Unit : Analysis_Unit) return Diagnostics_Array;
   ${ada_doc('langkit.unit_diagnostics', 3)}

   function Root (Unit : Analysis_Unit) return ${root_node_type_name};
   ${ada_doc('langkit.unit_root', 3)}

   procedure Dump_Lexical_Env (Unit : Analysis_Unit);
   --  Debug helper: output the lexical envs for given analysis unit

   procedure Print (Unit : Analysis_Unit);
   --  Debug helper: output the AST and eventual diagnostic for this unit on
   --  standard output.

   procedure PP_Trivia (Unit : Analysis_Unit);
   --  Debug helper: output a minimal AST with mixed trivias

private

   type Analysis_Context_Type;
   type Analysis_Unit_Type;

   type Analysis_Context is access all Analysis_Context_Type;
   type Analysis_Unit is access all Analysis_Unit_Type;

   package Units_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Unbounded_String,
      Element_Type    => Analysis_Unit,
      Hash            => Ada.Strings.Unbounded.Hash,
      Equivalent_Keys => "=");

   type Analysis_Context_Type is record
      Units_Map : Units_Maps.Map;
      Symbols   : Symbol_Table;

      Charset   : Unbounded_String;
      --  Default charset to use in analysis units

      Root_Scope      : AST_Envs.Lexical_Env;
      --  The lexical scope that is shared amongst every compilation unit. Used
      --  to resolve cross file references.
   end record;

   type Analysis_Unit_Type is new Analysis_Unit_Interface_Type with
   record
      Context         : Analysis_Context;
      Ref_Count       : Natural;
      AST_Root        : ${root_node_type_name};
      File_Name       : Unbounded_String;
      Charset         : Unbounded_String;
      TDH             : aliased Token_Data_Handler;
      Diagnostics     : Diagnostics_Vectors.Vector;
      With_Trivia     : Boolean;

      Rule            : Grammar_Rule;
      --  The grammar rule used to parse this unit

      AST_Mem_Pool    : Bump_Ptr_Pool;
      --  This memory pool shall only be used for AST parsing. Stored here
      --  because it is more convenient, but one shall not allocate from it.
   end record;

   function Root (Unit : Analysis_Unit) return ${root_node_type_name} is
     (Unit.AST_Root);

end ${_self.ada_api_settings.lib_name}.Analysis;
