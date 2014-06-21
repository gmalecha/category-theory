Require Export Coq.Classes.Equivalence.
Require Export Coq.Classes.Morphisms.
Require Export Coq.Classes.RelationClasses.
Require Export Coq.Logic.FunctionalExtensionality.
Require Export Coq.Setoids.Setoid.
Require        Setoid.

(* Proof General seems to add an extra two columns of overhead *)
Set Printing Width 130.
Generalizable All Variables.

(* Unicode → is used to describe morphisms, even though it is rather similar
   to the way ASCII -> is displayed in Emacs.

   Unicode ≈ means equivalence.

   Unicode ∘ is composition of morphisms.

   {C}-> specifically types a morphism from category C.
*)
Reserved Notation "a → b" (at level 90, right associativity).
Reserved Notation "f ≈ g" (at level 54).
Reserved Notation "f ∘ g" (at level 45).

(* A Category is defined by objects, and morphisms between objects, plus the
   following structure:

   - Every object has an identity morphism.
   - Morphisms may be compose.

   - There is some notion of equivalence between objects in the category,
     where the weakest form is just isomorphism.
   - Composition must respect equivalence.

   - Composition respect the monoid laws: left and right identity, plus
     associativity.
*)
Class Category (Ob : Type) (Hom : Ob -> Ob -> Type) :=
{ hom := Hom where "a → b" := (hom a b)
; ob  := Ob

; id : forall {A}, A → A
; compose : forall {A B C}, (B → C) -> (A → B) -> (A → C)
  where "f ∘ g" := (compose f g)
; eqv : forall {A B}, (A → B) -> (A → B) -> Prop where "f ≈ g" := (eqv f g)

; eqv_equivalence : forall {A B}, Equivalence (@eqv A B)
; compose_respects : forall {A B C}, Proper (@eqv B C ==> @eqv A B ==> @eqv A C) compose

; right_identity : forall {A B} (f : A → B), f ∘ id ≈ f
; left_identity : forall {A B} (f : A → B), id ∘ f ≈ f
; comp_assoc : forall {A B C D} (f : C → D) (g : B → C) (h : A → B) ,
    f ∘ (g ∘ h) ≈ (f ∘ g) ∘ h
}.

Coercion ob : Category >-> Sortclass.

Notation "a → b" := (hom a b) : category_scope.
Notation "f ≈ g" := (eqv f g) : category_scope.
Notation "f ∘ g" := (compose f g) : category_scope.
Notation "a -{ C }-> b" := (@hom _ _ C a b) (at level 100) : category_scope.

Open Scope category_scope.

Hint Extern 3 => apply compose_respects.
Hint Extern 1 => apply left_identity.
Hint Extern 1 => apply right_identity.

Add Parametric Relation
  (Ob : Type) (Hom : Ob -> Ob -> Type)
  (C : Category Ob Hom) (a b : Ob) : (hom a b) (@eqv _ _ C a b)

  reflexivity proved by  (@Equivalence_Reflexive  _ _ eqv_equivalence)
  symmetry proved by     (@Equivalence_Symmetric  _ _ eqv_equivalence)
  transitivity proved by (@Equivalence_Transitive _ _ eqv_equivalence)
    as parametric_relation_eqv.

  Add Parametric Morphism `(c:Category Ob Hom) (a b c : Ob)
    : (@compose _ _ _ a b c)
    with signature (eqv ==> eqv ==> eqv) as parametric_morphism_comp.
    auto.
  Defined.

Hint Constructors Equivalence.
Hint Unfold Reflexive.
Hint Unfold Symmetric.
Hint Unfold Transitive.
Hint Extern 1 (Proper _ _) => unfold Proper; auto.
Hint Extern 1 (Reflexive ?X) => unfold Reflexive; auto.
Hint Extern 1 (Symmetric ?X) => unfold Symmetric; intros; auto.
Hint Extern 1 (Transitive ?X) => unfold Transitive; intros; auto.
Hint Extern 1 (Equivalence ?X) => apply Build_Equivalence.
Hint Extern 8 (respectful _ _ _ _) => unfold respectful; auto.

Hint Extern 4 (?A ≈ ?A) => reflexivity.
Hint Extern 6 (?X ≈ ?Y) => apply Equivalence_Symmetric.
Hint Extern 7 (?X ≈ ?Z) => match goal
  with [H : ?X ≈ ?Y, H' : ?Y ≈ ?Z |- ?X ≈ ?Z] => transitivity Y end.
Hint Extern 10 (?X ∘ ?Y ≈ ?Z ∘ ?Q) => apply compose_respects; auto.

(* handy for rewriting *)
Lemma juggle1
  : forall `{C : Category} `(f : d → e) `(g : c → d) `(h : b → c) `(k : a → b),
  ((f ∘ g) ∘ h) ∘ k ≈ f ∘ (g ∘ h) ∘ k.
  intros; repeat setoid_rewrite <- comp_assoc. reflexivity.
  Defined.

Lemma juggle2
  : forall `{C : Category} `(f : d → e) `(g : c → d) `(h : b → c) `(k : a → b),
  f ∘ (g ∘ (h ∘ k)) ≈ f ∘ (g ∘ h) ∘ k.
  intros; repeat setoid_rewrite <- comp_assoc. reflexivity.
  Defined.

Lemma juggle3
  : forall `{C : Category} `(f : d → e) `(g : c → d) `(h : b → c) `(k : a → b),
  (f ∘ g) ∘ (h ∘ k) ≈ f ∘ (g ∘ h) ∘ k.
  intros; repeat setoid_rewrite <- comp_assoc. reflexivity.
  Defined.

Global Instance Coq : Category Type (fun X Y => X -> Y) :=
{ id      := fun _ x => x
; compose := fun _ _ _ f g x => f (g x)
; eqv     := fun _ _ f g => f = g
}.
Proof.
  - (* eqv_equivalence *)
    intros. apply Build_Equivalence.
    unfold Reflexive. reflexivity.
    unfold Symmetric. intros. rewrite H. reflexivity.
    unfold Transitive. intros. rewrite H. rewrite H0. reflexivity.

  - (* compose_respects *)
    intros. unfold Proper. unfold respectful.
    intros. rewrite H0. rewrite H. reflexivity.

  - (* right_identity *)   intros. reflexivity.
  - (* left_identity *)    intros. reflexivity.
  - (* comp_assoc *)       intros. reflexivity.
Defined.

Typeclasses Transparent Coq.

Definition homomorphisms A := A -> A -> Type.

Record category := mkCat
{ objs : Type
; homs : homomorphisms objs
; cat  : Category objs homs
}.

Class Functor `(C : Category objC homC, D : Category objD homD)
  (Fobj : C -> D) :=
{ functor_fobj := Fobj
; fmap : forall {X Y}, (X → Y) -> Fobj X → Fobj Y
; fmap_respects : forall X Y (f f' : X → Y), f ≈ f' -> fmap f ≈ fmap f'
; functor_law_1 : forall {X : objC}, fmap (@id objC homC C X) ≈ id
; functor_law_2 : forall {X Y Z} (f : Y → Z) (g : X → Y),
    fmap f ∘ fmap g ≈ fmap (f ∘ g)
}.
  (* register "fmap" so we can rewrite through it *)
  Implicit Arguments fmap          [ objC homC objD homD C D Fobj X Y   ].
  Implicit Arguments fmap_respects [ objC homC objD homD C D Fobj X Y   ].
  Implicit Arguments functor_law_1 [ objC homC objD homD C D Fobj       ].
  Implicit Arguments functor_law_2 [ objC homC objD homD C D Fobj X Y Z ].

  Notation "F \ f" := (fmap F f) (at level 100) : category_scope.

  Add Parametric Morphism `(C1 : Category, C2 : Category)
    (Fobj : C1 -> C2)
    (F : Functor C1 C2 Fobj)
    (a b : C1)
    : (@fmap _ _ C1 _ _ C2 Fobj F a b)
    with signature ((@eqv C1 _ C1 a b) ==> (@eqv C2 _ C2 (Fobj a) (Fobj b)))
      as parametric_morphism_fmap'.
    intros; apply (@fmap_respects _ _ C1 _ _ C2 Fobj F a b x y); auto.
  Defined.

Coercion functor_fobj : Functor >-> Funclass.

Inductive Either `(C : Category objC homC) (X Y : ob)  :=
  | Left : objC -> Either C X Y
  | Right : objC -> Either C X Y.

Definition Either_map
  `(C : Category objC homC)
  (f : objC -> objC) E X Y (x : Either C E X) : Either C E Y :=
  match x with
   | Left e => Left C E Y e
   | Right x' => Right C E Y (f x')
  end.

Definition Either_Functor
   `(C : Category objC homC)
   (E : objC) : Functor C C (Either C E).
  apply Build_Functor with (fmap := Either_map).
  - intros. 
  (* fun_composition *).
  - Abort.