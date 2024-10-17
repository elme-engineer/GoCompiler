#!/bin/sh
rm -f gocompiler lex.yy.c
lex gocompiler.l
clang-14 -o gocompiler lex.yy.c -Wall -Wno-unused-function
