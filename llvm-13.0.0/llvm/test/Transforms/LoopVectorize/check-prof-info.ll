; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt  -passes="print<block-freq>,loop-vectorize" -force-vector-width=4 -force-vector-interleave=1 -S < %s |  FileCheck %s
; RUN: opt  -passes="print<block-freq>,loop-vectorize" -force-vector-width=4 -force-vector-interleave=4 -S < %s |  FileCheck %s -check-prefix=CHECK-MASKED

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@a = dso_local global [1024 x i32] zeroinitializer, align 16
@b = dso_local global [1024 x i32] zeroinitializer, align 16

; Check correctness of profile info for vectorization without epilog.
; Function Attrs: nofree norecurse nounwind uwtable
define dso_local void @_Z3foov() local_unnamed_addr #0 {
; CHECK-LABEL: @_Z3foov(
; CHECK:  [[VECTOR_BODY:vector\.body]]:
; CHECK:    br i1 [[TMP:%.*]], label [[MIDDLE_BLOCK:%.*]], label %[[VECTOR_BODY]], !prof [[LP1_255:\!.*]],
; CHECK:  [[FOR_BODY:for\.body]]:
; CHECK:    br i1 [[EXITCOND:%.*]], label [[FOR_END_LOOPEXIT:%.*]], label %[[FOR_BODY]], !prof [[LP0_0:\!.*]],
; CHECK-MASKED:  [[VECTOR_BODY:vector\.body]]:
; CHECK-MASKED:    br i1 [[TMP:%.*]], label [[MIDDLE_BLOCK:%.*]], label %[[VECTOR_BODY]], !prof [[LP1_63:\!.*]],
; CHECK-MASKED:  [[FOR_BODY:for\.body]]:
; CHECK-MASKED:    br i1 [[EXITCOND:%.*]], label [[FOR_END_LOOPEXIT:%.*]], label %[[FOR_BODY]], !prof [[LP0_0:\!.*]],
;
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds [1024 x i32], [1024 x i32]* @b, i64 0, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %1 = trunc i64 %indvars.iv to i32
  %mul = mul nsw i32 %0, %1
  %arrayidx2 = getelementptr inbounds [1024 x i32], [1024 x i32]* @a, i64 0, i64 %indvars.iv
  %2 = load i32, i32* %arrayidx2, align 4, !tbaa !2
  %add = add nsw i32 %2, %mul
  store i32 %add, i32* %arrayidx2, align 4, !tbaa !2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 1024
  br i1 %exitcond, label %for.cond.cleanup, label %for.body, !prof !6
}

; Check correctness of profile info for vectorization with epilog.
; Function Attrs: nofree norecurse nounwind uwtable
define dso_local void @_Z3foo2v() local_unnamed_addr #0 {
; CHECK-LABEL: @_Z3foo2v(
; CHECK:  [[VECTOR_BODY:vector\.body]]:
; CHECK:    br i1 [[TMP:%.*]], label [[MIDDLE_BLOCK:%.*]], label %[[VECTOR_BODY]], !prof [[LP1_255:\!.*]],
; CHECK:  [[FOR_BODY:for\.body]]:
; CHECK:    br i1 [[EXITCOND:%.*]], label [[FOR_END_LOOPEXIT:%.*]], label %[[FOR_BODY]], !prof [[LP1_2:\!.*]],
; CHECK-MASKED:  [[VECTOR_BODY:vector\.body]]:
; CHECK-MASKED:    br i1 [[TMP:%.*]], label [[MIDDLE_BLOCK:%.*]], label %[[VECTOR_BODY]], !prof [[LP1_63:\!.*]],
; CHECK-MASKED:  [[FOR_BODY:for\.body]]:
; CHECK-MASKED:    br i1 [[EXITCOND:%.*]], label [[FOR_END_LOOPEXIT:%.*]], label %[[FOR_BODY]], !prof [[LP1_2:\!.*]],
;
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds [1024 x i32], [1024 x i32]* @b, i64 0, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !2
  %1 = trunc i64 %indvars.iv to i32
  %mul = mul nsw i32 %0, %1
  %arrayidx2 = getelementptr inbounds [1024 x i32], [1024 x i32]* @a, i64 0, i64 %indvars.iv
  %2 = load i32, i32* %arrayidx2, align 4, !tbaa !2
  %add = add nsw i32 %2, %mul
  store i32 %add, i32* %arrayidx2, align 4, !tbaa !2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 1027
  br i1 %exitcond, label %for.cond.cleanup, label %for.body, !prof !7
}

attributes #0 = { "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

; CHECK: [[LP1_255]] = !{!"branch_weights", i32 1, i32 255}
; CHECK: [[LP0_0]] = !{!"branch_weights", i32 0, i32 0}
; CHECK-MASKED: [[LP1_63]] = !{!"branch_weights", i32 1, i32 63}
; CHECK-MASKED: [[LP0_0]] = !{!"branch_weights", i32 0, i32 0}
; CHECK: [[LP1_2]] = !{!"branch_weights", i32 1, i32 2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project c292b5b5e059e6ce3e6449e6827ef7e1037c21c4)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!"branch_weights", i32 1, i32 1023}
!7 = !{!"branch_weights", i32 1, i32 1026}