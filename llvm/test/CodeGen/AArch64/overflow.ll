; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=arm64-eabi -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK,SDAG
; RUN: llc < %s -mtriple=arm64-eabi -global-isel -global-isel-abort=2 -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK,GISEL


define zeroext i1 @saddo1.i32.unused(i32 %v1, i32 %v2, ptr %res) {
; CHECK-LABEL: saddo1.i32.unused:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    add w8, w0, w1
; CHECK-NEXT:    mov w0, #1 // =0x1
; CHECK-NEXT:    str w8, [x2]
; CHECK-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 %v1, i32 %v2)
  %obit = extractvalue {i32, i1} %t, 1
  %val = extractvalue {i32, i1} %t, 0
  store i32 %val, ptr %res
  ret i1 1
}

define zeroext i1 @saddo1.i32.fold(i32 %v1, i32 %v2, ptr %res) {
; SDAG-LABEL: saddo1.i32.fold:
; SDAG:       // %bb.0: // %entry
; SDAG-NEXT:    mov w8, #20 // =0x14
; SDAG-NEXT:    mov w0, wzr
; SDAG-NEXT:    str w8, [x2]
; SDAG-NEXT:    ret
;
; GISEL-LABEL: saddo1.i32.fold:
; GISEL:       // %bb.0: // %entry
; GISEL-NEXT:    mov w8, #9 // =0x9
; GISEL-NEXT:    adds w8, w8, #11
; GISEL-NEXT:    cset w0, vs
; GISEL-NEXT:    str w8, [x2]
; GISEL-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 9, i32 11)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define zeroext i1 @saddo1.i32.addzero(i32 %v1, i32 %v2, ptr %res) {
; CHECK-LABEL: saddo1.i32.addzero:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    mov w8, w0
; CHECK-NEXT:    mov w0, wzr
; CHECK-NEXT:    str w8, [x2]
; CHECK-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 %v1, i32 0)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define zeroext i1 @uaddo1.i32.addzero(i32 %v1, i32 %v2, ptr %res) {
; CHECK-LABEL: uaddo1.i32.addzero:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    mov w8, w0
; CHECK-NEXT:    mov w0, wzr
; CHECK-NEXT:    str w8, [x2]
; CHECK-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %v1, i32 0)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define i32 @saddo.select.i64(i32 %v1, i32 %v2, i1 %v3, i64 %v4, i64 %v5) {
; SDAG-LABEL: saddo.select.i64:
; SDAG:       // %bb.0: // %entry
; SDAG-NEXT:    mov w0, w1
; SDAG-NEXT:    ret
;
; GISEL-LABEL: saddo.select.i64:
; GISEL:       // %bb.0: // %entry
; GISEL-NEXT:    mov w8, #13 // =0xd
; GISEL-NEXT:    and x9, x3, #0xc
; GISEL-NEXT:    and x8, x4, x8
; GISEL-NEXT:    cmn x9, x8
; GISEL-NEXT:    cset w8, vs
; GISEL-NEXT:    tst w8, #0x1
; GISEL-NEXT:    csel w0, w0, w1, ne
; GISEL-NEXT:    ret
entry:
  %lhs = and i64 %v4, 12
  %rhs = and i64 %v5, 13
  %t = call {i64, i1} @llvm.sadd.with.overflow.64(i64 %lhs, i64 %rhs)
  %obit = extractvalue {i64, i1} %t, 1
  %ret = select i1 %obit, i32 %v1, i32 %v2
  ret i32 %ret
}

define i32 @uaddo.select.i64(i32 %v1, i32 %v2, i1 %v3, i64 %v4, i64 %v5) {
; SDAG-LABEL: uaddo.select.i64:
; SDAG:       // %bb.0: // %entry
; SDAG-NEXT:    mov w0, w1
; SDAG-NEXT:    ret
;
; GISEL-LABEL: uaddo.select.i64:
; GISEL:       // %bb.0: // %entry
; GISEL-NEXT:    mov w8, #9 // =0x9
; GISEL-NEXT:    mov w9, #10 // =0xa
; GISEL-NEXT:    and x8, x3, x8
; GISEL-NEXT:    and x9, x4, x9
; GISEL-NEXT:    cmn x8, x9
; GISEL-NEXT:    cset w8, hs
; GISEL-NEXT:    tst w8, #0x1
; GISEL-NEXT:    csel w0, w0, w1, ne
; GISEL-NEXT:    ret
entry:
  %lhs = and i64 %v4, 9
  %rhs = and i64 %v5, 10
  %t = call {i64, i1} @llvm.uadd.with.overflow.64(i64 %lhs, i64 %rhs)
  %obit = extractvalue {i64, i1} %t, 1
  %ret = select i1 %obit, i32 %v1, i32 %v2
  ret i32 %ret
}

define zeroext i1 @saddo.canon.i32(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; SDAG-LABEL: saddo.canon.i32:
; SDAG:       // %bb.0: // %entry
; SDAG-NEXT:    mov w0, wzr
; SDAG-NEXT:    str w4, [x5]
; SDAG-NEXT:    ret
;
; GISEL-LABEL: saddo.canon.i32:
; GISEL:       // %bb.0: // %entry
; GISEL-NEXT:    adds w8, wzr, w4
; GISEL-NEXT:    cset w0, vs
; GISEL-NEXT:    str w8, [x5]
; GISEL-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 0, i32 %v5)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}
define zeroext i1 @saddo.add.i32(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; CHECK-LABEL: saddo.add.i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    add w8, w4, #100
; CHECK-NEXT:    subs w8, w8, #100
; CHECK-NEXT:    cset w0, vs
; CHECK-NEXT:    str w8, [x5]
; CHECK-NEXT:    ret
entry:
  %lhs = add nsw i32 %v5, 100
  %t = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 %lhs, i32 -100)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define zeroext i1 @uaddo.add.i32(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; CHECK-LABEL: uaddo.add.i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    add w8, w4, #5
; CHECK-NEXT:    adds w8, w8, #5
; CHECK-NEXT:    cset w0, hs
; CHECK-NEXT:    str w8, [x5]
; CHECK-NEXT:    ret
entry:
  %lhs = add nuw i32 %v5, 5
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %lhs, i32 5)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define zeroext i1 @uaddo.negative.i32(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; CHECK-LABEL: uaddo.negative.i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adds w8, w3, #5
; CHECK-NEXT:    cset w0, hs
; CHECK-NEXT:    str w8, [x5]
; CHECK-NEXT:    ret
entry:
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %v4, i32 5)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

define i32 @saddo.always.i8(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; CHECK-LABEL: saddo.always.i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    mov w0, w1
; CHECK-NEXT:    ret
entry:
  %t = call {i8, i1} @llvm.sadd.with.overflow.i8(i8 255, i8 254)
  %obit = extractvalue {i8, i1} %t, 1
  %ret = select i1 %obit, i32 %v1, i32 %v2
  ret i32 %ret
}

define i32 @uaddo.never.i8(i32 %v1, i32 %v2, i32 %v3, i32 %v4, i32 %v5, ptr %res) {
; CHECK-LABEL: uaddo.never.i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    mov w0, w1
; CHECK-NEXT:    ret
entry:
  %t = call {i8, i1} @llvm.uadd.with.overflow.i8(i8 2, i8 1)
  %obit = extractvalue {i8, i1} %t, 1
  %ret = select i1 %obit, i32 %v1, i32 %v2
  ret i32 %ret
}


declare {i8, i1} @llvm.sadd.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.sadd.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.sadd.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.sadd.with.overflow.i64(i64, i64) nounwind readnone
declare {i8, i1} @llvm.uadd.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.uadd.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.uadd.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.uadd.with.overflow.i64(i64, i64) nounwind readnone
declare {i8, i1} @llvm.ssub.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.ssub.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.ssub.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.ssub.with.overflow.i64(i64, i64) nounwind readnone
declare {i8, i1} @llvm.usub.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.usub.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.usub.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64) nounwind readnone
declare {i8, i1} @llvm.smul.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.smul.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.smul.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.smul.with.overflow.i64(i64, i64) nounwind readnone
declare {i8, i1} @llvm.umul.with.overflow.i8(i8, i8) nounwind readnone
declare {i16, i1} @llvm.umul.with.overflow.i16(i16, i16) nounwind readnone
declare {i32, i1} @llvm.umul.with.overflow.i32(i32, i32) nounwind readnone
declare {i64, i1} @llvm.umul.with.overflow.i64(i64, i64) nounwind readnone
