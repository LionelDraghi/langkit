from __future__ import absolute_import, division, print_function

from langkit.dsl import ASTNode, BoolType
from langkit.expressions import langkit_property
from langkit.parsers import Grammar

from utils import emit_and_print_errors


class FooNode(ASTNode):
    @langkit_property(public=True)
    def prop(a=BoolType):
        return a


class Example(FooNode):
    @langkit_property()
    def prop(b=BoolType):
        return b


grammar = Grammar('main_rule')
grammar.add_rules(
    main_rule=Example('example'),
)
emit_and_print_errors(grammar)
print('Done')
