; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32IF

; Exercises the ILP32 calling convention code in the case that f32 is a legal
; type. As well as testing that lowering is correct, these tests also aim to
; check that floating point load/store or integer load/store is chosen
; optimally when floats are passed on the stack.

define float @onstack_f32_noop(i64 %a, i64 %b, i64 %c, i64 %d, float %e, float %f) nounwind {
; RV32IF-LABEL: onstack_f32_noop:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    lw a0, 4(sp)
; RV32IF-NEXT:    ret
  ret float %f
}

define float @onstack_f32_fadd(i64 %a, i64 %b, i64 %c, i64 %d, float %e, float %f) nounwind {
; RV32IF-LABEL: onstack_f32_fadd:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    flw ft0, 4(sp)
; RV32IF-NEXT:    flw ft1, 0(sp)
; RV32IF-NEXT:    fadd.s ft0, ft1, ft0
; RV32IF-NEXT:    fmv.x.w a0, ft0
; RV32IF-NEXT:    ret
  %1 = fadd float %e, %f
  ret float %1
}

define float @caller_onstack_f32_noop(float %a) nounwind {
; RV32IF-LABEL: caller_onstack_f32_noop:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    addi sp, sp, -16
; RV32IF-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IF-NEXT:    sw a0, 4(sp)
; RV32IF-NEXT:    lui a1, 264704
; RV32IF-NEXT:    addi a0, zero, 1
; RV32IF-NEXT:    addi a2, zero, 2
; RV32IF-NEXT:    addi a4, zero, 3
; RV32IF-NEXT:    addi a6, zero, 4
; RV32IF-NEXT:    sw a1, 0(sp)
; RV32IF-NEXT:    mv a1, zero
; RV32IF-NEXT:    mv a3, zero
; RV32IF-NEXT:    mv a5, zero
; RV32IF-NEXT:    mv a7, zero
; RV32IF-NEXT:    call onstack_f32_noop@plt
; RV32IF-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IF-NEXT:    addi sp, sp, 16
; RV32IF-NEXT:    ret
  %1 = call float @onstack_f32_noop(i64 1, i64 2, i64 3, i64 4, float 5.0, float %a)
  ret float %1
}

define float @caller_onstack_f32_fadd(float %a, float %b) nounwind {
; RV32IF-LABEL: caller_onstack_f32_fadd:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    addi sp, sp, -16
; RV32IF-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IF-NEXT:    fmv.w.x ft0, a1
; RV32IF-NEXT:    fmv.w.x ft1, a0
; RV32IF-NEXT:    fadd.s ft2, ft1, ft0
; RV32IF-NEXT:    fsub.s ft0, ft0, ft1
; RV32IF-NEXT:    fsw ft0, 4(sp)
; RV32IF-NEXT:    addi a0, zero, 1
; RV32IF-NEXT:    addi a2, zero, 2
; RV32IF-NEXT:    addi a4, zero, 3
; RV32IF-NEXT:    addi a6, zero, 4
; RV32IF-NEXT:    fsw ft2, 0(sp)
; RV32IF-NEXT:    mv a1, zero
; RV32IF-NEXT:    mv a3, zero
; RV32IF-NEXT:    mv a5, zero
; RV32IF-NEXT:    mv a7, zero
; RV32IF-NEXT:    call onstack_f32_noop@plt
; RV32IF-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IF-NEXT:    addi sp, sp, 16
; RV32IF-NEXT:    ret
  %1 = fadd float %a, %b
  %2 = fsub float %b, %a
  %3 = call float @onstack_f32_noop(i64 1, i64 2, i64 3, i64 4, float %1, float %2)
  ret float %3
}