# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-apple-darwin %s -o %t.o
# RUN: not lld -flavor darwinnew -o %t %t.o 2>&1 | FileCheck %s -DFILE=%t.o
# CHECK: error: section from [[FILE]] conflicts with synthetic section __DATA_CONST,__got

.globl _main

.section __DATA_CONST,__got
.space 1

.text
_main:
  mov $0, %rax
  ret
