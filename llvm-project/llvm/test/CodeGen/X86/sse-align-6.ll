; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- | FileCheck %s

define <2 x i64> @bar(<2 x i64>* %p, <2 x i64> %x) nounwind {
; CHECK-LABEL: bar:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movdqu (%rdi), %xmm1
; CHECK-NEXT:    movdqa %xmm0, %xmm2
; CHECK-NEXT:    psrlq $32, %xmm2
; CHECK-NEXT:    pmuludq %xmm1, %xmm2
; CHECK-NEXT:    movdqa %xmm1, %xmm3
; CHECK-NEXT:    psrlq $32, %xmm3
; CHECK-NEXT:    pmuludq %xmm0, %xmm3
; CHECK-NEXT:    paddq %xmm2, %xmm3
; CHECK-NEXT:    psllq $32, %xmm3
; CHECK-NEXT:    pmuludq %xmm1, %xmm0
; CHECK-NEXT:    paddq %xmm3, %xmm0
; CHECK-NEXT:    retq
  %t = load <2 x i64>, <2 x i64>* %p, align 8
  %z = mul <2 x i64> %t, %x
  ret <2 x i64> %z
}