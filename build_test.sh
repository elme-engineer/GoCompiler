#!/bin/bash

yacc -dv -Wcounterexamples gocompiler.y
# Run lex to generate the C file from gocompiler.l
lex gocompiler.l

# Check if lex was successful
if [ $? -ne 0 ]; then
    exit 1
fi

# Compile the generated lex.yy.c using clang-14
clang-14 y.tab.c goast.c lex.yy.c -o gocompiler_test -DDEBUG -DYYDEBUG

# Check if clang-14 was successful
if [ $? -ne 0 ]; then
    exit 1
fi