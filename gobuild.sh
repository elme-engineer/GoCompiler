#!/bin/sh
rm -f gocompiler lex.yy.c y.tab.c y.tab.h
yacc -d -v -t -g -Wcounterexamples --report=all gocompiler.y
lex gocompiler.l
clang-14 -g -o gocompiler lex.yy.c y.tab.c goast.c