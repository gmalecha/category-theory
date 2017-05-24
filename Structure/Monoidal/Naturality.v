Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Theory.Morphisms.
Require Export Category.Theory.Isomorphism.
Require Export Category.Theory.Naturality.
Require Export Category.Functor.Bifunctor.
Require Export Category.Construction.Product.
Require Export Category.Structure.Monoidal.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.

Section MonoidalNaturality.

Context `{M : @Monoidal C}.

Global Program Definition Tensor_Left {F : C ⟶ C} {Y : C} : C ⟶ C := {|
  fobj := fun X => (F X ⨂ Y)%object;
  fmap := fun _ _ f => fmap[F] f ⨂[M] id
|}.
Next Obligation.
  proper.
  apply bimap_respects.
    rewrite X0; reflexivity.
  reflexivity.
Defined.
Next Obligation. normal; reflexivity. Qed.

Global Program Instance Tensor_Left_Map `{@CanonicalMap C P} {Y : C} :
  @CanonicalMap C (fun X => P X ⨂ Y)%object := {
  map := fun _ _ f => map f ⨂ id;
  is_functor := @Tensor_Left is_functor _
}.
Next Obligation.
  unfold Tensor_Left_Map_obligation_1.
  apply bifunctor_respects; simpl; split.
    apply fobj_related.
  reflexivity.
Defined.
Next Obligation.
  unfold Tensor_Left_Map_obligation_1;
  unfold Tensor_Left_Map_obligation_2; simpl.
  rewrite fmap_related.
  normal; reflexivity.
Qed.

Global Program Instance Tensor_Right {F : C ⟶ C} {X : C} : C ⟶ C := {
  fobj := fun Y => (X ⨂ F Y)%object;
  fmap := fun _ _ f => id ⨂[M] fmap[F] f
}.
Next Obligation.
  proper.
  apply bimap_respects.
    reflexivity.
  rewrite X1; reflexivity.
Qed.
Next Obligation. normal; reflexivity. Qed.

Global Program Instance Tensor_Right_Map `{@CanonicalMap C P} {X : C} :
  @CanonicalMap C (fun Y => X ⨂ P Y)%object := {
  map := fun _ _ f => id ⨂ map f;
  is_functor := @Tensor_Right is_functor _
}.
Next Obligation.
  unfold Tensor_Left_Map_obligation_1.
  apply bifunctor_respects; simpl; split.
    reflexivity.
  apply fobj_related.
Defined.
Next Obligation.
  unfold Tensor_Left_Map_obligation_1;
  unfold Tensor_Left_Map_obligation_2; simpl.
  rewrite fmap_related.
  normal; reflexivity.
Qed.

Global Program Definition Tensor_Both `{F : C ⟶ C} : C ⟶ C := {|
  fobj := fun X => (F X ⨂ F X)%object;
  fmap := fun _ _ f => fmap[F] f ⨂[M] fmap[F] f
|}.
Next Obligation.
  proper.
  apply bimap_respects;
  rewrite X0; reflexivity.
Qed.
Next Obligation. normal; reflexivity. Qed.

Global Program Instance Tensor_Both_Map `{@CanonicalMap C P} :
  @CanonicalMap C (fun X => P X ⨂ P X)%object := {
  map := fun _ _ f => map f ⨂ map f;
  is_functor := @Tensor_Both is_functor
}.
Next Obligation.
  apply bifunctor_respects; simpl; split;
  apply fobj_related.
Defined.
Next Obligation.
  rewrite fmap_related.
  normal; reflexivity.
Qed.

Theorem monoidal_naturality :
  natural (@unit_left _ M) *
  natural (@unit_right _ M) *
  natural (@tensor_assoc _ M).
Proof. prove_naturality M normal. Qed.

End MonoidalNaturality.