
// ** Expanded prelude

// Copyright (c) The Diem Core Contributors
// Copyright (c) The Move Contributors
// SPDX-License-Identifier: Apache-2.0

// Basic theory for vectors using arrays. This version of vectors is not extensional.

type {:datatype} Vec _;

function {:constructor} Vec<T>(v: [int]T, l: int): Vec T;

function {:builtin "MapConst"} MapConstVec<T>(T): [int]T;
function DefaultVecElem<T>(): T;
function {:inline} DefaultVecMap<T>(): [int]T { MapConstVec(DefaultVecElem()) }

function {:inline} EmptyVec<T>(): Vec T {
    Vec(DefaultVecMap(), 0)
}

function {:inline} MakeVec1<T>(v: T): Vec T {
    Vec(DefaultVecMap()[0 := v], 1)
}

function {:inline} MakeVec2<T>(v1: T, v2: T): Vec T {
    Vec(DefaultVecMap()[0 := v1][1 := v2], 2)
}

function {:inline} MakeVec3<T>(v1: T, v2: T, v3: T): Vec T {
    Vec(DefaultVecMap()[0 := v1][1 := v2][2 := v3], 3)
}

function {:inline} MakeVec4<T>(v1: T, v2: T, v3: T, v4: T): Vec T {
    Vec(DefaultVecMap()[0 := v1][1 := v2][2 := v3][3 := v4], 4)
}

function {:inline} ExtendVec<T>(v: Vec T, elem: T): Vec T {
    (var l := l#Vec(v);
    Vec(v#Vec(v)[l := elem], l + 1))
}

function {:inline} ReadVec<T>(v: Vec T, i: int): T {
    v#Vec(v)[i]
}

function {:inline} LenVec<T>(v: Vec T): int {
    l#Vec(v)
}

function {:inline} IsEmptyVec<T>(v: Vec T): bool {
    l#Vec(v) == 0
}

function {:inline} RemoveVec<T>(v: Vec T): Vec T {
    (var l := l#Vec(v) - 1;
    Vec(v#Vec(v)[l := DefaultVecElem()], l))
}

function {:inline} RemoveAtVec<T>(v: Vec T, i: int): Vec T {
    (var l := l#Vec(v) - 1;
    Vec(
        (lambda j: int ::
           if j >= 0 && j < l then
               if j < i then v#Vec(v)[j] else v#Vec(v)[j+1]
           else DefaultVecElem()),
        l))
}

function {:inline} ConcatVec<T>(v1: Vec T, v2: Vec T): Vec T {
    (var l1, m1, l2, m2 := l#Vec(v1), v#Vec(v1), l#Vec(v2), v#Vec(v2);
    Vec(
        (lambda i: int ::
          if i >= 0 && i < l1 + l2 then
            if i < l1 then m1[i] else m2[i - l1]
          else DefaultVecElem()),
        l1 + l2))
}

function {:inline} ReverseVec<T>(v: Vec T): Vec T {
    (var l := l#Vec(v);
    Vec(
        (lambda i: int :: if 0 <= i && i < l then v#Vec(v)[l - i - 1] else DefaultVecElem()),
        l))
}

function {:inline} SliceVec<T>(v: Vec T, i: int, j: int): Vec T {
    (var m := v#Vec(v);
    Vec(
        (lambda k:int ::
          if 0 <= k && k < j - i then
            m[i + k]
          else
            DefaultVecElem()),
        (if j - i < 0 then 0 else j - i)))
}


function {:inline} UpdateVec<T>(v: Vec T, i: int, elem: T): Vec T {
    Vec(v#Vec(v)[i := elem], l#Vec(v))
}

function {:inline} SwapVec<T>(v: Vec T, i: int, j: int): Vec T {
    (var m := v#Vec(v);
    Vec(m[i := m[j]][j := m[i]], l#Vec(v)))
}

function {:inline} ContainsVec<T>(v: Vec T, e: T): bool {
    (var l := l#Vec(v);
    (exists i: int :: InRangeVec(v, i) && v#Vec(v)[i] == e))
}

function IndexOfVec<T>(v: Vec T, e: T): int;
axiom {:ctor "Vec"} (forall<T> v: Vec T, e: T :: {IndexOfVec(v, e)}
    (var i := IndexOfVec(v,e);
     if (!ContainsVec(v, e)) then i == -1
     else InRangeVec(v, i) && ReadVec(v, i) == e &&
        (forall j: int :: j >= 0 && j < i ==> ReadVec(v, j) != e)));

// This function should stay non-inlined as it guards many quantifiers
// over vectors. It appears important to have this uninterpreted for
// quantifier triggering.
function InRangeVec<T>(v: Vec T, i: int): bool {
    i >= 0 && i < LenVec(v)
}

// Copyright (c) The Diem Core Contributors
// Copyright (c) The Move Contributors
// SPDX-License-Identifier: Apache-2.0

// Boogie model for multisets, based on Boogie arrays. This theory assumes extensional equality for element types.

type {:datatype} Multiset _;
function {:constructor} Multiset<T>(v: [T]int, l: int): Multiset T;

function {:builtin "MapConst"} MapConstMultiset<T>(l: int): [T]int;

function {:inline} EmptyMultiset<T>(): Multiset T {
    Multiset(MapConstMultiset(0), 0)
}

function {:inline} LenMultiset<T>(s: Multiset T): int {
    l#Multiset(s)
}

function {:inline} ExtendMultiset<T>(s: Multiset T, v: T): Multiset T {
    (var len := l#Multiset(s);
    (var cnt := v#Multiset(s)[v];
    Multiset(v#Multiset(s)[v := (cnt + 1)], len + 1)))
}

// This function returns (s1 - s2). This function assumes that s2 is a subset of s1.
function {:inline} SubtractMultiset<T>(s1: Multiset T, s2: Multiset T): Multiset T {
    (var len1 := l#Multiset(s1);
    (var len2 := l#Multiset(s2);
    Multiset((lambda v:T :: v#Multiset(s1)[v]-v#Multiset(s2)[v]), len1-len2)))
}

function {:inline} IsEmptyMultiset<T>(s: Multiset T): bool {
    (l#Multiset(s) == 0) &&
    (forall v: T :: v#Multiset(s)[v] == 0)
}

function {:inline} IsSubsetMultiset<T>(s1: Multiset T, s2: Multiset T): bool {
    (l#Multiset(s1) <= l#Multiset(s2)) &&
    (forall v: T :: v#Multiset(s1)[v] <= v#Multiset(s2)[v])
}

function {:inline} ContainsMultiset<T>(s: Multiset T, v: T): bool {
    v#Multiset(s)[v] > 0
}

// Copyright (c) The Diem Core Contributors
// Copyright (c) The Move Contributors
// SPDX-License-Identifier: Apache-2.0

// Theory for tables.

type {:datatype} Table _ _;

// v is the SMT array holding the key-value assignment. e is an array which
// independently determines whether a key is valid or not. l is the length.
//
// Note that even though the program cannot reflect over existence of a key,
// we want the specification to be able to do this, so it can express
// verification conditions like "key has been inserted".
function {:constructor} Table<K, V>(v: [K]V, e: [K]bool, l: int): Table K V;

// Functions for default SMT arrays. For the table values, we don't care and
// use an uninterpreted function.
function DefaultTableArray<K, V>(): [K]V;
function DefaultTableKeyExistsArray<K>(): [K]bool;
axiom DefaultTableKeyExistsArray() == (lambda i: int :: false);

function {:inline} EmptyTable<K, V>(): Table K V {
    Table(DefaultTableArray(), DefaultTableKeyExistsArray(), 0)
}

function {:inline} GetTable<K,V>(t: Table K V, k: K): V {
    // Notice we do not check whether key is in the table. The result is undetermined if it is not.
    v#Table(t)[k]
}

function {:inline} LenTable<K,V>(t: Table K V): int {
    l#Table(t)
}


function {:inline} ContainsTable<K,V>(t: Table K V, k: K): bool {
    e#Table(t)[k]
}

function {:inline} UpdateTable<K,V>(t: Table K V, k: K, v: V): Table K V {
    Table(v#Table(t)[k := v], e#Table(t)[k := true], l#Table(t))
}

function {:inline} AddTable<K,V>(t: Table K V, k: K, v: V): Table K V {
    // This function has an undetermined result if the key is already in the table
    // (all specification functions have this "partial definiteness" behavior). Thus we can
    // just increment the length.
    Table(v#Table(t)[k := v], e#Table(t)[k := true], l#Table(t) + 1)
}

function {:inline} RemoveTable<K,V>(t: Table K V, k: K): Table K V {
    // Similar as above, we only need to consider the case where the key is in the table.
    Table(v#Table(t), e#Table(t)[k := false], l#Table(t) - 1)
}

axiom {:ctor "Table"} (forall<K,V> t: Table K V :: {LenTable(t)}
    (exists k: K :: {ContainsTable(t, k)} ContainsTable(t, k)) ==> LenTable(t) >= 1
);
// TODO: we might want to encoder a stronger property that the length of table
// must be more than N given a set of N items. Currently we don't see a need here
// and the above axiom seems to be sufficient.


// ============================================================================================
// Primitive Types

const $MAX_U8: int;
axiom $MAX_U8 == 255;
const $MAX_U16: int;
axiom $MAX_U16 == 65535;
const $MAX_U32: int;
axiom $MAX_U32 == 4294967295;
const $MAX_U64: int;
axiom $MAX_U64 == 18446744073709551615;
const $MAX_U128: int;
axiom $MAX_U128 == 340282366920938463463374607431768211455;
const $MAX_U256: int;
axiom $MAX_U256 == 115792089237316195423570985008687907853269984665640564039457584007913129639935;

// Templates for bitvector operations

function {:bvbuiltin "bvand"} $And'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvor"} $Or'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvxor"} $Xor'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvadd"} $Add'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvsub"} $Sub'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvmul"} $Mul'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvudiv"} $Div'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvurem"} $Mod'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvshl"} $Shl'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvlshr"} $Shr'Bv8'(bv8,bv8) returns(bv8);
function {:bvbuiltin "bvult"} $Lt'Bv8'(bv8,bv8) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv8'(bv8,bv8) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv8'(bv8,bv8) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv8'(bv8,bv8) returns(bool);

procedure {:inline 1} $AddBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if ($Lt'Bv8'($Add'Bv8'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv8'(src1, src2);
}

procedure {:inline 1} $AddBv8_unchecked(src1: bv8, src2: bv8) returns (dst: bv8)
{
    dst := $Add'Bv8'(src1, src2);
}

procedure {:inline 1} $SubBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if ($Lt'Bv8'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv8'(src1, src2);
}

procedure {:inline 1} $MulBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if ($Lt'Bv8'($Mul'Bv8'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv8'(src1, src2);
}

procedure {:inline 1} $DivBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if (src2 == 0bv8) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv8'(src1, src2);
}

procedure {:inline 1} $ModBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if (src2 == 0bv8) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv8'(src1, src2);
}

procedure {:inline 1} $AndBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    dst := $And'Bv8'(src1,src2);
}

procedure {:inline 1} $OrBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    dst := $Or'Bv8'(src1,src2);
}

procedure {:inline 1} $XorBv8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    dst := $Xor'Bv8'(src1,src2);
}

procedure {:inline 1} $LtBv8(src1: bv8, src2: bv8) returns (dst: bool)
{
    dst := $Lt'Bv8'(src1,src2);
}

procedure {:inline 1} $LeBv8(src1: bv8, src2: bv8) returns (dst: bool)
{
    dst := $Le'Bv8'(src1,src2);
}

procedure {:inline 1} $GtBv8(src1: bv8, src2: bv8) returns (dst: bool)
{
    dst := $Gt'Bv8'(src1,src2);
}

procedure {:inline 1} $GeBv8(src1: bv8, src2: bv8) returns (dst: bool)
{
    dst := $Ge'Bv8'(src1,src2);
}

function $IsValid'bv8'(v: bv8): bool {
  $Ge'Bv8'(v,0bv8) && $Le'Bv8'(v,255bv8)
}

function {:inline} $IsEqual'bv8'(x: bv8, y: bv8): bool {
    x == y
}

procedure {:inline 1} $int2bv8(src: int) returns (dst: bv8)
{
    if (src > 255) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.8(src);
}

procedure {:inline 1} $bv2int8(src: bv8) returns (dst: int)
{
    dst := $bv2int.8(src);
}

function {:builtin "(_ int2bv 8)"} $int2bv.8(i: int) returns (bv8);
function {:builtin "bv2nat"} $bv2int.8(i: bv8) returns (int);

function {:bvbuiltin "bvand"} $And'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvor"} $Or'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvxor"} $Xor'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvadd"} $Add'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvsub"} $Sub'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvmul"} $Mul'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvudiv"} $Div'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvurem"} $Mod'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvshl"} $Shl'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvlshr"} $Shr'Bv16'(bv16,bv16) returns(bv16);
function {:bvbuiltin "bvult"} $Lt'Bv16'(bv16,bv16) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv16'(bv16,bv16) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv16'(bv16,bv16) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv16'(bv16,bv16) returns(bool);

procedure {:inline 1} $AddBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if ($Lt'Bv16'($Add'Bv16'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv16'(src1, src2);
}

procedure {:inline 1} $AddBv16_unchecked(src1: bv16, src2: bv16) returns (dst: bv16)
{
    dst := $Add'Bv16'(src1, src2);
}

procedure {:inline 1} $SubBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if ($Lt'Bv16'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv16'(src1, src2);
}

procedure {:inline 1} $MulBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if ($Lt'Bv16'($Mul'Bv16'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv16'(src1, src2);
}

procedure {:inline 1} $DivBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if (src2 == 0bv16) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv16'(src1, src2);
}

procedure {:inline 1} $ModBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if (src2 == 0bv16) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv16'(src1, src2);
}

procedure {:inline 1} $AndBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    dst := $And'Bv16'(src1,src2);
}

procedure {:inline 1} $OrBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    dst := $Or'Bv16'(src1,src2);
}

procedure {:inline 1} $XorBv16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    dst := $Xor'Bv16'(src1,src2);
}

procedure {:inline 1} $LtBv16(src1: bv16, src2: bv16) returns (dst: bool)
{
    dst := $Lt'Bv16'(src1,src2);
}

procedure {:inline 1} $LeBv16(src1: bv16, src2: bv16) returns (dst: bool)
{
    dst := $Le'Bv16'(src1,src2);
}

procedure {:inline 1} $GtBv16(src1: bv16, src2: bv16) returns (dst: bool)
{
    dst := $Gt'Bv16'(src1,src2);
}

procedure {:inline 1} $GeBv16(src1: bv16, src2: bv16) returns (dst: bool)
{
    dst := $Ge'Bv16'(src1,src2);
}

function $IsValid'bv16'(v: bv16): bool {
  $Ge'Bv16'(v,0bv16) && $Le'Bv16'(v,65535bv16)
}

function {:inline} $IsEqual'bv16'(x: bv16, y: bv16): bool {
    x == y
}

procedure {:inline 1} $int2bv16(src: int) returns (dst: bv16)
{
    if (src > 65535) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.16(src);
}

procedure {:inline 1} $bv2int16(src: bv16) returns (dst: int)
{
    dst := $bv2int.16(src);
}

function {:builtin "(_ int2bv 16)"} $int2bv.16(i: int) returns (bv16);
function {:builtin "bv2nat"} $bv2int.16(i: bv16) returns (int);

function {:bvbuiltin "bvand"} $And'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvor"} $Or'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvxor"} $Xor'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvadd"} $Add'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvsub"} $Sub'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvmul"} $Mul'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvudiv"} $Div'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvurem"} $Mod'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvshl"} $Shl'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvlshr"} $Shr'Bv32'(bv32,bv32) returns(bv32);
function {:bvbuiltin "bvult"} $Lt'Bv32'(bv32,bv32) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv32'(bv32,bv32) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv32'(bv32,bv32) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv32'(bv32,bv32) returns(bool);

procedure {:inline 1} $AddBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if ($Lt'Bv32'($Add'Bv32'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv32'(src1, src2);
}

procedure {:inline 1} $AddBv32_unchecked(src1: bv32, src2: bv32) returns (dst: bv32)
{
    dst := $Add'Bv32'(src1, src2);
}

procedure {:inline 1} $SubBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if ($Lt'Bv32'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv32'(src1, src2);
}

procedure {:inline 1} $MulBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if ($Lt'Bv32'($Mul'Bv32'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv32'(src1, src2);
}

procedure {:inline 1} $DivBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if (src2 == 0bv32) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv32'(src1, src2);
}

procedure {:inline 1} $ModBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if (src2 == 0bv32) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv32'(src1, src2);
}

procedure {:inline 1} $AndBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    dst := $And'Bv32'(src1,src2);
}

procedure {:inline 1} $OrBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    dst := $Or'Bv32'(src1,src2);
}

procedure {:inline 1} $XorBv32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    dst := $Xor'Bv32'(src1,src2);
}

procedure {:inline 1} $LtBv32(src1: bv32, src2: bv32) returns (dst: bool)
{
    dst := $Lt'Bv32'(src1,src2);
}

procedure {:inline 1} $LeBv32(src1: bv32, src2: bv32) returns (dst: bool)
{
    dst := $Le'Bv32'(src1,src2);
}

procedure {:inline 1} $GtBv32(src1: bv32, src2: bv32) returns (dst: bool)
{
    dst := $Gt'Bv32'(src1,src2);
}

procedure {:inline 1} $GeBv32(src1: bv32, src2: bv32) returns (dst: bool)
{
    dst := $Ge'Bv32'(src1,src2);
}

function $IsValid'bv32'(v: bv32): bool {
  $Ge'Bv32'(v,0bv32) && $Le'Bv32'(v,2147483647bv32)
}

function {:inline} $IsEqual'bv32'(x: bv32, y: bv32): bool {
    x == y
}

procedure {:inline 1} $int2bv32(src: int) returns (dst: bv32)
{
    if (src > 2147483647) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.32(src);
}

procedure {:inline 1} $bv2int32(src: bv32) returns (dst: int)
{
    dst := $bv2int.32(src);
}

function {:builtin "(_ int2bv 32)"} $int2bv.32(i: int) returns (bv32);
function {:builtin "bv2nat"} $bv2int.32(i: bv32) returns (int);

function {:bvbuiltin "bvand"} $And'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvor"} $Or'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvxor"} $Xor'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvadd"} $Add'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvsub"} $Sub'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvmul"} $Mul'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvudiv"} $Div'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvurem"} $Mod'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvshl"} $Shl'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvlshr"} $Shr'Bv64'(bv64,bv64) returns(bv64);
function {:bvbuiltin "bvult"} $Lt'Bv64'(bv64,bv64) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv64'(bv64,bv64) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv64'(bv64,bv64) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv64'(bv64,bv64) returns(bool);

procedure {:inline 1} $AddBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if ($Lt'Bv64'($Add'Bv64'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv64'(src1, src2);
}

procedure {:inline 1} $AddBv64_unchecked(src1: bv64, src2: bv64) returns (dst: bv64)
{
    dst := $Add'Bv64'(src1, src2);
}

procedure {:inline 1} $SubBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if ($Lt'Bv64'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv64'(src1, src2);
}

procedure {:inline 1} $MulBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if ($Lt'Bv64'($Mul'Bv64'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv64'(src1, src2);
}

procedure {:inline 1} $DivBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if (src2 == 0bv64) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv64'(src1, src2);
}

procedure {:inline 1} $ModBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if (src2 == 0bv64) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv64'(src1, src2);
}

procedure {:inline 1} $AndBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    dst := $And'Bv64'(src1,src2);
}

procedure {:inline 1} $OrBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    dst := $Or'Bv64'(src1,src2);
}

procedure {:inline 1} $XorBv64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    dst := $Xor'Bv64'(src1,src2);
}

procedure {:inline 1} $LtBv64(src1: bv64, src2: bv64) returns (dst: bool)
{
    dst := $Lt'Bv64'(src1,src2);
}

procedure {:inline 1} $LeBv64(src1: bv64, src2: bv64) returns (dst: bool)
{
    dst := $Le'Bv64'(src1,src2);
}

procedure {:inline 1} $GtBv64(src1: bv64, src2: bv64) returns (dst: bool)
{
    dst := $Gt'Bv64'(src1,src2);
}

procedure {:inline 1} $GeBv64(src1: bv64, src2: bv64) returns (dst: bool)
{
    dst := $Ge'Bv64'(src1,src2);
}

function $IsValid'bv64'(v: bv64): bool {
  $Ge'Bv64'(v,0bv64) && $Le'Bv64'(v,18446744073709551615bv64)
}

function {:inline} $IsEqual'bv64'(x: bv64, y: bv64): bool {
    x == y
}

procedure {:inline 1} $int2bv64(src: int) returns (dst: bv64)
{
    if (src > 18446744073709551615) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.64(src);
}

procedure {:inline 1} $bv2int64(src: bv64) returns (dst: int)
{
    dst := $bv2int.64(src);
}

function {:builtin "(_ int2bv 64)"} $int2bv.64(i: int) returns (bv64);
function {:builtin "bv2nat"} $bv2int.64(i: bv64) returns (int);

function {:bvbuiltin "bvand"} $And'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvor"} $Or'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvxor"} $Xor'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvadd"} $Add'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvsub"} $Sub'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvmul"} $Mul'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvudiv"} $Div'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvurem"} $Mod'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvshl"} $Shl'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvlshr"} $Shr'Bv128'(bv128,bv128) returns(bv128);
function {:bvbuiltin "bvult"} $Lt'Bv128'(bv128,bv128) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv128'(bv128,bv128) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv128'(bv128,bv128) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv128'(bv128,bv128) returns(bool);

procedure {:inline 1} $AddBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if ($Lt'Bv128'($Add'Bv128'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv128'(src1, src2);
}

procedure {:inline 1} $AddBv128_unchecked(src1: bv128, src2: bv128) returns (dst: bv128)
{
    dst := $Add'Bv128'(src1, src2);
}

procedure {:inline 1} $SubBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if ($Lt'Bv128'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv128'(src1, src2);
}

procedure {:inline 1} $MulBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if ($Lt'Bv128'($Mul'Bv128'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv128'(src1, src2);
}

procedure {:inline 1} $DivBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if (src2 == 0bv128) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv128'(src1, src2);
}

procedure {:inline 1} $ModBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if (src2 == 0bv128) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv128'(src1, src2);
}

procedure {:inline 1} $AndBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    dst := $And'Bv128'(src1,src2);
}

procedure {:inline 1} $OrBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    dst := $Or'Bv128'(src1,src2);
}

procedure {:inline 1} $XorBv128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    dst := $Xor'Bv128'(src1,src2);
}

procedure {:inline 1} $LtBv128(src1: bv128, src2: bv128) returns (dst: bool)
{
    dst := $Lt'Bv128'(src1,src2);
}

procedure {:inline 1} $LeBv128(src1: bv128, src2: bv128) returns (dst: bool)
{
    dst := $Le'Bv128'(src1,src2);
}

procedure {:inline 1} $GtBv128(src1: bv128, src2: bv128) returns (dst: bool)
{
    dst := $Gt'Bv128'(src1,src2);
}

procedure {:inline 1} $GeBv128(src1: bv128, src2: bv128) returns (dst: bool)
{
    dst := $Ge'Bv128'(src1,src2);
}

function $IsValid'bv128'(v: bv128): bool {
  $Ge'Bv128'(v,0bv128) && $Le'Bv128'(v,340282366920938463463374607431768211455bv128)
}

function {:inline} $IsEqual'bv128'(x: bv128, y: bv128): bool {
    x == y
}

procedure {:inline 1} $int2bv128(src: int) returns (dst: bv128)
{
    if (src > 340282366920938463463374607431768211455) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.128(src);
}

procedure {:inline 1} $bv2int128(src: bv128) returns (dst: int)
{
    dst := $bv2int.128(src);
}

function {:builtin "(_ int2bv 128)"} $int2bv.128(i: int) returns (bv128);
function {:builtin "bv2nat"} $bv2int.128(i: bv128) returns (int);

function {:bvbuiltin "bvand"} $And'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvor"} $Or'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvxor"} $Xor'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvadd"} $Add'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvsub"} $Sub'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvmul"} $Mul'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvudiv"} $Div'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvurem"} $Mod'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvshl"} $Shl'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvlshr"} $Shr'Bv256'(bv256,bv256) returns(bv256);
function {:bvbuiltin "bvult"} $Lt'Bv256'(bv256,bv256) returns(bool);
function {:bvbuiltin "bvule"} $Le'Bv256'(bv256,bv256) returns(bool);
function {:bvbuiltin "bvugt"} $Gt'Bv256'(bv256,bv256) returns(bool);
function {:bvbuiltin "bvuge"} $Ge'Bv256'(bv256,bv256) returns(bool);

procedure {:inline 1} $AddBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if ($Lt'Bv256'($Add'Bv256'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Add'Bv256'(src1, src2);
}

procedure {:inline 1} $AddBv256_unchecked(src1: bv256, src2: bv256) returns (dst: bv256)
{
    dst := $Add'Bv256'(src1, src2);
}

procedure {:inline 1} $SubBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if ($Lt'Bv256'(src1, src2)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Sub'Bv256'(src1, src2);
}

procedure {:inline 1} $MulBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if ($Lt'Bv256'($Mul'Bv256'(src1, src2), src1)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mul'Bv256'(src1, src2);
}

procedure {:inline 1} $DivBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if (src2 == 0bv256) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Div'Bv256'(src1, src2);
}

procedure {:inline 1} $ModBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if (src2 == 0bv256) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mod'Bv256'(src1, src2);
}

procedure {:inline 1} $AndBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    dst := $And'Bv256'(src1,src2);
}

procedure {:inline 1} $OrBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    dst := $Or'Bv256'(src1,src2);
}

procedure {:inline 1} $XorBv256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    dst := $Xor'Bv256'(src1,src2);
}

procedure {:inline 1} $LtBv256(src1: bv256, src2: bv256) returns (dst: bool)
{
    dst := $Lt'Bv256'(src1,src2);
}

procedure {:inline 1} $LeBv256(src1: bv256, src2: bv256) returns (dst: bool)
{
    dst := $Le'Bv256'(src1,src2);
}

procedure {:inline 1} $GtBv256(src1: bv256, src2: bv256) returns (dst: bool)
{
    dst := $Gt'Bv256'(src1,src2);
}

procedure {:inline 1} $GeBv256(src1: bv256, src2: bv256) returns (dst: bool)
{
    dst := $Ge'Bv256'(src1,src2);
}

function $IsValid'bv256'(v: bv256): bool {
  $Ge'Bv256'(v,0bv256) && $Le'Bv256'(v,115792089237316195423570985008687907853269984665640564039457584007913129639935bv256)
}

function {:inline} $IsEqual'bv256'(x: bv256, y: bv256): bool {
    x == y
}

procedure {:inline 1} $int2bv256(src: int) returns (dst: bv256)
{
    if (src > 115792089237316195423570985008687907853269984665640564039457584007913129639935) {
        call $ExecFailureAbort();
        return;
    }
    dst := $int2bv.256(src);
}

procedure {:inline 1} $bv2int256(src: bv256) returns (dst: int)
{
    dst := $bv2int.256(src);
}

function {:builtin "(_ int2bv 256)"} $int2bv.256(i: int) returns (bv256);
function {:builtin "bv2nat"} $bv2int.256(i: bv256) returns (int);

type {:datatype} $Range;
function {:constructor} $Range(lb: int, ub: int): $Range;

function {:inline} $IsValid'bool'(v: bool): bool {
  true
}

function $IsValid'u8'(v: int): bool {
  v >= 0 && v <= $MAX_U8
}

function $IsValid'u16'(v: int): bool {
  v >= 0 && v <= $MAX_U16
}

function $IsValid'u32'(v: int): bool {
  v >= 0 && v <= $MAX_U32
}

function $IsValid'u64'(v: int): bool {
  v >= 0 && v <= $MAX_U64
}

function $IsValid'u128'(v: int): bool {
  v >= 0 && v <= $MAX_U128
}

function $IsValid'u256'(v: int): bool {
  v >= 0 && v <= $MAX_U256
}

function $IsValid'num'(v: int): bool {
  true
}

function $IsValid'address'(v: int): bool {
  // TODO: restrict max to representable addresses?
  v >= 0
}

function {:inline} $IsValidRange(r: $Range): bool {
   $IsValid'u64'(lb#$Range(r)) &&  $IsValid'u64'(ub#$Range(r))
}

// Intentionally not inlined so it serves as a trigger in quantifiers.
function $InRange(r: $Range, i: int): bool {
   lb#$Range(r) <= i && i < ub#$Range(r)
}


function {:inline} $IsEqual'u8'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'u16'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'u32'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'u64'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'u128'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'u256'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'num'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'address'(x: int, y: int): bool {
    x == y
}

function {:inline} $IsEqual'bool'(x: bool, y: bool): bool {
    x == y
}

// ============================================================================================
// Memory

type {:datatype} $Location;

// A global resource location within the statically known resource type's memory,
// where `a` is an address.
function {:constructor} $Global(a: int): $Location;

// A local location. `i` is the unique index of the local.
function {:constructor} $Local(i: int): $Location;

// The location of a reference outside of the verification scope, for example, a `&mut` parameter
// of the function being verified. References with these locations don't need to be written back
// when mutation ends.
function {:constructor} $Param(i: int): $Location;

// The location of an uninitialized mutation. Using this to make sure that the location
// will not be equal to any valid mutation locations, i.e., $Local, $Global, or $Param.
function {:constructor} $Uninitialized(): $Location;

// A mutable reference which also carries its current value. Since mutable references
// are single threaded in Move, we can keep them together and treat them as a value
// during mutation until the point they are stored back to their original location.
type {:datatype} $Mutation _;
function {:constructor} $Mutation<T>(l: $Location, p: Vec int, v: T): $Mutation T;

// Representation of memory for a given type.
type {:datatype} $Memory _;
function {:constructor} $Memory<T>(domain: [int]bool, contents: [int]T): $Memory T;

function {:builtin "MapConst"} $ConstMemoryDomain(v: bool): [int]bool;
function {:builtin "MapConst"} $ConstMemoryContent<T>(v: T): [int]T;
axiom $ConstMemoryDomain(false) == (lambda i: int :: false);
axiom $ConstMemoryDomain(true) == (lambda i: int :: true);


// Dereferences a mutation.
function {:inline} $Dereference<T>(ref: $Mutation T): T {
    v#$Mutation(ref)
}

// Update the value of a mutation.
function {:inline} $UpdateMutation<T>(m: $Mutation T, v: T): $Mutation T {
    $Mutation(l#$Mutation(m), p#$Mutation(m), v)
}

function {:inline} $ChildMutation<T1, T2>(m: $Mutation T1, offset: int, v: T2): $Mutation T2 {
    $Mutation(l#$Mutation(m), ExtendVec(p#$Mutation(m), offset), v)
}

// Return true if two mutations share the location and path
function {:inline} $IsSameMutation<T1, T2>(parent: $Mutation T1, child: $Mutation T2 ): bool {
    l#$Mutation(parent) == l#$Mutation(child) && p#$Mutation(parent) == p#$Mutation(child)
}

// Return true if the mutation is a parent of a child which was derived with the given edge offset. This
// is used to implement write-back choices.
function {:inline} $IsParentMutation<T1, T2>(parent: $Mutation T1, edge: int, child: $Mutation T2 ): bool {
    l#$Mutation(parent) == l#$Mutation(child) &&
    (var pp := p#$Mutation(parent);
    (var cp := p#$Mutation(child);
    (var pl := LenVec(pp);
    (var cl := LenVec(cp);
     cl == pl + 1 &&
     (forall i: int:: i >= 0 && i < pl ==> ReadVec(pp, i) ==  ReadVec(cp, i)) &&
     $EdgeMatches(ReadVec(cp, pl), edge)
    ))))
}

// Return true if the mutation is a parent of a child, for hyper edge.
function {:inline} $IsParentMutationHyper<T1, T2>(parent: $Mutation T1, hyper_edge: Vec int, child: $Mutation T2 ): bool {
    l#$Mutation(parent) == l#$Mutation(child) &&
    (var pp := p#$Mutation(parent);
    (var cp := p#$Mutation(child);
    (var pl := LenVec(pp);
    (var cl := LenVec(cp);
    (var el := LenVec(hyper_edge);
     cl == pl + el &&
     (forall i: int:: i >= 0 && i < pl ==> ReadVec(pp, i) == ReadVec(cp, i)) &&
     (forall i: int:: i >= 0 && i < el ==> $EdgeMatches(ReadVec(cp, pl + i), ReadVec(hyper_edge, i)))
    )))))
}

function {:inline} $EdgeMatches(edge: int, edge_pattern: int): bool {
    edge_pattern == -1 // wildcard
    || edge_pattern == edge
}



function {:inline} $SameLocation<T1, T2>(m1: $Mutation T1, m2: $Mutation T2): bool {
    l#$Mutation(m1) == l#$Mutation(m2)
}

function {:inline} $HasGlobalLocation<T>(m: $Mutation T): bool {
    is#$Global(l#$Mutation(m))
}

function {:inline} $HasLocalLocation<T>(m: $Mutation T, idx: int): bool {
    l#$Mutation(m) == $Local(idx)
}

function {:inline} $GlobalLocationAddress<T>(m: $Mutation T): int {
    a#$Global(l#$Mutation(m))
}



// Tests whether resource exists.
function {:inline} $ResourceExists<T>(m: $Memory T, addr: int): bool {
    domain#$Memory(m)[addr]
}

// Obtains Value of given resource.
function {:inline} $ResourceValue<T>(m: $Memory T, addr: int): T {
    contents#$Memory(m)[addr]
}

// Update resource.
function {:inline} $ResourceUpdate<T>(m: $Memory T, a: int, v: T): $Memory T {
    $Memory(domain#$Memory(m)[a := true], contents#$Memory(m)[a := v])
}

// Remove resource.
function {:inline} $ResourceRemove<T>(m: $Memory T, a: int): $Memory T {
    $Memory(domain#$Memory(m)[a := false], contents#$Memory(m))
}

// Copies resource from memory s to m.
function {:inline} $ResourceCopy<T>(m: $Memory T, s: $Memory T, a: int): $Memory T {
    $Memory(domain#$Memory(m)[a := domain#$Memory(s)[a]],
            contents#$Memory(m)[a := contents#$Memory(s)[a]])
}



// ============================================================================================
// Abort Handling

var $abort_flag: bool;
var $abort_code: int;

function {:inline} $process_abort_code(code: int): int {
    code
}

const $EXEC_FAILURE_CODE: int;
axiom $EXEC_FAILURE_CODE == -1;

// TODO(wrwg): currently we map aborts of native functions like those for vectors also to
//   execution failure. This may need to be aligned with what the runtime actually does.

procedure {:inline 1} $ExecFailureAbort() {
    $abort_flag := true;
    $abort_code := $EXEC_FAILURE_CODE;
}

procedure {:inline 1} $Abort(code: int) {
    $abort_flag := true;
    $abort_code := code;
}

function {:inline} $StdError(cat: int, reason: int): int {
    reason * 256 + cat
}

procedure {:inline 1} $InitVerification() {
    // Set abort_flag to false, and havoc abort_code
    $abort_flag := false;
    havoc $abort_code;
    // Initialize event store
    call $InitEventStore();
}

// ============================================================================================
// Instructions


procedure {:inline 1} $CastU8(src: int) returns (dst: int)
{
    if (src > $MAX_U8) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $CastU16(src: int) returns (dst: int)
{
    if (src > $MAX_U16) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $CastU32(src: int) returns (dst: int)
{
    if (src > $MAX_U32) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $CastU64(src: int) returns (dst: int)
{
    if (src > $MAX_U64) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $CastU128(src: int) returns (dst: int)
{
    if (src > $MAX_U128) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $CastU256(src: int) returns (dst: int)
{
    if (src > $MAX_U256) {
        call $ExecFailureAbort();
        return;
    }
    dst := src;
}

procedure {:inline 1} $AddU8(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U8) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU16(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U16) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU16_unchecked(src1: int, src2: int) returns (dst: int)
{
    dst := src1 + src2;
}

procedure {:inline 1} $AddU32(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U32) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU32_unchecked(src1: int, src2: int) returns (dst: int)
{
    dst := src1 + src2;
}

procedure {:inline 1} $AddU64(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U64) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU64_unchecked(src1: int, src2: int) returns (dst: int)
{
    dst := src1 + src2;
}

procedure {:inline 1} $AddU128(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U128) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU128_unchecked(src1: int, src2: int) returns (dst: int)
{
    dst := src1 + src2;
}

procedure {:inline 1} $AddU256(src1: int, src2: int) returns (dst: int)
{
    if (src1 + src2 > $MAX_U256) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 + src2;
}

procedure {:inline 1} $AddU256_unchecked(src1: int, src2: int) returns (dst: int)
{
    dst := src1 + src2;
}

procedure {:inline 1} $Sub(src1: int, src2: int) returns (dst: int)
{
    if (src1 < src2) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 - src2;
}

// uninterpreted function to return an undefined value.
function $undefined_int(): int;

// Recursive exponentiation function
// Undefined unless e >=0.  $pow(0,0) is also undefined.
function $pow(n: int, e: int): int {
    if n != 0 && e == 0 then 1
    else if e > 0 then n * $pow(n, e - 1)
    else $undefined_int()
}

function $shl(src1: int, p: int): int {
    src1 * $pow(2, p)
}

function $shlU8(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 256
}

function $shlU16(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 65536
}

function $shlU32(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 4294967296
}

function $shlU64(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 18446744073709551616
}

function $shlU128(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 340282366920938463463374607431768211456
}

function $shlU256(src1: int, p: int): int {
    (src1 * $pow(2, p)) mod 115792089237316195423570985008687907853269984665640564039457584007913129639936
}

function $shr(src1: int, p: int): int {
    src1 div $pow(2, p)
}

// We need to know the size of the destination in order to drop bits
// that have been shifted left more than that, so we have $ShlU8/16/32/64/128/256
procedure {:inline 1} $ShlU8(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 8) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shlU8(src1, src2);
}

// Template for cast and shift operations of bitvector types

procedure {:inline 1} $CastBv8to8(src: bv8) returns (dst: bv8)
{
    dst := src;
}


function $shlBv8From8(src1: bv8, src2: bv8) returns (bv8)
{
    $Shl'Bv8'(src1, src2)
}

procedure {:inline 1} $ShlBv8From8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if ($Ge'Bv8'(src2, 8bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2);
}

function $shrBv8From8(src1: bv8, src2: bv8) returns (bv8)
{
    $Shr'Bv8'(src1, src2)
}

procedure {:inline 1} $ShrBv8From8(src1: bv8, src2: bv8) returns (dst: bv8)
{
    if ($Ge'Bv8'(src2, 8bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2);
}

procedure {:inline 1} $CastBv16to8(src: bv16) returns (dst: bv8)
{
    if ($Gt'Bv16'(src, 255bv16)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[8:0];
}


function $shlBv8From16(src1: bv8, src2: bv16) returns (bv8)
{
    $Shl'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShlBv8From16(src1: bv8, src2: bv16) returns (dst: bv8)
{
    if ($Ge'Bv16'(src2, 8bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2[8:0]);
}

function $shrBv8From16(src1: bv8, src2: bv16) returns (bv8)
{
    $Shr'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShrBv8From16(src1: bv8, src2: bv16) returns (dst: bv8)
{
    if ($Ge'Bv16'(src2, 8bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2[8:0]);
}

procedure {:inline 1} $CastBv32to8(src: bv32) returns (dst: bv8)
{
    if ($Gt'Bv32'(src, 255bv32)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[8:0];
}


function $shlBv8From32(src1: bv8, src2: bv32) returns (bv8)
{
    $Shl'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShlBv8From32(src1: bv8, src2: bv32) returns (dst: bv8)
{
    if ($Ge'Bv32'(src2, 8bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2[8:0]);
}

function $shrBv8From32(src1: bv8, src2: bv32) returns (bv8)
{
    $Shr'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShrBv8From32(src1: bv8, src2: bv32) returns (dst: bv8)
{
    if ($Ge'Bv32'(src2, 8bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2[8:0]);
}

procedure {:inline 1} $CastBv64to8(src: bv64) returns (dst: bv8)
{
    if ($Gt'Bv64'(src, 255bv64)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[8:0];
}


function $shlBv8From64(src1: bv8, src2: bv64) returns (bv8)
{
    $Shl'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShlBv8From64(src1: bv8, src2: bv64) returns (dst: bv8)
{
    if ($Ge'Bv64'(src2, 8bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2[8:0]);
}

function $shrBv8From64(src1: bv8, src2: bv64) returns (bv8)
{
    $Shr'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShrBv8From64(src1: bv8, src2: bv64) returns (dst: bv8)
{
    if ($Ge'Bv64'(src2, 8bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2[8:0]);
}

procedure {:inline 1} $CastBv128to8(src: bv128) returns (dst: bv8)
{
    if ($Gt'Bv128'(src, 255bv128)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[8:0];
}


function $shlBv8From128(src1: bv8, src2: bv128) returns (bv8)
{
    $Shl'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShlBv8From128(src1: bv8, src2: bv128) returns (dst: bv8)
{
    if ($Ge'Bv128'(src2, 8bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2[8:0]);
}

function $shrBv8From128(src1: bv8, src2: bv128) returns (bv8)
{
    $Shr'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShrBv8From128(src1: bv8, src2: bv128) returns (dst: bv8)
{
    if ($Ge'Bv128'(src2, 8bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2[8:0]);
}

procedure {:inline 1} $CastBv256to8(src: bv256) returns (dst: bv8)
{
    if ($Gt'Bv256'(src, 255bv256)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[8:0];
}


function $shlBv8From256(src1: bv8, src2: bv256) returns (bv8)
{
    $Shl'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShlBv8From256(src1: bv8, src2: bv256) returns (dst: bv8)
{
    if ($Ge'Bv256'(src2, 8bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv8'(src1, src2[8:0]);
}

function $shrBv8From256(src1: bv8, src2: bv256) returns (bv8)
{
    $Shr'Bv8'(src1, src2[8:0])
}

procedure {:inline 1} $ShrBv8From256(src1: bv8, src2: bv256) returns (dst: bv8)
{
    if ($Ge'Bv256'(src2, 8bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv8'(src1, src2[8:0]);
}

procedure {:inline 1} $CastBv8to16(src: bv8) returns (dst: bv16)
{
    dst := 0bv8 ++ src;
}


function $shlBv16From8(src1: bv16, src2: bv8) returns (bv16)
{
    $Shl'Bv16'(src1, 0bv8 ++ src2)
}

procedure {:inline 1} $ShlBv16From8(src1: bv16, src2: bv8) returns (dst: bv16)
{
    if ($Ge'Bv8'(src2, 16bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, 0bv8 ++ src2);
}

function $shrBv16From8(src1: bv16, src2: bv8) returns (bv16)
{
    $Shr'Bv16'(src1, 0bv8 ++ src2)
}

procedure {:inline 1} $ShrBv16From8(src1: bv16, src2: bv8) returns (dst: bv16)
{
    if ($Ge'Bv8'(src2, 16bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, 0bv8 ++ src2);
}

procedure {:inline 1} $CastBv16to16(src: bv16) returns (dst: bv16)
{
    dst := src;
}


function $shlBv16From16(src1: bv16, src2: bv16) returns (bv16)
{
    $Shl'Bv16'(src1, src2)
}

procedure {:inline 1} $ShlBv16From16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if ($Ge'Bv16'(src2, 16bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, src2);
}

function $shrBv16From16(src1: bv16, src2: bv16) returns (bv16)
{
    $Shr'Bv16'(src1, src2)
}

procedure {:inline 1} $ShrBv16From16(src1: bv16, src2: bv16) returns (dst: bv16)
{
    if ($Ge'Bv16'(src2, 16bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, src2);
}

procedure {:inline 1} $CastBv32to16(src: bv32) returns (dst: bv16)
{
    if ($Gt'Bv32'(src, 65535bv32)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[16:0];
}


function $shlBv16From32(src1: bv16, src2: bv32) returns (bv16)
{
    $Shl'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShlBv16From32(src1: bv16, src2: bv32) returns (dst: bv16)
{
    if ($Ge'Bv32'(src2, 16bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, src2[16:0]);
}

function $shrBv16From32(src1: bv16, src2: bv32) returns (bv16)
{
    $Shr'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShrBv16From32(src1: bv16, src2: bv32) returns (dst: bv16)
{
    if ($Ge'Bv32'(src2, 16bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, src2[16:0]);
}

procedure {:inline 1} $CastBv64to16(src: bv64) returns (dst: bv16)
{
    if ($Gt'Bv64'(src, 65535bv64)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[16:0];
}


function $shlBv16From64(src1: bv16, src2: bv64) returns (bv16)
{
    $Shl'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShlBv16From64(src1: bv16, src2: bv64) returns (dst: bv16)
{
    if ($Ge'Bv64'(src2, 16bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, src2[16:0]);
}

function $shrBv16From64(src1: bv16, src2: bv64) returns (bv16)
{
    $Shr'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShrBv16From64(src1: bv16, src2: bv64) returns (dst: bv16)
{
    if ($Ge'Bv64'(src2, 16bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, src2[16:0]);
}

procedure {:inline 1} $CastBv128to16(src: bv128) returns (dst: bv16)
{
    if ($Gt'Bv128'(src, 65535bv128)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[16:0];
}


function $shlBv16From128(src1: bv16, src2: bv128) returns (bv16)
{
    $Shl'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShlBv16From128(src1: bv16, src2: bv128) returns (dst: bv16)
{
    if ($Ge'Bv128'(src2, 16bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, src2[16:0]);
}

function $shrBv16From128(src1: bv16, src2: bv128) returns (bv16)
{
    $Shr'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShrBv16From128(src1: bv16, src2: bv128) returns (dst: bv16)
{
    if ($Ge'Bv128'(src2, 16bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, src2[16:0]);
}

procedure {:inline 1} $CastBv256to16(src: bv256) returns (dst: bv16)
{
    if ($Gt'Bv256'(src, 65535bv256)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[16:0];
}


function $shlBv16From256(src1: bv16, src2: bv256) returns (bv16)
{
    $Shl'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShlBv16From256(src1: bv16, src2: bv256) returns (dst: bv16)
{
    if ($Ge'Bv256'(src2, 16bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv16'(src1, src2[16:0]);
}

function $shrBv16From256(src1: bv16, src2: bv256) returns (bv16)
{
    $Shr'Bv16'(src1, src2[16:0])
}

procedure {:inline 1} $ShrBv16From256(src1: bv16, src2: bv256) returns (dst: bv16)
{
    if ($Ge'Bv256'(src2, 16bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv16'(src1, src2[16:0]);
}

procedure {:inline 1} $CastBv8to32(src: bv8) returns (dst: bv32)
{
    dst := 0bv24 ++ src;
}


function $shlBv32From8(src1: bv32, src2: bv8) returns (bv32)
{
    $Shl'Bv32'(src1, 0bv24 ++ src2)
}

procedure {:inline 1} $ShlBv32From8(src1: bv32, src2: bv8) returns (dst: bv32)
{
    if ($Ge'Bv8'(src2, 32bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, 0bv24 ++ src2);
}

function $shrBv32From8(src1: bv32, src2: bv8) returns (bv32)
{
    $Shr'Bv32'(src1, 0bv24 ++ src2)
}

procedure {:inline 1} $ShrBv32From8(src1: bv32, src2: bv8) returns (dst: bv32)
{
    if ($Ge'Bv8'(src2, 32bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, 0bv24 ++ src2);
}

procedure {:inline 1} $CastBv16to32(src: bv16) returns (dst: bv32)
{
    dst := 0bv16 ++ src;
}


function $shlBv32From16(src1: bv32, src2: bv16) returns (bv32)
{
    $Shl'Bv32'(src1, 0bv16 ++ src2)
}

procedure {:inline 1} $ShlBv32From16(src1: bv32, src2: bv16) returns (dst: bv32)
{
    if ($Ge'Bv16'(src2, 32bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, 0bv16 ++ src2);
}

function $shrBv32From16(src1: bv32, src2: bv16) returns (bv32)
{
    $Shr'Bv32'(src1, 0bv16 ++ src2)
}

procedure {:inline 1} $ShrBv32From16(src1: bv32, src2: bv16) returns (dst: bv32)
{
    if ($Ge'Bv16'(src2, 32bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, 0bv16 ++ src2);
}

procedure {:inline 1} $CastBv32to32(src: bv32) returns (dst: bv32)
{
    dst := src;
}


function $shlBv32From32(src1: bv32, src2: bv32) returns (bv32)
{
    $Shl'Bv32'(src1, src2)
}

procedure {:inline 1} $ShlBv32From32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if ($Ge'Bv32'(src2, 32bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, src2);
}

function $shrBv32From32(src1: bv32, src2: bv32) returns (bv32)
{
    $Shr'Bv32'(src1, src2)
}

procedure {:inline 1} $ShrBv32From32(src1: bv32, src2: bv32) returns (dst: bv32)
{
    if ($Ge'Bv32'(src2, 32bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, src2);
}

procedure {:inline 1} $CastBv64to32(src: bv64) returns (dst: bv32)
{
    if ($Gt'Bv64'(src, 2147483647bv64)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[32:0];
}


function $shlBv32From64(src1: bv32, src2: bv64) returns (bv32)
{
    $Shl'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShlBv32From64(src1: bv32, src2: bv64) returns (dst: bv32)
{
    if ($Ge'Bv64'(src2, 32bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, src2[32:0]);
}

function $shrBv32From64(src1: bv32, src2: bv64) returns (bv32)
{
    $Shr'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShrBv32From64(src1: bv32, src2: bv64) returns (dst: bv32)
{
    if ($Ge'Bv64'(src2, 32bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, src2[32:0]);
}

procedure {:inline 1} $CastBv128to32(src: bv128) returns (dst: bv32)
{
    if ($Gt'Bv128'(src, 2147483647bv128)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[32:0];
}


function $shlBv32From128(src1: bv32, src2: bv128) returns (bv32)
{
    $Shl'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShlBv32From128(src1: bv32, src2: bv128) returns (dst: bv32)
{
    if ($Ge'Bv128'(src2, 32bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, src2[32:0]);
}

function $shrBv32From128(src1: bv32, src2: bv128) returns (bv32)
{
    $Shr'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShrBv32From128(src1: bv32, src2: bv128) returns (dst: bv32)
{
    if ($Ge'Bv128'(src2, 32bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, src2[32:0]);
}

procedure {:inline 1} $CastBv256to32(src: bv256) returns (dst: bv32)
{
    if ($Gt'Bv256'(src, 2147483647bv256)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[32:0];
}


function $shlBv32From256(src1: bv32, src2: bv256) returns (bv32)
{
    $Shl'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShlBv32From256(src1: bv32, src2: bv256) returns (dst: bv32)
{
    if ($Ge'Bv256'(src2, 32bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv32'(src1, src2[32:0]);
}

function $shrBv32From256(src1: bv32, src2: bv256) returns (bv32)
{
    $Shr'Bv32'(src1, src2[32:0])
}

procedure {:inline 1} $ShrBv32From256(src1: bv32, src2: bv256) returns (dst: bv32)
{
    if ($Ge'Bv256'(src2, 32bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv32'(src1, src2[32:0]);
}

procedure {:inline 1} $CastBv8to64(src: bv8) returns (dst: bv64)
{
    dst := 0bv56 ++ src;
}


function $shlBv64From8(src1: bv64, src2: bv8) returns (bv64)
{
    $Shl'Bv64'(src1, 0bv56 ++ src2)
}

procedure {:inline 1} $ShlBv64From8(src1: bv64, src2: bv8) returns (dst: bv64)
{
    if ($Ge'Bv8'(src2, 64bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, 0bv56 ++ src2);
}

function $shrBv64From8(src1: bv64, src2: bv8) returns (bv64)
{
    $Shr'Bv64'(src1, 0bv56 ++ src2)
}

procedure {:inline 1} $ShrBv64From8(src1: bv64, src2: bv8) returns (dst: bv64)
{
    if ($Ge'Bv8'(src2, 64bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, 0bv56 ++ src2);
}

procedure {:inline 1} $CastBv16to64(src: bv16) returns (dst: bv64)
{
    dst := 0bv48 ++ src;
}


function $shlBv64From16(src1: bv64, src2: bv16) returns (bv64)
{
    $Shl'Bv64'(src1, 0bv48 ++ src2)
}

procedure {:inline 1} $ShlBv64From16(src1: bv64, src2: bv16) returns (dst: bv64)
{
    if ($Ge'Bv16'(src2, 64bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, 0bv48 ++ src2);
}

function $shrBv64From16(src1: bv64, src2: bv16) returns (bv64)
{
    $Shr'Bv64'(src1, 0bv48 ++ src2)
}

procedure {:inline 1} $ShrBv64From16(src1: bv64, src2: bv16) returns (dst: bv64)
{
    if ($Ge'Bv16'(src2, 64bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, 0bv48 ++ src2);
}

procedure {:inline 1} $CastBv32to64(src: bv32) returns (dst: bv64)
{
    dst := 0bv32 ++ src;
}


function $shlBv64From32(src1: bv64, src2: bv32) returns (bv64)
{
    $Shl'Bv64'(src1, 0bv32 ++ src2)
}

procedure {:inline 1} $ShlBv64From32(src1: bv64, src2: bv32) returns (dst: bv64)
{
    if ($Ge'Bv32'(src2, 64bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, 0bv32 ++ src2);
}

function $shrBv64From32(src1: bv64, src2: bv32) returns (bv64)
{
    $Shr'Bv64'(src1, 0bv32 ++ src2)
}

procedure {:inline 1} $ShrBv64From32(src1: bv64, src2: bv32) returns (dst: bv64)
{
    if ($Ge'Bv32'(src2, 64bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, 0bv32 ++ src2);
}

procedure {:inline 1} $CastBv64to64(src: bv64) returns (dst: bv64)
{
    dst := src;
}


function $shlBv64From64(src1: bv64, src2: bv64) returns (bv64)
{
    $Shl'Bv64'(src1, src2)
}

procedure {:inline 1} $ShlBv64From64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if ($Ge'Bv64'(src2, 64bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, src2);
}

function $shrBv64From64(src1: bv64, src2: bv64) returns (bv64)
{
    $Shr'Bv64'(src1, src2)
}

procedure {:inline 1} $ShrBv64From64(src1: bv64, src2: bv64) returns (dst: bv64)
{
    if ($Ge'Bv64'(src2, 64bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, src2);
}

procedure {:inline 1} $CastBv128to64(src: bv128) returns (dst: bv64)
{
    if ($Gt'Bv128'(src, 18446744073709551615bv128)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[64:0];
}


function $shlBv64From128(src1: bv64, src2: bv128) returns (bv64)
{
    $Shl'Bv64'(src1, src2[64:0])
}

procedure {:inline 1} $ShlBv64From128(src1: bv64, src2: bv128) returns (dst: bv64)
{
    if ($Ge'Bv128'(src2, 64bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, src2[64:0]);
}

function $shrBv64From128(src1: bv64, src2: bv128) returns (bv64)
{
    $Shr'Bv64'(src1, src2[64:0])
}

procedure {:inline 1} $ShrBv64From128(src1: bv64, src2: bv128) returns (dst: bv64)
{
    if ($Ge'Bv128'(src2, 64bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, src2[64:0]);
}

procedure {:inline 1} $CastBv256to64(src: bv256) returns (dst: bv64)
{
    if ($Gt'Bv256'(src, 18446744073709551615bv256)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[64:0];
}


function $shlBv64From256(src1: bv64, src2: bv256) returns (bv64)
{
    $Shl'Bv64'(src1, src2[64:0])
}

procedure {:inline 1} $ShlBv64From256(src1: bv64, src2: bv256) returns (dst: bv64)
{
    if ($Ge'Bv256'(src2, 64bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv64'(src1, src2[64:0]);
}

function $shrBv64From256(src1: bv64, src2: bv256) returns (bv64)
{
    $Shr'Bv64'(src1, src2[64:0])
}

procedure {:inline 1} $ShrBv64From256(src1: bv64, src2: bv256) returns (dst: bv64)
{
    if ($Ge'Bv256'(src2, 64bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv64'(src1, src2[64:0]);
}

procedure {:inline 1} $CastBv8to128(src: bv8) returns (dst: bv128)
{
    dst := 0bv120 ++ src;
}


function $shlBv128From8(src1: bv128, src2: bv8) returns (bv128)
{
    $Shl'Bv128'(src1, 0bv120 ++ src2)
}

procedure {:inline 1} $ShlBv128From8(src1: bv128, src2: bv8) returns (dst: bv128)
{
    if ($Ge'Bv8'(src2, 128bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, 0bv120 ++ src2);
}

function $shrBv128From8(src1: bv128, src2: bv8) returns (bv128)
{
    $Shr'Bv128'(src1, 0bv120 ++ src2)
}

procedure {:inline 1} $ShrBv128From8(src1: bv128, src2: bv8) returns (dst: bv128)
{
    if ($Ge'Bv8'(src2, 128bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, 0bv120 ++ src2);
}

procedure {:inline 1} $CastBv16to128(src: bv16) returns (dst: bv128)
{
    dst := 0bv112 ++ src;
}


function $shlBv128From16(src1: bv128, src2: bv16) returns (bv128)
{
    $Shl'Bv128'(src1, 0bv112 ++ src2)
}

procedure {:inline 1} $ShlBv128From16(src1: bv128, src2: bv16) returns (dst: bv128)
{
    if ($Ge'Bv16'(src2, 128bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, 0bv112 ++ src2);
}

function $shrBv128From16(src1: bv128, src2: bv16) returns (bv128)
{
    $Shr'Bv128'(src1, 0bv112 ++ src2)
}

procedure {:inline 1} $ShrBv128From16(src1: bv128, src2: bv16) returns (dst: bv128)
{
    if ($Ge'Bv16'(src2, 128bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, 0bv112 ++ src2);
}

procedure {:inline 1} $CastBv32to128(src: bv32) returns (dst: bv128)
{
    dst := 0bv96 ++ src;
}


function $shlBv128From32(src1: bv128, src2: bv32) returns (bv128)
{
    $Shl'Bv128'(src1, 0bv96 ++ src2)
}

procedure {:inline 1} $ShlBv128From32(src1: bv128, src2: bv32) returns (dst: bv128)
{
    if ($Ge'Bv32'(src2, 128bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, 0bv96 ++ src2);
}

function $shrBv128From32(src1: bv128, src2: bv32) returns (bv128)
{
    $Shr'Bv128'(src1, 0bv96 ++ src2)
}

procedure {:inline 1} $ShrBv128From32(src1: bv128, src2: bv32) returns (dst: bv128)
{
    if ($Ge'Bv32'(src2, 128bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, 0bv96 ++ src2);
}

procedure {:inline 1} $CastBv64to128(src: bv64) returns (dst: bv128)
{
    dst := 0bv64 ++ src;
}


function $shlBv128From64(src1: bv128, src2: bv64) returns (bv128)
{
    $Shl'Bv128'(src1, 0bv64 ++ src2)
}

procedure {:inline 1} $ShlBv128From64(src1: bv128, src2: bv64) returns (dst: bv128)
{
    if ($Ge'Bv64'(src2, 128bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, 0bv64 ++ src2);
}

function $shrBv128From64(src1: bv128, src2: bv64) returns (bv128)
{
    $Shr'Bv128'(src1, 0bv64 ++ src2)
}

procedure {:inline 1} $ShrBv128From64(src1: bv128, src2: bv64) returns (dst: bv128)
{
    if ($Ge'Bv64'(src2, 128bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, 0bv64 ++ src2);
}

procedure {:inline 1} $CastBv128to128(src: bv128) returns (dst: bv128)
{
    dst := src;
}


function $shlBv128From128(src1: bv128, src2: bv128) returns (bv128)
{
    $Shl'Bv128'(src1, src2)
}

procedure {:inline 1} $ShlBv128From128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if ($Ge'Bv128'(src2, 128bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, src2);
}

function $shrBv128From128(src1: bv128, src2: bv128) returns (bv128)
{
    $Shr'Bv128'(src1, src2)
}

procedure {:inline 1} $ShrBv128From128(src1: bv128, src2: bv128) returns (dst: bv128)
{
    if ($Ge'Bv128'(src2, 128bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, src2);
}

procedure {:inline 1} $CastBv256to128(src: bv256) returns (dst: bv128)
{
    if ($Gt'Bv256'(src, 340282366920938463463374607431768211455bv256)) {
            call $ExecFailureAbort();
            return;
    }
    dst := src[128:0];
}


function $shlBv128From256(src1: bv128, src2: bv256) returns (bv128)
{
    $Shl'Bv128'(src1, src2[128:0])
}

procedure {:inline 1} $ShlBv128From256(src1: bv128, src2: bv256) returns (dst: bv128)
{
    if ($Ge'Bv256'(src2, 128bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv128'(src1, src2[128:0]);
}

function $shrBv128From256(src1: bv128, src2: bv256) returns (bv128)
{
    $Shr'Bv128'(src1, src2[128:0])
}

procedure {:inline 1} $ShrBv128From256(src1: bv128, src2: bv256) returns (dst: bv128)
{
    if ($Ge'Bv256'(src2, 128bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv128'(src1, src2[128:0]);
}

procedure {:inline 1} $CastBv8to256(src: bv8) returns (dst: bv256)
{
    dst := 0bv248 ++ src;
}


function $shlBv256From8(src1: bv256, src2: bv8) returns (bv256)
{
    $Shl'Bv256'(src1, 0bv248 ++ src2)
}

procedure {:inline 1} $ShlBv256From8(src1: bv256, src2: bv8) returns (dst: bv256)
{
    if ($Ge'Bv8'(src2, 256bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, 0bv248 ++ src2);
}

function $shrBv256From8(src1: bv256, src2: bv8) returns (bv256)
{
    $Shr'Bv256'(src1, 0bv248 ++ src2)
}

procedure {:inline 1} $ShrBv256From8(src1: bv256, src2: bv8) returns (dst: bv256)
{
    if ($Ge'Bv8'(src2, 256bv8)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, 0bv248 ++ src2);
}

procedure {:inline 1} $CastBv16to256(src: bv16) returns (dst: bv256)
{
    dst := 0bv240 ++ src;
}


function $shlBv256From16(src1: bv256, src2: bv16) returns (bv256)
{
    $Shl'Bv256'(src1, 0bv240 ++ src2)
}

procedure {:inline 1} $ShlBv256From16(src1: bv256, src2: bv16) returns (dst: bv256)
{
    if ($Ge'Bv16'(src2, 256bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, 0bv240 ++ src2);
}

function $shrBv256From16(src1: bv256, src2: bv16) returns (bv256)
{
    $Shr'Bv256'(src1, 0bv240 ++ src2)
}

procedure {:inline 1} $ShrBv256From16(src1: bv256, src2: bv16) returns (dst: bv256)
{
    if ($Ge'Bv16'(src2, 256bv16)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, 0bv240 ++ src2);
}

procedure {:inline 1} $CastBv32to256(src: bv32) returns (dst: bv256)
{
    dst := 0bv224 ++ src;
}


function $shlBv256From32(src1: bv256, src2: bv32) returns (bv256)
{
    $Shl'Bv256'(src1, 0bv224 ++ src2)
}

procedure {:inline 1} $ShlBv256From32(src1: bv256, src2: bv32) returns (dst: bv256)
{
    if ($Ge'Bv32'(src2, 256bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, 0bv224 ++ src2);
}

function $shrBv256From32(src1: bv256, src2: bv32) returns (bv256)
{
    $Shr'Bv256'(src1, 0bv224 ++ src2)
}

procedure {:inline 1} $ShrBv256From32(src1: bv256, src2: bv32) returns (dst: bv256)
{
    if ($Ge'Bv32'(src2, 256bv32)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, 0bv224 ++ src2);
}

procedure {:inline 1} $CastBv64to256(src: bv64) returns (dst: bv256)
{
    dst := 0bv192 ++ src;
}


function $shlBv256From64(src1: bv256, src2: bv64) returns (bv256)
{
    $Shl'Bv256'(src1, 0bv192 ++ src2)
}

procedure {:inline 1} $ShlBv256From64(src1: bv256, src2: bv64) returns (dst: bv256)
{
    if ($Ge'Bv64'(src2, 256bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, 0bv192 ++ src2);
}

function $shrBv256From64(src1: bv256, src2: bv64) returns (bv256)
{
    $Shr'Bv256'(src1, 0bv192 ++ src2)
}

procedure {:inline 1} $ShrBv256From64(src1: bv256, src2: bv64) returns (dst: bv256)
{
    if ($Ge'Bv64'(src2, 256bv64)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, 0bv192 ++ src2);
}

procedure {:inline 1} $CastBv128to256(src: bv128) returns (dst: bv256)
{
    dst := 0bv128 ++ src;
}


function $shlBv256From128(src1: bv256, src2: bv128) returns (bv256)
{
    $Shl'Bv256'(src1, 0bv128 ++ src2)
}

procedure {:inline 1} $ShlBv256From128(src1: bv256, src2: bv128) returns (dst: bv256)
{
    if ($Ge'Bv128'(src2, 256bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, 0bv128 ++ src2);
}

function $shrBv256From128(src1: bv256, src2: bv128) returns (bv256)
{
    $Shr'Bv256'(src1, 0bv128 ++ src2)
}

procedure {:inline 1} $ShrBv256From128(src1: bv256, src2: bv128) returns (dst: bv256)
{
    if ($Ge'Bv128'(src2, 256bv128)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, 0bv128 ++ src2);
}

procedure {:inline 1} $CastBv256to256(src: bv256) returns (dst: bv256)
{
    dst := src;
}


function $shlBv256From256(src1: bv256, src2: bv256) returns (bv256)
{
    $Shl'Bv256'(src1, src2)
}

procedure {:inline 1} $ShlBv256From256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if ($Ge'Bv256'(src2, 256bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shl'Bv256'(src1, src2);
}

function $shrBv256From256(src1: bv256, src2: bv256) returns (bv256)
{
    $Shr'Bv256'(src1, src2)
}

procedure {:inline 1} $ShrBv256From256(src1: bv256, src2: bv256) returns (dst: bv256)
{
    if ($Ge'Bv256'(src2, 256bv256)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Shr'Bv256'(src1, src2);
}

procedure {:inline 1} $ShlU16(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 16) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shlU16(src1, src2);
}

procedure {:inline 1} $ShlU32(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 32) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shlU32(src1, src2);
}

procedure {:inline 1} $ShlU64(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 64) {
       call $ExecFailureAbort();
       return;
    }
    dst := $shlU64(src1, src2);
}

procedure {:inline 1} $ShlU128(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 128) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shlU128(src1, src2);
}

procedure {:inline 1} $ShlU256(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    dst := $shlU256(src1, src2);
}

procedure {:inline 1} $Shr(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU8(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 8) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU16(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 16) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU32(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 32) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU64(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 64) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU128(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    if (src2 >= 128) {
        call $ExecFailureAbort();
        return;
    }
    dst := $shr(src1, src2);
}

procedure {:inline 1} $ShrU256(src1: int, src2: int) returns (dst: int)
{
    var res: int;
    // src2 is a u8
    assume src2 >= 0 && src2 < 256;
    dst := $shr(src1, src2);
}

procedure {:inline 1} $MulU8(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U8) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $MulU16(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U16) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $MulU32(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U32) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $MulU64(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U64) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $MulU128(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U128) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $MulU256(src1: int, src2: int) returns (dst: int)
{
    if (src1 * src2 > $MAX_U256) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 * src2;
}

procedure {:inline 1} $Div(src1: int, src2: int) returns (dst: int)
{
    if (src2 == 0) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 div src2;
}

procedure {:inline 1} $Mod(src1: int, src2: int) returns (dst: int)
{
    if (src2 == 0) {
        call $ExecFailureAbort();
        return;
    }
    dst := src1 mod src2;
}

procedure {:inline 1} $ArithBinaryUnimplemented(src1: int, src2: int) returns (dst: int);

procedure {:inline 1} $Lt(src1: int, src2: int) returns (dst: bool)
{
    dst := src1 < src2;
}

procedure {:inline 1} $Gt(src1: int, src2: int) returns (dst: bool)
{
    dst := src1 > src2;
}

procedure {:inline 1} $Le(src1: int, src2: int) returns (dst: bool)
{
    dst := src1 <= src2;
}

procedure {:inline 1} $Ge(src1: int, src2: int) returns (dst: bool)
{
    dst := src1 >= src2;
}

procedure {:inline 1} $And(src1: bool, src2: bool) returns (dst: bool)
{
    dst := src1 && src2;
}

procedure {:inline 1} $Or(src1: bool, src2: bool) returns (dst: bool)
{
    dst := src1 || src2;
}

procedure {:inline 1} $Not(src: bool) returns (dst: bool)
{
    dst := !src;
}

// Pack and Unpack are auto-generated for each type T


// ==================================================================================
// Native Vector

function {:inline} $SliceVecByRange<T>(v: Vec T, r: $Range): Vec T {
    SliceVec(v, lb#$Range(r), ub#$Range(r))
}

// ----------------------------------------------------------------------------------
// Native Vector implementation for element type `#0`

// Not inlined. It appears faster this way.
function $IsEqual'vec'#0''(v1: Vec (#0), v2: Vec (#0)): bool {
    LenVec(v1) == LenVec(v2) &&
    (forall i: int:: InRangeVec(v1, i) ==> $IsEqual'#0'(ReadVec(v1, i), ReadVec(v2, i)))
}

// Not inlined.
function $IsPrefix'vec'#0''(v: Vec (#0), prefix: Vec (#0)): bool {
    LenVec(v) >= LenVec(prefix) &&
    (forall i: int:: InRangeVec(prefix, i) ==> $IsEqual'#0'(ReadVec(v, i), ReadVec(prefix, i)))
}

// Not inlined.
function $IsSuffix'vec'#0''(v: Vec (#0), suffix: Vec (#0)): bool {
    LenVec(v) >= LenVec(suffix) &&
    (forall i: int:: InRangeVec(suffix, i) ==> $IsEqual'#0'(ReadVec(v, LenVec(v) - LenVec(suffix) + i), ReadVec(suffix, i)))
}

// Not inlined.
function $IsValid'vec'#0''(v: Vec (#0)): bool {
    $IsValid'u64'(LenVec(v)) &&
    (forall i: int:: InRangeVec(v, i) ==> $IsValid'#0'(ReadVec(v, i)))
}


function {:inline} $ContainsVec'#0'(v: Vec (#0), e: #0): bool {
    (exists i: int :: $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'#0'(ReadVec(v, i), e))
}

function $IndexOfVec'#0'(v: Vec (#0), e: #0): int;
axiom (forall v: Vec (#0), e: #0:: {$IndexOfVec'#0'(v, e)}
    (var i := $IndexOfVec'#0'(v, e);
     if (!$ContainsVec'#0'(v, e)) then i == -1
     else $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'#0'(ReadVec(v, i), e) &&
        (forall j: int :: $IsValid'u64'(j) && j >= 0 && j < i ==> !$IsEqual'#0'(ReadVec(v, j), e))));


function {:inline} $RangeVec'#0'(v: Vec (#0)): $Range {
    $Range(0, LenVec(v))
}


function {:inline} $EmptyVec'#0'(): Vec (#0) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_empty'#0'() returns (v: Vec (#0)) {
    v := EmptyVec();
}

function {:inline} $1_vector_$empty'#0'(): Vec (#0) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_is_empty'#0'(v: Vec (#0)) returns (b: bool) {
    b := IsEmptyVec(v);
}

procedure {:inline 1} $1_vector_push_back'#0'(m: $Mutation (Vec (#0)), val: #0) returns (m': $Mutation (Vec (#0))) {
    m' := $UpdateMutation(m, ExtendVec($Dereference(m), val));
}

function {:inline} $1_vector_$push_back'#0'(v: Vec (#0), val: #0): Vec (#0) {
    ExtendVec(v, val)
}

procedure {:inline 1} $1_vector_pop_back'#0'(m: $Mutation (Vec (#0))) returns (e: #0, m': $Mutation (Vec (#0))) {
    var v: Vec (#0);
    var len: int;
    v := $Dereference(m);
    len := LenVec(v);
    if (len == 0) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, len-1);
    m' := $UpdateMutation(m, RemoveVec(v));
}

procedure {:inline 1} $1_vector_append'#0'(m: $Mutation (Vec (#0)), other: Vec (#0)) returns (m': $Mutation (Vec (#0))) {
    m' := $UpdateMutation(m, ConcatVec($Dereference(m), other));
}

procedure {:inline 1} $1_vector_reverse'#0'(m: $Mutation (Vec (#0))) returns (m': $Mutation (Vec (#0))) {
    m' := $UpdateMutation(m, ReverseVec($Dereference(m)));
}

procedure {:inline 1} $1_vector_length'#0'(v: Vec (#0)) returns (l: int) {
    l := LenVec(v);
}

function {:inline} $1_vector_$length'#0'(v: Vec (#0)): int {
    LenVec(v)
}

procedure {:inline 1} $1_vector_borrow'#0'(v: Vec (#0), i: int) returns (dst: #0) {
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    dst := ReadVec(v, i);
}

function {:inline} $1_vector_$borrow'#0'(v: Vec (#0), i: int): #0 {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_borrow_mut'#0'(m: $Mutation (Vec (#0)), index: int)
returns (dst: $Mutation (#0), m': $Mutation (Vec (#0)))
{
    var v: Vec (#0);
    v := $Dereference(m);
    if (!InRangeVec(v, index)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mutation(l#$Mutation(m), ExtendVec(p#$Mutation(m), index), ReadVec(v, index));
    m' := m;
}

function {:inline} $1_vector_$borrow_mut'#0'(v: Vec (#0), i: int): #0 {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_destroy_empty'#0'(v: Vec (#0)) {
    if (!IsEmptyVec(v)) {
      call $ExecFailureAbort();
    }
}

procedure {:inline 1} $1_vector_swap'#0'(m: $Mutation (Vec (#0)), i: int, j: int) returns (m': $Mutation (Vec (#0)))
{
    var v: Vec (#0);
    v := $Dereference(m);
    if (!InRangeVec(v, i) || !InRangeVec(v, j)) {
        call $ExecFailureAbort();
        return;
    }
    m' := $UpdateMutation(m, SwapVec(v, i, j));
}

function {:inline} $1_vector_$swap'#0'(v: Vec (#0), i: int, j: int): Vec (#0) {
    SwapVec(v, i, j)
}

procedure {:inline 1} $1_vector_remove'#0'(m: $Mutation (Vec (#0)), i: int) returns (e: #0, m': $Mutation (Vec (#0)))
{
    var v: Vec (#0);

    v := $Dereference(m);

    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveAtVec(v, i));
}

procedure {:inline 1} $1_vector_swap_remove'#0'(m: $Mutation (Vec (#0)), i: int) returns (e: #0, m': $Mutation (Vec (#0)))
{
    var len: int;
    var v: Vec (#0);

    v := $Dereference(m);
    len := LenVec(v);
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveVec(SwapVec(v, i, len-1)));
}

procedure {:inline 1} $1_vector_contains'#0'(v: Vec (#0), e: #0) returns (res: bool)  {
    res := $ContainsVec'#0'(v, e);
}

procedure {:inline 1}
$1_vector_index_of'#0'(v: Vec (#0), e: #0) returns (res1: bool, res2: int) {
    res2 := $IndexOfVec'#0'(v, e);
    if (res2 >= 0) {
        res1 := true;
    } else {
        res1 := false;
        res2 := 0;
    }
}


// ----------------------------------------------------------------------------------
// Native Vector implementation for element type `address`

// Not inlined. It appears faster this way.
function $IsEqual'vec'address''(v1: Vec (int), v2: Vec (int)): bool {
    LenVec(v1) == LenVec(v2) &&
    (forall i: int:: InRangeVec(v1, i) ==> $IsEqual'address'(ReadVec(v1, i), ReadVec(v2, i)))
}

// Not inlined.
function $IsPrefix'vec'address''(v: Vec (int), prefix: Vec (int)): bool {
    LenVec(v) >= LenVec(prefix) &&
    (forall i: int:: InRangeVec(prefix, i) ==> $IsEqual'address'(ReadVec(v, i), ReadVec(prefix, i)))
}

// Not inlined.
function $IsSuffix'vec'address''(v: Vec (int), suffix: Vec (int)): bool {
    LenVec(v) >= LenVec(suffix) &&
    (forall i: int:: InRangeVec(suffix, i) ==> $IsEqual'address'(ReadVec(v, LenVec(v) - LenVec(suffix) + i), ReadVec(suffix, i)))
}

// Not inlined.
function $IsValid'vec'address''(v: Vec (int)): bool {
    $IsValid'u64'(LenVec(v)) &&
    (forall i: int:: InRangeVec(v, i) ==> $IsValid'address'(ReadVec(v, i)))
}


function {:inline} $ContainsVec'address'(v: Vec (int), e: int): bool {
    (exists i: int :: $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'address'(ReadVec(v, i), e))
}

function $IndexOfVec'address'(v: Vec (int), e: int): int;
axiom (forall v: Vec (int), e: int:: {$IndexOfVec'address'(v, e)}
    (var i := $IndexOfVec'address'(v, e);
     if (!$ContainsVec'address'(v, e)) then i == -1
     else $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'address'(ReadVec(v, i), e) &&
        (forall j: int :: $IsValid'u64'(j) && j >= 0 && j < i ==> !$IsEqual'address'(ReadVec(v, j), e))));


function {:inline} $RangeVec'address'(v: Vec (int)): $Range {
    $Range(0, LenVec(v))
}


function {:inline} $EmptyVec'address'(): Vec (int) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_empty'address'() returns (v: Vec (int)) {
    v := EmptyVec();
}

function {:inline} $1_vector_$empty'address'(): Vec (int) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_is_empty'address'(v: Vec (int)) returns (b: bool) {
    b := IsEmptyVec(v);
}

procedure {:inline 1} $1_vector_push_back'address'(m: $Mutation (Vec (int)), val: int) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ExtendVec($Dereference(m), val));
}

function {:inline} $1_vector_$push_back'address'(v: Vec (int), val: int): Vec (int) {
    ExtendVec(v, val)
}

procedure {:inline 1} $1_vector_pop_back'address'(m: $Mutation (Vec (int))) returns (e: int, m': $Mutation (Vec (int))) {
    var v: Vec (int);
    var len: int;
    v := $Dereference(m);
    len := LenVec(v);
    if (len == 0) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, len-1);
    m' := $UpdateMutation(m, RemoveVec(v));
}

procedure {:inline 1} $1_vector_append'address'(m: $Mutation (Vec (int)), other: Vec (int)) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ConcatVec($Dereference(m), other));
}

procedure {:inline 1} $1_vector_reverse'address'(m: $Mutation (Vec (int))) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ReverseVec($Dereference(m)));
}

procedure {:inline 1} $1_vector_length'address'(v: Vec (int)) returns (l: int) {
    l := LenVec(v);
}

function {:inline} $1_vector_$length'address'(v: Vec (int)): int {
    LenVec(v)
}

procedure {:inline 1} $1_vector_borrow'address'(v: Vec (int), i: int) returns (dst: int) {
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    dst := ReadVec(v, i);
}

function {:inline} $1_vector_$borrow'address'(v: Vec (int), i: int): int {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_borrow_mut'address'(m: $Mutation (Vec (int)), index: int)
returns (dst: $Mutation (int), m': $Mutation (Vec (int)))
{
    var v: Vec (int);
    v := $Dereference(m);
    if (!InRangeVec(v, index)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mutation(l#$Mutation(m), ExtendVec(p#$Mutation(m), index), ReadVec(v, index));
    m' := m;
}

function {:inline} $1_vector_$borrow_mut'address'(v: Vec (int), i: int): int {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_destroy_empty'address'(v: Vec (int)) {
    if (!IsEmptyVec(v)) {
      call $ExecFailureAbort();
    }
}

procedure {:inline 1} $1_vector_swap'address'(m: $Mutation (Vec (int)), i: int, j: int) returns (m': $Mutation (Vec (int)))
{
    var v: Vec (int);
    v := $Dereference(m);
    if (!InRangeVec(v, i) || !InRangeVec(v, j)) {
        call $ExecFailureAbort();
        return;
    }
    m' := $UpdateMutation(m, SwapVec(v, i, j));
}

function {:inline} $1_vector_$swap'address'(v: Vec (int), i: int, j: int): Vec (int) {
    SwapVec(v, i, j)
}

procedure {:inline 1} $1_vector_remove'address'(m: $Mutation (Vec (int)), i: int) returns (e: int, m': $Mutation (Vec (int)))
{
    var v: Vec (int);

    v := $Dereference(m);

    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveAtVec(v, i));
}

procedure {:inline 1} $1_vector_swap_remove'address'(m: $Mutation (Vec (int)), i: int) returns (e: int, m': $Mutation (Vec (int)))
{
    var len: int;
    var v: Vec (int);

    v := $Dereference(m);
    len := LenVec(v);
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveVec(SwapVec(v, i, len-1)));
}

procedure {:inline 1} $1_vector_contains'address'(v: Vec (int), e: int) returns (res: bool)  {
    res := $ContainsVec'address'(v, e);
}

procedure {:inline 1}
$1_vector_index_of'address'(v: Vec (int), e: int) returns (res1: bool, res2: int) {
    res2 := $IndexOfVec'address'(v, e);
    if (res2 >= 0) {
        res1 := true;
    } else {
        res1 := false;
        res2 := 0;
    }
}


// ----------------------------------------------------------------------------------
// Native Vector implementation for element type `u8`

// Not inlined. It appears faster this way.
function $IsEqual'vec'u8''(v1: Vec (int), v2: Vec (int)): bool {
    LenVec(v1) == LenVec(v2) &&
    (forall i: int:: InRangeVec(v1, i) ==> $IsEqual'u8'(ReadVec(v1, i), ReadVec(v2, i)))
}

// Not inlined.
function $IsPrefix'vec'u8''(v: Vec (int), prefix: Vec (int)): bool {
    LenVec(v) >= LenVec(prefix) &&
    (forall i: int:: InRangeVec(prefix, i) ==> $IsEqual'u8'(ReadVec(v, i), ReadVec(prefix, i)))
}

// Not inlined.
function $IsSuffix'vec'u8''(v: Vec (int), suffix: Vec (int)): bool {
    LenVec(v) >= LenVec(suffix) &&
    (forall i: int:: InRangeVec(suffix, i) ==> $IsEqual'u8'(ReadVec(v, LenVec(v) - LenVec(suffix) + i), ReadVec(suffix, i)))
}

// Not inlined.
function $IsValid'vec'u8''(v: Vec (int)): bool {
    $IsValid'u64'(LenVec(v)) &&
    (forall i: int:: InRangeVec(v, i) ==> $IsValid'u8'(ReadVec(v, i)))
}


function {:inline} $ContainsVec'u8'(v: Vec (int), e: int): bool {
    (exists i: int :: $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'u8'(ReadVec(v, i), e))
}

function $IndexOfVec'u8'(v: Vec (int), e: int): int;
axiom (forall v: Vec (int), e: int:: {$IndexOfVec'u8'(v, e)}
    (var i := $IndexOfVec'u8'(v, e);
     if (!$ContainsVec'u8'(v, e)) then i == -1
     else $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'u8'(ReadVec(v, i), e) &&
        (forall j: int :: $IsValid'u64'(j) && j >= 0 && j < i ==> !$IsEqual'u8'(ReadVec(v, j), e))));


function {:inline} $RangeVec'u8'(v: Vec (int)): $Range {
    $Range(0, LenVec(v))
}


function {:inline} $EmptyVec'u8'(): Vec (int) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_empty'u8'() returns (v: Vec (int)) {
    v := EmptyVec();
}

function {:inline} $1_vector_$empty'u8'(): Vec (int) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_is_empty'u8'(v: Vec (int)) returns (b: bool) {
    b := IsEmptyVec(v);
}

procedure {:inline 1} $1_vector_push_back'u8'(m: $Mutation (Vec (int)), val: int) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ExtendVec($Dereference(m), val));
}

function {:inline} $1_vector_$push_back'u8'(v: Vec (int), val: int): Vec (int) {
    ExtendVec(v, val)
}

procedure {:inline 1} $1_vector_pop_back'u8'(m: $Mutation (Vec (int))) returns (e: int, m': $Mutation (Vec (int))) {
    var v: Vec (int);
    var len: int;
    v := $Dereference(m);
    len := LenVec(v);
    if (len == 0) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, len-1);
    m' := $UpdateMutation(m, RemoveVec(v));
}

procedure {:inline 1} $1_vector_append'u8'(m: $Mutation (Vec (int)), other: Vec (int)) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ConcatVec($Dereference(m), other));
}

procedure {:inline 1} $1_vector_reverse'u8'(m: $Mutation (Vec (int))) returns (m': $Mutation (Vec (int))) {
    m' := $UpdateMutation(m, ReverseVec($Dereference(m)));
}

procedure {:inline 1} $1_vector_length'u8'(v: Vec (int)) returns (l: int) {
    l := LenVec(v);
}

function {:inline} $1_vector_$length'u8'(v: Vec (int)): int {
    LenVec(v)
}

procedure {:inline 1} $1_vector_borrow'u8'(v: Vec (int), i: int) returns (dst: int) {
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    dst := ReadVec(v, i);
}

function {:inline} $1_vector_$borrow'u8'(v: Vec (int), i: int): int {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_borrow_mut'u8'(m: $Mutation (Vec (int)), index: int)
returns (dst: $Mutation (int), m': $Mutation (Vec (int)))
{
    var v: Vec (int);
    v := $Dereference(m);
    if (!InRangeVec(v, index)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mutation(l#$Mutation(m), ExtendVec(p#$Mutation(m), index), ReadVec(v, index));
    m' := m;
}

function {:inline} $1_vector_$borrow_mut'u8'(v: Vec (int), i: int): int {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_destroy_empty'u8'(v: Vec (int)) {
    if (!IsEmptyVec(v)) {
      call $ExecFailureAbort();
    }
}

procedure {:inline 1} $1_vector_swap'u8'(m: $Mutation (Vec (int)), i: int, j: int) returns (m': $Mutation (Vec (int)))
{
    var v: Vec (int);
    v := $Dereference(m);
    if (!InRangeVec(v, i) || !InRangeVec(v, j)) {
        call $ExecFailureAbort();
        return;
    }
    m' := $UpdateMutation(m, SwapVec(v, i, j));
}

function {:inline} $1_vector_$swap'u8'(v: Vec (int), i: int, j: int): Vec (int) {
    SwapVec(v, i, j)
}

procedure {:inline 1} $1_vector_remove'u8'(m: $Mutation (Vec (int)), i: int) returns (e: int, m': $Mutation (Vec (int)))
{
    var v: Vec (int);

    v := $Dereference(m);

    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveAtVec(v, i));
}

procedure {:inline 1} $1_vector_swap_remove'u8'(m: $Mutation (Vec (int)), i: int) returns (e: int, m': $Mutation (Vec (int)))
{
    var len: int;
    var v: Vec (int);

    v := $Dereference(m);
    len := LenVec(v);
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveVec(SwapVec(v, i, len-1)));
}

procedure {:inline 1} $1_vector_contains'u8'(v: Vec (int), e: int) returns (res: bool)  {
    res := $ContainsVec'u8'(v, e);
}

procedure {:inline 1}
$1_vector_index_of'u8'(v: Vec (int), e: int) returns (res1: bool, res2: int) {
    res2 := $IndexOfVec'u8'(v, e);
    if (res2 >= 0) {
        res1 := true;
    } else {
        res1 := false;
        res2 := 0;
    }
}


// ----------------------------------------------------------------------------------
// Native Vector implementation for element type `bv8`

// Not inlined. It appears faster this way.
function $IsEqual'vec'bv8''(v1: Vec (bv8), v2: Vec (bv8)): bool {
    LenVec(v1) == LenVec(v2) &&
    (forall i: int:: InRangeVec(v1, i) ==> $IsEqual'bv8'(ReadVec(v1, i), ReadVec(v2, i)))
}

// Not inlined.
function $IsPrefix'vec'bv8''(v: Vec (bv8), prefix: Vec (bv8)): bool {
    LenVec(v) >= LenVec(prefix) &&
    (forall i: int:: InRangeVec(prefix, i) ==> $IsEqual'bv8'(ReadVec(v, i), ReadVec(prefix, i)))
}

// Not inlined.
function $IsSuffix'vec'bv8''(v: Vec (bv8), suffix: Vec (bv8)): bool {
    LenVec(v) >= LenVec(suffix) &&
    (forall i: int:: InRangeVec(suffix, i) ==> $IsEqual'bv8'(ReadVec(v, LenVec(v) - LenVec(suffix) + i), ReadVec(suffix, i)))
}

// Not inlined.
function $IsValid'vec'bv8''(v: Vec (bv8)): bool {
    $IsValid'u64'(LenVec(v)) &&
    (forall i: int:: InRangeVec(v, i) ==> $IsValid'bv8'(ReadVec(v, i)))
}


function {:inline} $ContainsVec'bv8'(v: Vec (bv8), e: bv8): bool {
    (exists i: int :: $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'bv8'(ReadVec(v, i), e))
}

function $IndexOfVec'bv8'(v: Vec (bv8), e: bv8): int;
axiom (forall v: Vec (bv8), e: bv8:: {$IndexOfVec'bv8'(v, e)}
    (var i := $IndexOfVec'bv8'(v, e);
     if (!$ContainsVec'bv8'(v, e)) then i == -1
     else $IsValid'u64'(i) && InRangeVec(v, i) && $IsEqual'bv8'(ReadVec(v, i), e) &&
        (forall j: int :: $IsValid'u64'(j) && j >= 0 && j < i ==> !$IsEqual'bv8'(ReadVec(v, j), e))));


function {:inline} $RangeVec'bv8'(v: Vec (bv8)): $Range {
    $Range(0, LenVec(v))
}


function {:inline} $EmptyVec'bv8'(): Vec (bv8) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_empty'bv8'() returns (v: Vec (bv8)) {
    v := EmptyVec();
}

function {:inline} $1_vector_$empty'bv8'(): Vec (bv8) {
    EmptyVec()
}

procedure {:inline 1} $1_vector_is_empty'bv8'(v: Vec (bv8)) returns (b: bool) {
    b := IsEmptyVec(v);
}

procedure {:inline 1} $1_vector_push_back'bv8'(m: $Mutation (Vec (bv8)), val: bv8) returns (m': $Mutation (Vec (bv8))) {
    m' := $UpdateMutation(m, ExtendVec($Dereference(m), val));
}

function {:inline} $1_vector_$push_back'bv8'(v: Vec (bv8), val: bv8): Vec (bv8) {
    ExtendVec(v, val)
}

procedure {:inline 1} $1_vector_pop_back'bv8'(m: $Mutation (Vec (bv8))) returns (e: bv8, m': $Mutation (Vec (bv8))) {
    var v: Vec (bv8);
    var len: int;
    v := $Dereference(m);
    len := LenVec(v);
    if (len == 0) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, len-1);
    m' := $UpdateMutation(m, RemoveVec(v));
}

procedure {:inline 1} $1_vector_append'bv8'(m: $Mutation (Vec (bv8)), other: Vec (bv8)) returns (m': $Mutation (Vec (bv8))) {
    m' := $UpdateMutation(m, ConcatVec($Dereference(m), other));
}

procedure {:inline 1} $1_vector_reverse'bv8'(m: $Mutation (Vec (bv8))) returns (m': $Mutation (Vec (bv8))) {
    m' := $UpdateMutation(m, ReverseVec($Dereference(m)));
}

procedure {:inline 1} $1_vector_length'bv8'(v: Vec (bv8)) returns (l: int) {
    l := LenVec(v);
}

function {:inline} $1_vector_$length'bv8'(v: Vec (bv8)): int {
    LenVec(v)
}

procedure {:inline 1} $1_vector_borrow'bv8'(v: Vec (bv8), i: int) returns (dst: bv8) {
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    dst := ReadVec(v, i);
}

function {:inline} $1_vector_$borrow'bv8'(v: Vec (bv8), i: int): bv8 {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_borrow_mut'bv8'(m: $Mutation (Vec (bv8)), index: int)
returns (dst: $Mutation (bv8), m': $Mutation (Vec (bv8)))
{
    var v: Vec (bv8);
    v := $Dereference(m);
    if (!InRangeVec(v, index)) {
        call $ExecFailureAbort();
        return;
    }
    dst := $Mutation(l#$Mutation(m), ExtendVec(p#$Mutation(m), index), ReadVec(v, index));
    m' := m;
}

function {:inline} $1_vector_$borrow_mut'bv8'(v: Vec (bv8), i: int): bv8 {
    ReadVec(v, i)
}

procedure {:inline 1} $1_vector_destroy_empty'bv8'(v: Vec (bv8)) {
    if (!IsEmptyVec(v)) {
      call $ExecFailureAbort();
    }
}

procedure {:inline 1} $1_vector_swap'bv8'(m: $Mutation (Vec (bv8)), i: int, j: int) returns (m': $Mutation (Vec (bv8)))
{
    var v: Vec (bv8);
    v := $Dereference(m);
    if (!InRangeVec(v, i) || !InRangeVec(v, j)) {
        call $ExecFailureAbort();
        return;
    }
    m' := $UpdateMutation(m, SwapVec(v, i, j));
}

function {:inline} $1_vector_$swap'bv8'(v: Vec (bv8), i: int, j: int): Vec (bv8) {
    SwapVec(v, i, j)
}

procedure {:inline 1} $1_vector_remove'bv8'(m: $Mutation (Vec (bv8)), i: int) returns (e: bv8, m': $Mutation (Vec (bv8)))
{
    var v: Vec (bv8);

    v := $Dereference(m);

    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveAtVec(v, i));
}

procedure {:inline 1} $1_vector_swap_remove'bv8'(m: $Mutation (Vec (bv8)), i: int) returns (e: bv8, m': $Mutation (Vec (bv8)))
{
    var len: int;
    var v: Vec (bv8);

    v := $Dereference(m);
    len := LenVec(v);
    if (!InRangeVec(v, i)) {
        call $ExecFailureAbort();
        return;
    }
    e := ReadVec(v, i);
    m' := $UpdateMutation(m, RemoveVec(SwapVec(v, i, len-1)));
}

procedure {:inline 1} $1_vector_contains'bv8'(v: Vec (bv8), e: bv8) returns (res: bool)  {
    res := $ContainsVec'bv8'(v, e);
}

procedure {:inline 1}
$1_vector_index_of'bv8'(v: Vec (bv8), e: bv8) returns (res1: bool, res2: int) {
    res2 := $IndexOfVec'bv8'(v, e);
    if (res2 >= 0) {
        res1 := true;
    } else {
        res1 := false;
        res2 := 0;
    }
}


// ==================================================================================
// Native Table

// ==================================================================================
// Native Hash

// Hash is modeled as an otherwise uninterpreted injection.
// In truth, it is not an injection since the domain has greater cardinality
// (arbitrary length vectors) than the co-domain (vectors of length 32).  But it is
// common to assume in code there are no hash collisions in practice.  Fortunately,
// Boogie is not smart enough to recognized that there is an inconsistency.
// FIXME: If we were using a reliable extensional theory of arrays, and if we could use ==
// instead of $IsEqual, we might be able to avoid so many quantified formulas by
// using a sha2_inverse function in the ensures conditions of Hash_sha2_256 to
// assert that sha2/3 are injections without using global quantified axioms.


function $1_hash_sha2(val: Vec int): Vec int;

// This says that Hash_sha2 is bijective.
axiom (forall v1,v2: Vec int :: {$1_hash_sha2(v1), $1_hash_sha2(v2)}
       $IsEqual'vec'u8''(v1, v2) <==> $IsEqual'vec'u8''($1_hash_sha2(v1), $1_hash_sha2(v2)));

procedure $1_hash_sha2_256(val: Vec int) returns (res: Vec int);
ensures res == $1_hash_sha2(val);     // returns Hash_sha2 Value
ensures $IsValid'vec'u8''(res);    // result is a legal vector of U8s.
ensures LenVec(res) == 32;               // result is 32 bytes.

// Spec version of Move native function.
function {:inline} $1_hash_$sha2_256(val: Vec int): Vec int {
    $1_hash_sha2(val)
}

// similarly for Hash_sha3
function $1_hash_sha3(val: Vec int): Vec int;

axiom (forall v1,v2: Vec int :: {$1_hash_sha3(v1), $1_hash_sha3(v2)}
       $IsEqual'vec'u8''(v1, v2) <==> $IsEqual'vec'u8''($1_hash_sha3(v1), $1_hash_sha3(v2)));

procedure $1_hash_sha3_256(val: Vec int) returns (res: Vec int);
ensures res == $1_hash_sha3(val);     // returns Hash_sha3 Value
ensures $IsValid'vec'u8''(res);    // result is a legal vector of U8s.
ensures LenVec(res) == 32;               // result is 32 bytes.

// Spec version of Move native function.
function {:inline} $1_hash_$sha3_256(val: Vec int): Vec int {
    $1_hash_sha3(val)
}

// ==================================================================================
// Native string

// TODO: correct implementation of strings

procedure {:inline 1} $1_string_internal_check_utf8(x: Vec int) returns (r: bool) {
}

procedure {:inline 1} $1_string_internal_sub_string(x: Vec int, i: int, j: int) returns (r: Vec int) {
}

procedure {:inline 1} $1_string_internal_index_of(x: Vec int, y: Vec int) returns (r: int) {
}

procedure {:inline 1} $1_string_internal_is_char_boundary(x: Vec int, i: int) returns (r: bool) {
}




// ==================================================================================
// Native diem_account

procedure {:inline 1} $1_DiemAccount_create_signer(
  addr: int
) returns (signer: $signer) {
    // A signer is currently identical to an address.
    signer := $signer(addr);
}

procedure {:inline 1} $1_DiemAccount_destroy_signer(
  signer: $signer
) {
  return;
}

// ==================================================================================
// Native account

procedure {:inline 1} $1_Account_create_signer(
  addr: int
) returns (signer: $signer) {
    // A signer is currently identical to an address.
    signer := $signer(addr);
}

// ==================================================================================
// Native Signer

type {:datatype} $signer;
function {:constructor} $signer($addr: int): $signer;
function {:inline} $IsValid'signer'(s: $signer): bool {
    $IsValid'address'($addr#$signer(s))
}
function {:inline} $IsEqual'signer'(s1: $signer, s2: $signer): bool {
    s1 == s2
}

procedure {:inline 1} $1_signer_borrow_address(signer: $signer) returns (res: int) {
    res := $addr#$signer(signer);
}

function {:inline} $1_signer_$borrow_address(signer: $signer): int
{
    $addr#$signer(signer)
}

function $1_signer_is_txn_signer(s: $signer): bool;

function $1_signer_is_txn_signer_addr(a: int): bool;


// ==================================================================================
// Native signature

// Signature related functionality is handled via uninterpreted functions. This is sound
// currently because we verify every code path based on signature verification with
// an arbitrary interpretation.

function $1_Signature_$ed25519_validate_pubkey(public_key: Vec int): bool;
function $1_Signature_$ed25519_verify(signature: Vec int, public_key: Vec int, message: Vec int): bool;

// Needed because we do not have extensional equality:
axiom (forall k1, k2: Vec int ::
    {$1_Signature_$ed25519_validate_pubkey(k1), $1_Signature_$ed25519_validate_pubkey(k2)}
    $IsEqual'vec'u8''(k1, k2) ==> $1_Signature_$ed25519_validate_pubkey(k1) == $1_Signature_$ed25519_validate_pubkey(k2));
axiom (forall s1, s2, k1, k2, m1, m2: Vec int ::
    {$1_Signature_$ed25519_verify(s1, k1, m1), $1_Signature_$ed25519_verify(s2, k2, m2)}
    $IsEqual'vec'u8''(s1, s2) && $IsEqual'vec'u8''(k1, k2) && $IsEqual'vec'u8''(m1, m2)
    ==> $1_Signature_$ed25519_verify(s1, k1, m1) == $1_Signature_$ed25519_verify(s2, k2, m2));


procedure {:inline 1} $1_Signature_ed25519_validate_pubkey(public_key: Vec int) returns (res: bool) {
    res := $1_Signature_$ed25519_validate_pubkey(public_key);
}

procedure {:inline 1} $1_Signature_ed25519_verify(
        signature: Vec int, public_key: Vec int, message: Vec int) returns (res: bool) {
    res := $1_Signature_$ed25519_verify(signature, public_key, message);
}


// ==================================================================================
// Native bcs::serialize


// ==================================================================================
// Native Event module



procedure {:inline 1} $InitEventStore() {
}

// ============================================================================================
// Type Reflection on Type Parameters

type {:datatype} $TypeParamInfo;

function {:constructor} $TypeParamBool(): $TypeParamInfo;
function {:constructor} $TypeParamU8(): $TypeParamInfo;
function {:constructor} $TypeParamU16(): $TypeParamInfo;
function {:constructor} $TypeParamU32(): $TypeParamInfo;
function {:constructor} $TypeParamU64(): $TypeParamInfo;
function {:constructor} $TypeParamU128(): $TypeParamInfo;
function {:constructor} $TypeParamU256(): $TypeParamInfo;
function {:constructor} $TypeParamAddress(): $TypeParamInfo;
function {:constructor} $TypeParamSigner(): $TypeParamInfo;
function {:constructor} $TypeParamVector(e: $TypeParamInfo): $TypeParamInfo;
function {:constructor} $TypeParamStruct(a: int, m: Vec int, s: Vec int): $TypeParamInfo;



//==================================
// Begin Translation

function $TypeName(t: $TypeParamInfo): Vec int;
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamBool(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 98][1 := 111][2 := 111][3 := 108], 4)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 98][1 := 111][2 := 111][3 := 108], 4)) ==> is#$TypeParamBool(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU8(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 56], 2)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 56], 2)) ==> is#$TypeParamU8(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU16(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 49][2 := 54], 3)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 49][2 := 54], 3)) ==> is#$TypeParamU16(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU32(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 51][2 := 50], 3)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 51][2 := 50], 3)) ==> is#$TypeParamU32(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU64(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 54][2 := 52], 3)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 54][2 := 52], 3)) ==> is#$TypeParamU64(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU128(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 49][2 := 50][3 := 56], 4)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 49][2 := 50][3 := 56], 4)) ==> is#$TypeParamU128(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamU256(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 50][2 := 53][3 := 54], 4)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 117][1 := 50][2 := 53][3 := 54], 4)) ==> is#$TypeParamU256(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamAddress(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 97][1 := 100][2 := 100][3 := 114][4 := 101][5 := 115][6 := 115], 7)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 97][1 := 100][2 := 100][3 := 114][4 := 101][5 := 115][6 := 115], 7)) ==> is#$TypeParamAddress(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamSigner(t) ==> $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 115][1 := 105][2 := 103][3 := 110][4 := 101][5 := 114], 6)));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsEqual'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 115][1 := 105][2 := 103][3 := 110][4 := 101][5 := 114], 6)) ==> is#$TypeParamSigner(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamVector(t) ==> $IsEqual'vec'u8''($TypeName(t), ConcatVec(ConcatVec(Vec(DefaultVecMap()[0 := 118][1 := 101][2 := 99][3 := 116][4 := 111][5 := 114][6 := 60], 7), $TypeName(e#$TypeParamVector(t))), Vec(DefaultVecMap()[0 := 62], 1))));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} ($IsPrefix'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 118][1 := 101][2 := 99][3 := 116][4 := 111][5 := 114][6 := 60], 7)) && $IsSuffix'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 62], 1))) ==> is#$TypeParamVector(t));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} is#$TypeParamStruct(t) ==> $IsEqual'vec'u8''($TypeName(t), ConcatVec(ConcatVec(ConcatVec(ConcatVec(ConcatVec(Vec(DefaultVecMap()[0 := 48][1 := 120], 2), MakeVec1(a#$TypeParamStruct(t))), Vec(DefaultVecMap()[0 := 58][1 := 58], 2)), m#$TypeParamStruct(t)), Vec(DefaultVecMap()[0 := 58][1 := 58], 2)), s#$TypeParamStruct(t))));
axiom (forall t: $TypeParamInfo :: {$TypeName(t)} $IsPrefix'vec'u8''($TypeName(t), Vec(DefaultVecMap()[0 := 48][1 := 120], 2)) ==> is#$TypeParamVector(t));


// Given Types for Type Parameters

type #0;
function {:inline} $IsEqual'#0'(x1: #0, x2: #0): bool { x1 == x2 }
function {:inline} $IsValid'#0'(x: #0): bool { true }
var #0_info: $TypeParamInfo;

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <bool>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'bool'($1_from_bcs_deserialize'bool'(b1), $1_from_bcs_deserialize'bool'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <u64>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'u64'($1_from_bcs_deserialize'u64'(b1), $1_from_bcs_deserialize'u64'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <u128>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'u128'($1_from_bcs_deserialize'u128'(b1), $1_from_bcs_deserialize'u128'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <u256>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'u256'($1_from_bcs_deserialize'u256'(b1), $1_from_bcs_deserialize'u256'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <address>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'address'($1_from_bcs_deserialize'address'(b1), $1_from_bcs_deserialize'address'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <signer>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'signer'($1_from_bcs_deserialize'signer'(b1), $1_from_bcs_deserialize'signer'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <vector<u8>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'vec'u8''($1_from_bcs_deserialize'vec'u8''(b1), $1_from_bcs_deserialize'vec'u8''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <vector<address>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'vec'address''($1_from_bcs_deserialize'vec'address''(b1), $1_from_bcs_deserialize'vec'address''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <vector<#0>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'vec'#0''($1_from_bcs_deserialize'vec'#0''(b1), $1_from_bcs_deserialize'vec'#0''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <option::Option<address>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_option_Option'address''($1_from_bcs_deserialize'$1_option_Option'address''(b1), $1_from_bcs_deserialize'$1_option_Option'address''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <string::String>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_string_String'($1_from_bcs_deserialize'$1_string_String'(b1), $1_from_bcs_deserialize'$1_string_String'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <type_info::TypeInfo>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_type_info_TypeInfo'($1_from_bcs_deserialize'$1_type_info_TypeInfo'(b1), $1_from_bcs_deserialize'$1_type_info_TypeInfo'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <guid::GUID>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_guid_GUID'($1_from_bcs_deserialize'$1_guid_GUID'(b1), $1_from_bcs_deserialize'$1_guid_GUID'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <guid::ID>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_guid_ID'($1_from_bcs_deserialize'$1_guid_ID'(b1), $1_from_bcs_deserialize'$1_guid_ID'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<account::CoinRegisterEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$1_account_CoinRegisterEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$1_account_CoinRegisterEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_CoinRegisterEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<account::KeyRotationEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$1_account_KeyRotationEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$1_account_KeyRotationEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_KeyRotationEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<coin::DepositEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$1_coin_DepositEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_DepositEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_DepositEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<coin::WithdrawEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$1_coin_WithdrawEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_WithdrawEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_WithdrawEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<reconfiguration::NewEpochEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<per_second_v8::CloseSessionEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<per_second_v8::CreateSessionEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<per_second_v8::JoinSessionEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <event::EventHandle<per_second_v8::StartSessionEvent>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''($1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(b1), $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <account::Account>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_account_Account'($1_from_bcs_deserialize'$1_account_Account'(b1), $1_from_bcs_deserialize'$1_account_Account'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <account::CapabilityOffer<account::RotationCapability>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_account_CapabilityOffer'$1_account_RotationCapability''($1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_RotationCapability''(b1), $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_RotationCapability''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <account::CapabilityOffer<account::SignerCapability>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_account_CapabilityOffer'$1_account_SignerCapability''($1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_SignerCapability''(b1), $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_SignerCapability''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <coin::Coin<#0>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_coin_Coin'#0''($1_from_bcs_deserialize'$1_coin_Coin'#0''(b1), $1_from_bcs_deserialize'$1_coin_Coin'#0''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <coin::CoinStore<#0>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_coin_CoinStore'#0''($1_from_bcs_deserialize'$1_coin_CoinStore'#0''(b1), $1_from_bcs_deserialize'$1_coin_CoinStore'#0''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <coin::WithdrawEvent>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_coin_WithdrawEvent'($1_from_bcs_deserialize'$1_coin_WithdrawEvent'(b1), $1_from_bcs_deserialize'$1_coin_WithdrawEvent'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <chain_status::GenesisEndMarker>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_chain_status_GenesisEndMarker'($1_from_bcs_deserialize'$1_chain_status_GenesisEndMarker'(b1), $1_from_bcs_deserialize'$1_chain_status_GenesisEndMarker'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <timestamp::CurrentTimeMicroseconds>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_timestamp_CurrentTimeMicroseconds'($1_from_bcs_deserialize'$1_timestamp_CurrentTimeMicroseconds'(b1), $1_from_bcs_deserialize'$1_timestamp_CurrentTimeMicroseconds'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <reconfiguration::Configuration>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$1_reconfiguration_Configuration'($1_from_bcs_deserialize'$1_reconfiguration_Configuration'(b1), $1_from_bcs_deserialize'$1_reconfiguration_Configuration'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <per_second_v8::CreateSessionEvent>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(b1), $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <per_second_v8::Session<#0>>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''($1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(b1), $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// axiom at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:14:9+116, instance <#0>
axiom (forall b1: Vec (int), b2: Vec (int) :: $IsValid'vec'u8''(b1) ==> $IsValid'vec'u8''(b2) ==> (($IsEqual'#0'($1_from_bcs_deserialize'#0'(b1), $1_from_bcs_deserialize'#0'(b2)) ==> $IsEqual'vec'u8''(b1, b2))));

// struct option::Option<address> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/option.move:7:5+81
type {:datatype} $1_option_Option'address';
function {:constructor} $1_option_Option'address'($vec: Vec (int)): $1_option_Option'address';
function {:inline} $Update'$1_option_Option'address''_vec(s: $1_option_Option'address', x: Vec (int)): $1_option_Option'address' {
    $1_option_Option'address'(x)
}
function $IsValid'$1_option_Option'address''(s: $1_option_Option'address'): bool {
    $IsValid'vec'address''($vec#$1_option_Option'address'(s))
}
function {:inline} $IsEqual'$1_option_Option'address''(s1: $1_option_Option'address', s2: $1_option_Option'address'): bool {
    $IsEqual'vec'address''($vec#$1_option_Option'address'(s1), $vec#$1_option_Option'address'(s2))}

// struct string::String at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/string.move:13:5+70
type {:datatype} $1_string_String;
function {:constructor} $1_string_String($bytes: Vec (int)): $1_string_String;
function {:inline} $Update'$1_string_String'_bytes(s: $1_string_String, x: Vec (int)): $1_string_String {
    $1_string_String(x)
}
function $IsValid'$1_string_String'(s: $1_string_String): bool {
    $IsValid'vec'u8''($bytes#$1_string_String(s))
}
function {:inline} $IsEqual'$1_string_String'(s1: $1_string_String, s2: $1_string_String): bool {
    $IsEqual'vec'u8''($bytes#$1_string_String(s1), $bytes#$1_string_String(s2))}

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:12:5+77
function {:inline} $1_signer_$address_of(s: $signer): int {
    $1_signer_$borrow_address(s)
}

// fun signer::address_of [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:12:5+77
procedure {:inline 1} $1_signer_address_of(_$t0: $signer) returns ($ret0: int)
{
    // declare local variables
    var $t1: int;
    var $t2: int;
    var $t0: $signer;
    var $temp_0'address': int;
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[s]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:12:5+1
    assume {:print "$at(15,389,390)"} true;
    assume {:print "$track_local(3,0,0):", $t0} $t0 == $t0;

    // $t1 := signer::borrow_address($t0) on_abort goto L2 with $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:13:10+17
    assume {:print "$at(15,443,460)"} true;
    call $t1 := $1_signer_borrow_address($t0);
    if ($abort_flag) {
        assume {:print "$at(15,443,460)"} true;
        $t2 := $abort_code;
        assume {:print "$track_abort(3,0):", $t2} $t2 == $t2;
        goto L2;
    }

    // trace_return[0]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:13:9+18
    assume {:print "$track_return(3,0,0):", $t1} $t1 == $t1;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:14:5+1
    assume {:print "$at(15,465,466)"} true;
L1:

    // return $t1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:14:5+1
    assume {:print "$at(15,465,466)"} true;
    $ret0 := $t1;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:14:5+1
L2:

    // abort($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/signer.move:14:5+1
    assume {:print "$at(15,465,466)"} true;
    $abort_code := $t2;
    $abort_flag := true;
    return;

}

// fun error::invalid_argument [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:3+76
procedure {:inline 1} $1_error_invalid_argument(_$t0: int) returns ($ret0: int)
{
    // declare local variables
    var $t1: int;
    var $t2: int;
    var $t3: int;
    var $t0: int;
    var $temp_0'u64': int;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[r]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:3+1
    assume {:print "$at(11,3082,3083)"} true;
    assume {:print "$track_local(4,4,0):", $t0} $t0 == $t0;

    // $t1 := 1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:57+16
    $t1 := 1;
    assume $IsValid'u64'($t1);

    // assume Identical($t2, Shl($t1, 16)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:69:5+29
    assume {:print "$at(11,2844,2873)"} true;
    assume ($t2 == $shlU64($t1, 16));

    // $t3 := opaque begin: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:47+30
    assume {:print "$at(11,3126,3156)"} true;

    // assume WellFormed($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:47+30
    assume $IsValid'u64'($t3);

    // assume Eq<u64>($t3, $t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:47+30
    assume $IsEqual'u64'($t3, $t1);

    // $t3 := opaque end: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:47+30

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:47+30
    assume {:print "$track_return(4,4,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:78+1
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:76:78+1
    assume {:print "$at(11,3157,3158)"} true;
    $ret0 := $t3;
    return;

}

// fun error::invalid_state [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:3+70
procedure {:inline 1} $1_error_invalid_state(_$t0: int) returns ($ret0: int)
{
    // declare local variables
    var $t1: int;
    var $t2: int;
    var $t3: int;
    var $t0: int;
    var $temp_0'u64': int;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[r]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:3+1
    assume {:print "$at(11,3232,3233)"} true;
    assume {:print "$track_local(4,5,0):", $t0} $t0 == $t0;

    // $t1 := 3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:54+13
    $t1 := 3;
    assume $IsValid'u64'($t1);

    // assume Identical($t2, Shl($t1, 16)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:69:5+29
    assume {:print "$at(11,2844,2873)"} true;
    assume ($t2 == $shlU64($t1, 16));

    // $t3 := opaque begin: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:44+27
    assume {:print "$at(11,3273,3300)"} true;

    // assume WellFormed($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:44+27
    assume $IsValid'u64'($t3);

    // assume Eq<u64>($t3, $t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:44+27
    assume $IsEqual'u64'($t3, $t1);

    // $t3 := opaque end: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:44+27

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:44+27
    assume {:print "$track_return(4,5,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:72+1
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:78:72+1
    assume {:print "$at(11,3301,3302)"} true;
    $ret0 := $t3;
    return;

}

// fun error::not_found [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:3+61
procedure {:inline 1} $1_error_not_found(_$t0: int) returns ($ret0: int)
{
    // declare local variables
    var $t1: int;
    var $t2: int;
    var $t3: int;
    var $t0: int;
    var $temp_0'u64': int;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[r]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:3+1
    assume {:print "$at(11,3461,3462)"} true;
    assume {:print "$track_local(4,6,0):", $t0} $t0 == $t0;

    // $t1 := 6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:49+9
    $t1 := 6;
    assume $IsValid'u64'($t1);

    // assume Identical($t2, Shl($t1, 16)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:69:5+29
    assume {:print "$at(11,2844,2873)"} true;
    assume ($t2 == $shlU64($t1, 16));

    // $t3 := opaque begin: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:39+23
    assume {:print "$at(11,3497,3520)"} true;

    // assume WellFormed($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:39+23
    assume $IsValid'u64'($t3);

    // assume Eq<u64>($t3, $t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:39+23
    assume $IsEqual'u64'($t3, $t1);

    // $t3 := opaque end: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:39+23

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:39+23
    assume {:print "$track_return(4,6,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:63+1
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:81:63+1
    assume {:print "$at(11,3521,3522)"} true;
    $ret0 := $t3;
    return;

}

// fun error::permission_denied [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:3+77
procedure {:inline 1} $1_error_permission_denied(_$t0: int) returns ($ret0: int)
{
    // declare local variables
    var $t1: int;
    var $t2: int;
    var $t3: int;
    var $t0: int;
    var $temp_0'u64': int;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[r]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:3+1
    assume {:print "$at(11,3381,3382)"} true;
    assume {:print "$track_local(4,9,0):", $t0} $t0 == $t0;

    // $t1 := 5 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:57+17
    $t1 := 5;
    assume $IsValid'u64'($t1);

    // assume Identical($t2, Shl($t1, 16)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:69:5+29
    assume {:print "$at(11,2844,2873)"} true;
    assume ($t2 == $shlU64($t1, 16));

    // $t3 := opaque begin: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:47+31
    assume {:print "$at(11,3425,3456)"} true;

    // assume WellFormed($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:47+31
    assume $IsValid'u64'($t3);

    // assume Eq<u64>($t3, $t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:47+31
    assume $IsEqual'u64'($t3, $t1);

    // $t3 := opaque end: error::canonical($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:47+31

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:47+31
    assume {:print "$track_return(4,9,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:79+1
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/../move-stdlib/sources/error.move:80:79+1
    assume {:print "$at(11,3457,3458)"} true;
    $ret0 := $t3;
    return;

}

// struct type_info::TypeInfo at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/type_info.move:17:5+145
type {:datatype} $1_type_info_TypeInfo;
function {:constructor} $1_type_info_TypeInfo($account_address: int, $module_name: Vec (int), $struct_name: Vec (int)): $1_type_info_TypeInfo;
function {:inline} $Update'$1_type_info_TypeInfo'_account_address(s: $1_type_info_TypeInfo, x: int): $1_type_info_TypeInfo {
    $1_type_info_TypeInfo(x, $module_name#$1_type_info_TypeInfo(s), $struct_name#$1_type_info_TypeInfo(s))
}
function {:inline} $Update'$1_type_info_TypeInfo'_module_name(s: $1_type_info_TypeInfo, x: Vec (int)): $1_type_info_TypeInfo {
    $1_type_info_TypeInfo($account_address#$1_type_info_TypeInfo(s), x, $struct_name#$1_type_info_TypeInfo(s))
}
function {:inline} $Update'$1_type_info_TypeInfo'_struct_name(s: $1_type_info_TypeInfo, x: Vec (int)): $1_type_info_TypeInfo {
    $1_type_info_TypeInfo($account_address#$1_type_info_TypeInfo(s), $module_name#$1_type_info_TypeInfo(s), x)
}
function $IsValid'$1_type_info_TypeInfo'(s: $1_type_info_TypeInfo): bool {
    $IsValid'address'($account_address#$1_type_info_TypeInfo(s))
      && $IsValid'vec'u8''($module_name#$1_type_info_TypeInfo(s))
      && $IsValid'vec'u8''($struct_name#$1_type_info_TypeInfo(s))
}
function {:inline} $IsEqual'$1_type_info_TypeInfo'(s1: $1_type_info_TypeInfo, s2: $1_type_info_TypeInfo): bool {
    $IsEqual'address'($account_address#$1_type_info_TypeInfo(s1), $account_address#$1_type_info_TypeInfo(s2))
    && $IsEqual'vec'u8''($module_name#$1_type_info_TypeInfo(s1), $module_name#$1_type_info_TypeInfo(s2))
    && $IsEqual'vec'u8''($struct_name#$1_type_info_TypeInfo(s1), $struct_name#$1_type_info_TypeInfo(s2))}

// struct guid::GUID at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:6:5+50
type {:datatype} $1_guid_GUID;
function {:constructor} $1_guid_GUID($id: $1_guid_ID): $1_guid_GUID;
function {:inline} $Update'$1_guid_GUID'_id(s: $1_guid_GUID, x: $1_guid_ID): $1_guid_GUID {
    $1_guid_GUID(x)
}
function $IsValid'$1_guid_GUID'(s: $1_guid_GUID): bool {
    $IsValid'$1_guid_ID'($id#$1_guid_GUID(s))
}
function {:inline} $IsEqual'$1_guid_GUID'(s1: $1_guid_GUID, s2: $1_guid_GUID): bool {
    s1 == s2
}

// struct guid::ID at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:11:5+209
type {:datatype} $1_guid_ID;
function {:constructor} $1_guid_ID($creation_num: int, $addr: int): $1_guid_ID;
function {:inline} $Update'$1_guid_ID'_creation_num(s: $1_guid_ID, x: int): $1_guid_ID {
    $1_guid_ID(x, $addr#$1_guid_ID(s))
}
function {:inline} $Update'$1_guid_ID'_addr(s: $1_guid_ID, x: int): $1_guid_ID {
    $1_guid_ID($creation_num#$1_guid_ID(s), x)
}
function $IsValid'$1_guid_ID'(s: $1_guid_ID): bool {
    $IsValid'u64'($creation_num#$1_guid_ID(s))
      && $IsValid'address'($addr#$1_guid_ID(s))
}
function {:inline} $IsEqual'$1_guid_ID'(s1: $1_guid_ID, s2: $1_guid_ID): bool {
    s1 == s2
}

// fun guid::create [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:22:5+286
procedure {:inline 1} $1_guid_create(_$t0: int, _$t1: $Mutation (int)) returns ($ret0: $1_guid_GUID, $ret1: $Mutation (int))
{
    // declare local variables
    var $t2: int;
    var $t3: int;
    var $t4: int;
    var $t5: int;
    var $t6: int;
    var $t7: $1_guid_ID;
    var $t8: $1_guid_GUID;
    var $t0: int;
    var $t1: $Mutation (int);
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    var $temp_0'address': int;
    var $temp_0'u64': int;
    $t0 := _$t0;
    $t1 := _$t1;

    // bytecode translation starts here
    // trace_local[addr]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:22:5+1
    assume {:print "$at(94,800,801)"} true;
    assume {:print "$track_local(13,0,0):", $t0} $t0 == $t0;

    // trace_local[creation_num_ref]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:22:5+1
    $temp_0'u64' := $Dereference($t1);
    assume {:print "$track_local(13,0,1):", $temp_0'u64'} $temp_0'u64' == $temp_0'u64';

    // $t3 := read_ref($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:23:28+17
    assume {:print "$at(94,904,921)"} true;
    $t3 := $Dereference($t1);

    // trace_local[creation_num]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:23:13+12
    assume {:print "$track_local(13,0,2):", $t3} $t3 == $t3;

    // $t4 := 1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:24:44+1
    assume {:print "$at(94,966,967)"} true;
    $t4 := 1;
    assume $IsValid'u64'($t4);

    // $t5 := +($t3, $t4) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:24:42+1
    call $t5 := $AddU64($t3, $t4);
    if ($abort_flag) {
        assume {:print "$at(94,964,965)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(13,0):", $t6} $t6 == $t6;
        goto L2;
    }

    // write_ref($t1, $t5) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:24:9+36
    $t1 := $UpdateMutation($t1, $t5);

    // $t7 := pack guid::ID($t3, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:26:17+70
    assume {:print "$at(94,1000,1070)"} true;
    $t7 := $1_guid_ID($t3, $t0);

    // $t8 := pack guid::GUID($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:25:9+103
    assume {:print "$at(94,977,1080)"} true;
    $t8 := $1_guid_GUID($t7);

    // trace_return[0]($t8) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:25:9+103
    assume {:print "$track_return(13,0,0):", $t8} $t8 == $t8;

    // trace_local[creation_num_ref]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:25:9+103
    $temp_0'u64' := $Dereference($t1);
    assume {:print "$track_local(13,0,1):", $temp_0'u64'} $temp_0'u64' == $temp_0'u64';

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:31:5+1
    assume {:print "$at(94,1085,1086)"} true;
L1:

    // return $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:31:5+1
    assume {:print "$at(94,1085,1086)"} true;
    $ret0 := $t8;
    $ret1 := $t1;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:31:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/guid.move:31:5+1
    assume {:print "$at(94,1085,1086)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'bool'(bytes: Vec (int)): bool;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'bool'(bytes);
$IsValid'bool'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'u64'(bytes: Vec (int)): int;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'u64'(bytes);
$IsValid'u64'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'u128'(bytes: Vec (int)): int;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'u128'(bytes);
$IsValid'u128'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'u256'(bytes: Vec (int)): int;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'u256'(bytes);
$IsValid'u256'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'address'(bytes: Vec (int)): int;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'address'(bytes);
$IsValid'address'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'signer'(bytes: Vec (int)): $signer;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'signer'(bytes);
$IsValid'signer'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'vec'u8''(bytes: Vec (int)): Vec (int);
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'vec'u8''(bytes);
$IsValid'vec'u8''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'vec'address''(bytes: Vec (int)): Vec (int);
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'vec'address''(bytes);
$IsValid'vec'address''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'vec'#0''(bytes: Vec (int)): Vec (#0);
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'vec'#0''(bytes);
$IsValid'vec'#0''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_option_Option'address''(bytes: Vec (int)): $1_option_Option'address';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_option_Option'address''(bytes);
$IsValid'$1_option_Option'address''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_string_String'(bytes: Vec (int)): $1_string_String;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_string_String'(bytes);
$IsValid'$1_string_String'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_type_info_TypeInfo'(bytes: Vec (int)): $1_type_info_TypeInfo;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_type_info_TypeInfo'(bytes);
$IsValid'$1_type_info_TypeInfo'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_guid_GUID'(bytes: Vec (int)): $1_guid_GUID;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_guid_GUID'(bytes);
$IsValid'$1_guid_GUID'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_guid_ID'(bytes: Vec (int)): $1_guid_ID;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_guid_ID'(bytes);
$IsValid'$1_guid_ID'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_CoinRegisterEvent''(bytes: Vec (int)): $1_event_EventHandle'$1_account_CoinRegisterEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_CoinRegisterEvent''(bytes);
$IsValid'$1_event_EventHandle'$1_account_CoinRegisterEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_KeyRotationEvent''(bytes: Vec (int)): $1_event_EventHandle'$1_account_KeyRotationEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$1_account_KeyRotationEvent''(bytes);
$IsValid'$1_event_EventHandle'$1_account_KeyRotationEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_DepositEvent''(bytes: Vec (int)): $1_event_EventHandle'$1_coin_DepositEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_DepositEvent''(bytes);
$IsValid'$1_event_EventHandle'$1_coin_DepositEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_WithdrawEvent''(bytes: Vec (int)): $1_event_EventHandle'$1_coin_WithdrawEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$1_coin_WithdrawEvent''(bytes);
$IsValid'$1_event_EventHandle'$1_coin_WithdrawEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(bytes: Vec (int)): $1_event_EventHandle'$1_reconfiguration_NewEpochEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(bytes);
$IsValid'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(bytes: Vec (int)): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(bytes);
$IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(bytes: Vec (int)): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(bytes);
$IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(bytes: Vec (int)): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(bytes);
$IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(bytes: Vec (int)): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(bytes);
$IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_account_Account'(bytes: Vec (int)): $1_account_Account;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_account_Account'(bytes);
$IsValid'$1_account_Account'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_RotationCapability''(bytes: Vec (int)): $1_account_CapabilityOffer'$1_account_RotationCapability';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_RotationCapability''(bytes);
$IsValid'$1_account_CapabilityOffer'$1_account_RotationCapability''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_SignerCapability''(bytes: Vec (int)): $1_account_CapabilityOffer'$1_account_SignerCapability';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_account_CapabilityOffer'$1_account_SignerCapability''(bytes);
$IsValid'$1_account_CapabilityOffer'$1_account_SignerCapability''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_coin_Coin'#0''(bytes: Vec (int)): $1_coin_Coin'#0';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_coin_Coin'#0''(bytes);
$IsValid'$1_coin_Coin'#0''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_coin_CoinStore'#0''(bytes: Vec (int)): $1_coin_CoinStore'#0';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_coin_CoinStore'#0''(bytes);
$IsValid'$1_coin_CoinStore'#0''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_coin_WithdrawEvent'(bytes: Vec (int)): $1_coin_WithdrawEvent;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_coin_WithdrawEvent'(bytes);
$IsValid'$1_coin_WithdrawEvent'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_chain_status_GenesisEndMarker'(bytes: Vec (int)): $1_chain_status_GenesisEndMarker;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_chain_status_GenesisEndMarker'(bytes);
$IsValid'$1_chain_status_GenesisEndMarker'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_timestamp_CurrentTimeMicroseconds'(bytes: Vec (int)): $1_timestamp_CurrentTimeMicroseconds;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_timestamp_CurrentTimeMicroseconds'(bytes);
$IsValid'$1_timestamp_CurrentTimeMicroseconds'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$1_reconfiguration_Configuration'(bytes: Vec (int)): $1_reconfiguration_Configuration;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$1_reconfiguration_Configuration'(bytes);
$IsValid'$1_reconfiguration_Configuration'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(bytes: Vec (int)): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(bytes);
$IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(bytes: Vec (int)): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(bytes);
$IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''($$res)));

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/../aptos-stdlib/sources/from_bcs.spec.move:7:9+41
function  $1_from_bcs_deserialize'#0'(bytes: Vec (int)): #0;
axiom (forall bytes: Vec (int) ::
(var $$res := $1_from_bcs_deserialize'#0'(bytes);
$IsValid'#0'($$res)));

// struct event::EventHandle<account::CoinRegisterEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$1_account_CoinRegisterEvent';
function {:constructor} $1_event_EventHandle'$1_account_CoinRegisterEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$1_account_CoinRegisterEvent';
function {:inline} $Update'$1_event_EventHandle'$1_account_CoinRegisterEvent''_counter(s: $1_event_EventHandle'$1_account_CoinRegisterEvent', x: int): $1_event_EventHandle'$1_account_CoinRegisterEvent' {
    $1_event_EventHandle'$1_account_CoinRegisterEvent'(x, $guid#$1_event_EventHandle'$1_account_CoinRegisterEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$1_account_CoinRegisterEvent''_guid(s: $1_event_EventHandle'$1_account_CoinRegisterEvent', x: $1_guid_GUID): $1_event_EventHandle'$1_account_CoinRegisterEvent' {
    $1_event_EventHandle'$1_account_CoinRegisterEvent'($counter#$1_event_EventHandle'$1_account_CoinRegisterEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$1_account_CoinRegisterEvent''(s: $1_event_EventHandle'$1_account_CoinRegisterEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$1_account_CoinRegisterEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$1_account_CoinRegisterEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$1_account_CoinRegisterEvent''(s1: $1_event_EventHandle'$1_account_CoinRegisterEvent', s2: $1_event_EventHandle'$1_account_CoinRegisterEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<account::KeyRotationEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$1_account_KeyRotationEvent';
function {:constructor} $1_event_EventHandle'$1_account_KeyRotationEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$1_account_KeyRotationEvent';
function {:inline} $Update'$1_event_EventHandle'$1_account_KeyRotationEvent''_counter(s: $1_event_EventHandle'$1_account_KeyRotationEvent', x: int): $1_event_EventHandle'$1_account_KeyRotationEvent' {
    $1_event_EventHandle'$1_account_KeyRotationEvent'(x, $guid#$1_event_EventHandle'$1_account_KeyRotationEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$1_account_KeyRotationEvent''_guid(s: $1_event_EventHandle'$1_account_KeyRotationEvent', x: $1_guid_GUID): $1_event_EventHandle'$1_account_KeyRotationEvent' {
    $1_event_EventHandle'$1_account_KeyRotationEvent'($counter#$1_event_EventHandle'$1_account_KeyRotationEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$1_account_KeyRotationEvent''(s: $1_event_EventHandle'$1_account_KeyRotationEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$1_account_KeyRotationEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$1_account_KeyRotationEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$1_account_KeyRotationEvent''(s1: $1_event_EventHandle'$1_account_KeyRotationEvent', s2: $1_event_EventHandle'$1_account_KeyRotationEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<coin::DepositEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$1_coin_DepositEvent';
function {:constructor} $1_event_EventHandle'$1_coin_DepositEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$1_coin_DepositEvent';
function {:inline} $Update'$1_event_EventHandle'$1_coin_DepositEvent''_counter(s: $1_event_EventHandle'$1_coin_DepositEvent', x: int): $1_event_EventHandle'$1_coin_DepositEvent' {
    $1_event_EventHandle'$1_coin_DepositEvent'(x, $guid#$1_event_EventHandle'$1_coin_DepositEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$1_coin_DepositEvent''_guid(s: $1_event_EventHandle'$1_coin_DepositEvent', x: $1_guid_GUID): $1_event_EventHandle'$1_coin_DepositEvent' {
    $1_event_EventHandle'$1_coin_DepositEvent'($counter#$1_event_EventHandle'$1_coin_DepositEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$1_coin_DepositEvent''(s: $1_event_EventHandle'$1_coin_DepositEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$1_coin_DepositEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$1_coin_DepositEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$1_coin_DepositEvent''(s1: $1_event_EventHandle'$1_coin_DepositEvent', s2: $1_event_EventHandle'$1_coin_DepositEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<coin::WithdrawEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$1_coin_WithdrawEvent';
function {:constructor} $1_event_EventHandle'$1_coin_WithdrawEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$1_coin_WithdrawEvent';
function {:inline} $Update'$1_event_EventHandle'$1_coin_WithdrawEvent''_counter(s: $1_event_EventHandle'$1_coin_WithdrawEvent', x: int): $1_event_EventHandle'$1_coin_WithdrawEvent' {
    $1_event_EventHandle'$1_coin_WithdrawEvent'(x, $guid#$1_event_EventHandle'$1_coin_WithdrawEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$1_coin_WithdrawEvent''_guid(s: $1_event_EventHandle'$1_coin_WithdrawEvent', x: $1_guid_GUID): $1_event_EventHandle'$1_coin_WithdrawEvent' {
    $1_event_EventHandle'$1_coin_WithdrawEvent'($counter#$1_event_EventHandle'$1_coin_WithdrawEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$1_coin_WithdrawEvent''(s: $1_event_EventHandle'$1_coin_WithdrawEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$1_coin_WithdrawEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$1_coin_WithdrawEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$1_coin_WithdrawEvent''(s1: $1_event_EventHandle'$1_coin_WithdrawEvent', s2: $1_event_EventHandle'$1_coin_WithdrawEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<reconfiguration::NewEpochEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$1_reconfiguration_NewEpochEvent';
function {:constructor} $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$1_reconfiguration_NewEpochEvent';
function {:inline} $Update'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''_counter(s: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent', x: int): $1_event_EventHandle'$1_reconfiguration_NewEpochEvent' {
    $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'(x, $guid#$1_event_EventHandle'$1_reconfiguration_NewEpochEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''_guid(s: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent', x: $1_guid_GUID): $1_event_EventHandle'$1_reconfiguration_NewEpochEvent' {
    $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'($counter#$1_event_EventHandle'$1_reconfiguration_NewEpochEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(s: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$1_reconfiguration_NewEpochEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$1_reconfiguration_NewEpochEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''(s1: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent', s2: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<per_second_v8::CloseSessionEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
function {:constructor} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''_counter(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent', x: int): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(x, $guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''_guid(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent', x: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''(s1: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent', s2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<per_second_v8::CreateSessionEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
function {:constructor} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''_counter(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent', x: int): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(x, $guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''_guid(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent', x: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''(s1: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent', s2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<per_second_v8::JoinSessionEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
function {:constructor} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''_counter(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent', x: int): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(x, $guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''_guid(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent', x: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''(s1: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent', s2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'): bool {
    s1 == s2
}

// struct event::EventHandle<per_second_v8::StartSessionEvent> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:15:5+224
type {:datatype} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
function {:constructor} $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'($counter: int, $guid: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''_counter(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent', x: int): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(x, $guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s))
}
function {:inline} $Update'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''_guid(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent', x: $1_guid_GUID): $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent' {
    $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s), x)
}
function $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(s: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'): bool {
    $IsValid'u64'($counter#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s))
      && $IsValid'$1_guid_GUID'($guid#$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s))
}
function {:inline} $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''(s1: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent', s2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'): bool {
    s1 == s2
}

// fun event::new_event_handle<per_second_v8::CloseSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+165
procedure {:inline 1} $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(_$t0: $1_guid_GUID) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
    var $t0: $1_guid_GUID;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[guid]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+1
    assume {:print "$at(89,942,943)"} true;
    assume {:print "$track_local(15,4,0):", $t0} $t0 == $t0;

    // $t1 := 0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:25:22+1
    assume {:print "$at(89,1071,1072)"} true;
    $t1 := 0;
    assume $IsValid'u64'($t1);

    // $t2 := pack event::EventHandle<#0>($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$at(89,1033,1101)"} true;
    $t2 := $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'($t1, $t0);

    // trace_return[0]($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$track_return(15,4,0):", $t2} $t2 == $t2;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
L1:

    // return $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
    $ret0 := $t2;
    return;

}

// fun event::new_event_handle<per_second_v8::CreateSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+165
procedure {:inline 1} $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(_$t0: $1_guid_GUID) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
    var $t0: $1_guid_GUID;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[guid]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+1
    assume {:print "$at(89,942,943)"} true;
    assume {:print "$track_local(15,4,0):", $t0} $t0 == $t0;

    // $t1 := 0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:25:22+1
    assume {:print "$at(89,1071,1072)"} true;
    $t1 := 0;
    assume $IsValid'u64'($t1);

    // $t2 := pack event::EventHandle<#0>($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$at(89,1033,1101)"} true;
    $t2 := $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($t1, $t0);

    // trace_return[0]($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$track_return(15,4,0):", $t2} $t2 == $t2;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
L1:

    // return $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
    $ret0 := $t2;
    return;

}

// fun event::new_event_handle<per_second_v8::JoinSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+165
procedure {:inline 1} $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(_$t0: $1_guid_GUID) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
    var $t0: $1_guid_GUID;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[guid]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+1
    assume {:print "$at(89,942,943)"} true;
    assume {:print "$track_local(15,4,0):", $t0} $t0 == $t0;

    // $t1 := 0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:25:22+1
    assume {:print "$at(89,1071,1072)"} true;
    $t1 := 0;
    assume $IsValid'u64'($t1);

    // $t2 := pack event::EventHandle<#0>($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$at(89,1033,1101)"} true;
    $t2 := $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'($t1, $t0);

    // trace_return[0]($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$track_return(15,4,0):", $t2} $t2 == $t2;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
L1:

    // return $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
    $ret0 := $t2;
    return;

}

// fun event::new_event_handle<per_second_v8::StartSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+165
procedure {:inline 1} $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(_$t0: $1_guid_GUID) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
    var $t0: $1_guid_GUID;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[guid]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:23:5+1
    assume {:print "$at(89,942,943)"} true;
    assume {:print "$track_local(15,4,0):", $t0} $t0 == $t0;

    // $t1 := 0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:25:22+1
    assume {:print "$at(89,1071,1072)"} true;
    $t1 := 0;
    assume $IsValid'u64'($t1);

    // $t2 := pack event::EventHandle<#0>($t1, $t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$at(89,1033,1101)"} true;
    $t2 := $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'($t1, $t0);

    // trace_return[0]($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:24:9+68
    assume {:print "$track_return(15,4,0):", $t2} $t2 == $t2;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
L1:

    // return $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/event.move:28:5+1
    assume {:print "$at(89,1106,1107)"} true;
    $ret0 := $t2;
    return;

}

// struct account::Account at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:25:5+401
type {:datatype} $1_account_Account;
function {:constructor} $1_account_Account($authentication_key: Vec (int), $sequence_number: int, $guid_creation_num: int, $coin_register_events: $1_event_EventHandle'$1_account_CoinRegisterEvent', $key_rotation_events: $1_event_EventHandle'$1_account_KeyRotationEvent', $rotation_capability_offer: $1_account_CapabilityOffer'$1_account_RotationCapability', $signer_capability_offer: $1_account_CapabilityOffer'$1_account_SignerCapability'): $1_account_Account;
function {:inline} $Update'$1_account_Account'_authentication_key(s: $1_account_Account, x: Vec (int)): $1_account_Account {
    $1_account_Account(x, $sequence_number#$1_account_Account(s), $guid_creation_num#$1_account_Account(s), $coin_register_events#$1_account_Account(s), $key_rotation_events#$1_account_Account(s), $rotation_capability_offer#$1_account_Account(s), $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_sequence_number(s: $1_account_Account, x: int): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), x, $guid_creation_num#$1_account_Account(s), $coin_register_events#$1_account_Account(s), $key_rotation_events#$1_account_Account(s), $rotation_capability_offer#$1_account_Account(s), $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_guid_creation_num(s: $1_account_Account, x: int): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), $sequence_number#$1_account_Account(s), x, $coin_register_events#$1_account_Account(s), $key_rotation_events#$1_account_Account(s), $rotation_capability_offer#$1_account_Account(s), $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_coin_register_events(s: $1_account_Account, x: $1_event_EventHandle'$1_account_CoinRegisterEvent'): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), $sequence_number#$1_account_Account(s), $guid_creation_num#$1_account_Account(s), x, $key_rotation_events#$1_account_Account(s), $rotation_capability_offer#$1_account_Account(s), $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_key_rotation_events(s: $1_account_Account, x: $1_event_EventHandle'$1_account_KeyRotationEvent'): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), $sequence_number#$1_account_Account(s), $guid_creation_num#$1_account_Account(s), $coin_register_events#$1_account_Account(s), x, $rotation_capability_offer#$1_account_Account(s), $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_rotation_capability_offer(s: $1_account_Account, x: $1_account_CapabilityOffer'$1_account_RotationCapability'): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), $sequence_number#$1_account_Account(s), $guid_creation_num#$1_account_Account(s), $coin_register_events#$1_account_Account(s), $key_rotation_events#$1_account_Account(s), x, $signer_capability_offer#$1_account_Account(s))
}
function {:inline} $Update'$1_account_Account'_signer_capability_offer(s: $1_account_Account, x: $1_account_CapabilityOffer'$1_account_SignerCapability'): $1_account_Account {
    $1_account_Account($authentication_key#$1_account_Account(s), $sequence_number#$1_account_Account(s), $guid_creation_num#$1_account_Account(s), $coin_register_events#$1_account_Account(s), $key_rotation_events#$1_account_Account(s), $rotation_capability_offer#$1_account_Account(s), x)
}
function $IsValid'$1_account_Account'(s: $1_account_Account): bool {
    $IsValid'vec'u8''($authentication_key#$1_account_Account(s))
      && $IsValid'u64'($sequence_number#$1_account_Account(s))
      && $IsValid'u64'($guid_creation_num#$1_account_Account(s))
      && $IsValid'$1_event_EventHandle'$1_account_CoinRegisterEvent''($coin_register_events#$1_account_Account(s))
      && $IsValid'$1_event_EventHandle'$1_account_KeyRotationEvent''($key_rotation_events#$1_account_Account(s))
      && $IsValid'$1_account_CapabilityOffer'$1_account_RotationCapability''($rotation_capability_offer#$1_account_Account(s))
      && $IsValid'$1_account_CapabilityOffer'$1_account_SignerCapability''($signer_capability_offer#$1_account_Account(s))
}
function {:inline} $IsEqual'$1_account_Account'(s1: $1_account_Account, s2: $1_account_Account): bool {
    $IsEqual'vec'u8''($authentication_key#$1_account_Account(s1), $authentication_key#$1_account_Account(s2))
    && $IsEqual'u64'($sequence_number#$1_account_Account(s1), $sequence_number#$1_account_Account(s2))
    && $IsEqual'u64'($guid_creation_num#$1_account_Account(s1), $guid_creation_num#$1_account_Account(s2))
    && $IsEqual'$1_event_EventHandle'$1_account_CoinRegisterEvent''($coin_register_events#$1_account_Account(s1), $coin_register_events#$1_account_Account(s2))
    && $IsEqual'$1_event_EventHandle'$1_account_KeyRotationEvent''($key_rotation_events#$1_account_Account(s1), $key_rotation_events#$1_account_Account(s2))
    && $IsEqual'$1_account_CapabilityOffer'$1_account_RotationCapability''($rotation_capability_offer#$1_account_Account(s1), $rotation_capability_offer#$1_account_Account(s2))
    && $IsEqual'$1_account_CapabilityOffer'$1_account_SignerCapability''($signer_capability_offer#$1_account_Account(s1), $signer_capability_offer#$1_account_Account(s2))}
var $1_account_Account_$memory: $Memory $1_account_Account;

// struct account::CapabilityOffer<account::RotationCapability> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:44:5+68
type {:datatype} $1_account_CapabilityOffer'$1_account_RotationCapability';
function {:constructor} $1_account_CapabilityOffer'$1_account_RotationCapability'($for: $1_option_Option'address'): $1_account_CapabilityOffer'$1_account_RotationCapability';
function {:inline} $Update'$1_account_CapabilityOffer'$1_account_RotationCapability''_for(s: $1_account_CapabilityOffer'$1_account_RotationCapability', x: $1_option_Option'address'): $1_account_CapabilityOffer'$1_account_RotationCapability' {
    $1_account_CapabilityOffer'$1_account_RotationCapability'(x)
}
function $IsValid'$1_account_CapabilityOffer'$1_account_RotationCapability''(s: $1_account_CapabilityOffer'$1_account_RotationCapability'): bool {
    $IsValid'$1_option_Option'address''($for#$1_account_CapabilityOffer'$1_account_RotationCapability'(s))
}
function {:inline} $IsEqual'$1_account_CapabilityOffer'$1_account_RotationCapability''(s1: $1_account_CapabilityOffer'$1_account_RotationCapability', s2: $1_account_CapabilityOffer'$1_account_RotationCapability'): bool {
    $IsEqual'$1_option_Option'address''($for#$1_account_CapabilityOffer'$1_account_RotationCapability'(s1), $for#$1_account_CapabilityOffer'$1_account_RotationCapability'(s2))}

// struct account::CapabilityOffer<account::SignerCapability> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:44:5+68
type {:datatype} $1_account_CapabilityOffer'$1_account_SignerCapability';
function {:constructor} $1_account_CapabilityOffer'$1_account_SignerCapability'($for: $1_option_Option'address'): $1_account_CapabilityOffer'$1_account_SignerCapability';
function {:inline} $Update'$1_account_CapabilityOffer'$1_account_SignerCapability''_for(s: $1_account_CapabilityOffer'$1_account_SignerCapability', x: $1_option_Option'address'): $1_account_CapabilityOffer'$1_account_SignerCapability' {
    $1_account_CapabilityOffer'$1_account_SignerCapability'(x)
}
function $IsValid'$1_account_CapabilityOffer'$1_account_SignerCapability''(s: $1_account_CapabilityOffer'$1_account_SignerCapability'): bool {
    $IsValid'$1_option_Option'address''($for#$1_account_CapabilityOffer'$1_account_SignerCapability'(s))
}
function {:inline} $IsEqual'$1_account_CapabilityOffer'$1_account_SignerCapability''(s1: $1_account_CapabilityOffer'$1_account_SignerCapability', s2: $1_account_CapabilityOffer'$1_account_SignerCapability'): bool {
    $IsEqual'$1_option_Option'address''($for#$1_account_CapabilityOffer'$1_account_SignerCapability'(s1), $for#$1_account_CapabilityOffer'$1_account_SignerCapability'(s2))}

// struct account::CoinRegisterEvent at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:40:5+77
type {:datatype} $1_account_CoinRegisterEvent;
function {:constructor} $1_account_CoinRegisterEvent($type_info: $1_type_info_TypeInfo): $1_account_CoinRegisterEvent;
function {:inline} $Update'$1_account_CoinRegisterEvent'_type_info(s: $1_account_CoinRegisterEvent, x: $1_type_info_TypeInfo): $1_account_CoinRegisterEvent {
    $1_account_CoinRegisterEvent(x)
}
function $IsValid'$1_account_CoinRegisterEvent'(s: $1_account_CoinRegisterEvent): bool {
    $IsValid'$1_type_info_TypeInfo'($type_info#$1_account_CoinRegisterEvent(s))
}
function {:inline} $IsEqual'$1_account_CoinRegisterEvent'(s1: $1_account_CoinRegisterEvent, s2: $1_account_CoinRegisterEvent): bool {
    $IsEqual'$1_type_info_TypeInfo'($type_info#$1_account_CoinRegisterEvent(s1), $type_info#$1_account_CoinRegisterEvent(s2))}

// struct account::KeyRotationEvent at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:35:5+135
type {:datatype} $1_account_KeyRotationEvent;
function {:constructor} $1_account_KeyRotationEvent($old_authentication_key: Vec (int), $new_authentication_key: Vec (int)): $1_account_KeyRotationEvent;
function {:inline} $Update'$1_account_KeyRotationEvent'_old_authentication_key(s: $1_account_KeyRotationEvent, x: Vec (int)): $1_account_KeyRotationEvent {
    $1_account_KeyRotationEvent(x, $new_authentication_key#$1_account_KeyRotationEvent(s))
}
function {:inline} $Update'$1_account_KeyRotationEvent'_new_authentication_key(s: $1_account_KeyRotationEvent, x: Vec (int)): $1_account_KeyRotationEvent {
    $1_account_KeyRotationEvent($old_authentication_key#$1_account_KeyRotationEvent(s), x)
}
function $IsValid'$1_account_KeyRotationEvent'(s: $1_account_KeyRotationEvent): bool {
    $IsValid'vec'u8''($old_authentication_key#$1_account_KeyRotationEvent(s))
      && $IsValid'vec'u8''($new_authentication_key#$1_account_KeyRotationEvent(s))
}
function {:inline} $IsEqual'$1_account_KeyRotationEvent'(s1: $1_account_KeyRotationEvent, s2: $1_account_KeyRotationEvent): bool {
    $IsEqual'vec'u8''($old_authentication_key#$1_account_KeyRotationEvent(s1), $old_authentication_key#$1_account_KeyRotationEvent(s2))
    && $IsEqual'vec'u8''($new_authentication_key#$1_account_KeyRotationEvent(s1), $new_authentication_key#$1_account_KeyRotationEvent(s2))}

// struct account::RotationCapability at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:46:5+62
type {:datatype} $1_account_RotationCapability;
function {:constructor} $1_account_RotationCapability($account: int): $1_account_RotationCapability;
function {:inline} $Update'$1_account_RotationCapability'_account(s: $1_account_RotationCapability, x: int): $1_account_RotationCapability {
    $1_account_RotationCapability(x)
}
function $IsValid'$1_account_RotationCapability'(s: $1_account_RotationCapability): bool {
    $IsValid'address'($account#$1_account_RotationCapability(s))
}
function {:inline} $IsEqual'$1_account_RotationCapability'(s1: $1_account_RotationCapability, s2: $1_account_RotationCapability): bool {
    s1 == s2
}

// struct account::SignerCapability at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:48:5+60
type {:datatype} $1_account_SignerCapability;
function {:constructor} $1_account_SignerCapability($account: int): $1_account_SignerCapability;
function {:inline} $Update'$1_account_SignerCapability'_account(s: $1_account_SignerCapability, x: int): $1_account_SignerCapability {
    $1_account_SignerCapability(x)
}
function $IsValid'$1_account_SignerCapability'(s: $1_account_SignerCapability): bool {
    $IsValid'address'($account#$1_account_SignerCapability(s))
}
function {:inline} $IsEqual'$1_account_SignerCapability'(s1: $1_account_SignerCapability, s2: $1_account_SignerCapability): bool {
    s1 == s2
}

// fun account::new_event_handle<per_second_v8::CloseSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+157
procedure {:inline 1} $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(_$t0: $signer) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_account_Account;
    var $t3: int;
    var $t4: $1_account_Account;
    var $t5: $1_guid_GUID;
    var $t6: int;
    var $t7: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
    var $t0: $signer;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // assume Identical($t1, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t1 == $1_signer_$address_of($t0));

    // assume Identical($t2, global<account::Account>($t1)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t2 == $ResourceValue($1_account_Account_$memory, $t1));

    // trace_local[account]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+1
    assume {:print "$at(57,38259,38260)"} true;
    assume {:print "$track_local(17,17,0):", $t0} $t0 == $t0;

    // assume Identical($t3, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:247:9+46
    assume {:print "$at(58,11405,11451)"} true;
    assume ($t3 == $1_signer_$address_of($t0));

    // assume Identical($t4, global<account::Account>($t3)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:248:9+36
    assume {:print "$at(58,11460,11496)"} true;
    assume ($t4 == $ResourceValue($1_account_Account_$memory, $t3));

    // $t5 := account::create_guid($t0) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:33+20
    assume {:print "$at(57,38389,38409)"} true;
    call $t5 := $1_account_create_guid($t0);
    if ($abort_flag) {
        assume {:print "$at(57,38389,38409)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // $t7 := event::new_event_handle<#0>($t5) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    call $t7 := $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'($t5);
    if ($abort_flag) {
        assume {:print "$at(57,38365,38410)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_return[0]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    assume {:print "$track_return(17,17,0):", $t7} $t7 == $t7;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
L1:

    // return $t7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $ret0 := $t7;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// fun account::new_event_handle<per_second_v8::CreateSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+157
procedure {:inline 1} $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(_$t0: $signer) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_account_Account;
    var $t3: int;
    var $t4: $1_account_Account;
    var $t5: $1_guid_GUID;
    var $t6: int;
    var $t7: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
    var $t0: $signer;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // assume Identical($t1, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t1 == $1_signer_$address_of($t0));

    // assume Identical($t2, global<account::Account>($t1)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t2 == $ResourceValue($1_account_Account_$memory, $t1));

    // trace_local[account]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+1
    assume {:print "$at(57,38259,38260)"} true;
    assume {:print "$track_local(17,17,0):", $t0} $t0 == $t0;

    // assume Identical($t3, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:247:9+46
    assume {:print "$at(58,11405,11451)"} true;
    assume ($t3 == $1_signer_$address_of($t0));

    // assume Identical($t4, global<account::Account>($t3)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:248:9+36
    assume {:print "$at(58,11460,11496)"} true;
    assume ($t4 == $ResourceValue($1_account_Account_$memory, $t3));

    // $t5 := account::create_guid($t0) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:33+20
    assume {:print "$at(57,38389,38409)"} true;
    call $t5 := $1_account_create_guid($t0);
    if ($abort_flag) {
        assume {:print "$at(57,38389,38409)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // $t7 := event::new_event_handle<#0>($t5) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    call $t7 := $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($t5);
    if ($abort_flag) {
        assume {:print "$at(57,38365,38410)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_return[0]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    assume {:print "$track_return(17,17,0):", $t7} $t7 == $t7;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
L1:

    // return $t7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $ret0 := $t7;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// fun account::new_event_handle<per_second_v8::JoinSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+157
procedure {:inline 1} $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(_$t0: $signer) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_account_Account;
    var $t3: int;
    var $t4: $1_account_Account;
    var $t5: $1_guid_GUID;
    var $t6: int;
    var $t7: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
    var $t0: $signer;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // assume Identical($t1, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t1 == $1_signer_$address_of($t0));

    // assume Identical($t2, global<account::Account>($t1)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t2 == $ResourceValue($1_account_Account_$memory, $t1));

    // trace_local[account]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+1
    assume {:print "$at(57,38259,38260)"} true;
    assume {:print "$track_local(17,17,0):", $t0} $t0 == $t0;

    // assume Identical($t3, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:247:9+46
    assume {:print "$at(58,11405,11451)"} true;
    assume ($t3 == $1_signer_$address_of($t0));

    // assume Identical($t4, global<account::Account>($t3)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:248:9+36
    assume {:print "$at(58,11460,11496)"} true;
    assume ($t4 == $ResourceValue($1_account_Account_$memory, $t3));

    // $t5 := account::create_guid($t0) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:33+20
    assume {:print "$at(57,38389,38409)"} true;
    call $t5 := $1_account_create_guid($t0);
    if ($abort_flag) {
        assume {:print "$at(57,38389,38409)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // $t7 := event::new_event_handle<#0>($t5) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    call $t7 := $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'($t5);
    if ($abort_flag) {
        assume {:print "$at(57,38365,38410)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_return[0]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    assume {:print "$track_return(17,17,0):", $t7} $t7 == $t7;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
L1:

    // return $t7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $ret0 := $t7;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// fun account::new_event_handle<per_second_v8::StartSessionEvent> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+157
procedure {:inline 1} $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(_$t0: $signer) returns ($ret0: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent')
{
    // declare local variables
    var $t1: int;
    var $t2: $1_account_Account;
    var $t3: int;
    var $t4: $1_account_Account;
    var $t5: $1_guid_GUID;
    var $t6: int;
    var $t7: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
    var $t0: $signer;
    var $temp_0'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'': $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // assume Identical($t1, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t1 == $1_signer_$address_of($t0));

    // assume Identical($t2, global<account::Account>($t1)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t2 == $ResourceValue($1_account_Account_$memory, $t1));

    // trace_local[account]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:663:5+1
    assume {:print "$at(57,38259,38260)"} true;
    assume {:print "$track_local(17,17,0):", $t0} $t0 == $t0;

    // assume Identical($t3, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:247:9+46
    assume {:print "$at(58,11405,11451)"} true;
    assume ($t3 == $1_signer_$address_of($t0));

    // assume Identical($t4, global<account::Account>($t3)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:248:9+36
    assume {:print "$at(58,11460,11496)"} true;
    assume ($t4 == $ResourceValue($1_account_Account_$memory, $t3));

    // $t5 := account::create_guid($t0) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:33+20
    assume {:print "$at(57,38389,38409)"} true;
    call $t5 := $1_account_create_guid($t0);
    if ($abort_flag) {
        assume {:print "$at(57,38389,38409)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // $t7 := event::new_event_handle<#0>($t5) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    call $t7 := $1_event_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'($t5);
    if ($abort_flag) {
        assume {:print "$at(57,38365,38410)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,17):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_return[0]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:664:9+45
    assume {:print "$track_return(17,17,0):", $t7} $t7 == $t7;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
L1:

    // return $t7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $ret0 := $t7;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:665:5+1
    assume {:print "$at(57,38415,38416)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// fun account::create_guid [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:653:5+254
procedure {:inline 1} $1_account_create_guid(_$t0: $signer) returns ($ret0: $1_guid_GUID)
{
    // declare local variables
    var $t1: $Mutation ($1_account_Account);
    var $t2: int;
    var $t3: int;
    var $t4: $1_account_Account;
    var $t5: int;
    var $t6: int;
    var $t7: $Mutation ($1_account_Account);
    var $t8: $Mutation (int);
    var $t9: $1_guid_GUID;
    var $t0: $signer;
    var $1_account_Account_$modifies: [int]bool;
    var $temp_0'$1_account_Account': $1_account_Account;
    var $temp_0'$1_guid_GUID': $1_guid_GUID;
    var $temp_0'address': int;
    var $temp_0'signer': $signer;
    $t0 := _$t0;

    // bytecode translation starts here
    // assume Identical($t3, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:247:9+46
    assume {:print "$at(58,11405,11451)"} true;
    assume ($t3 == $1_signer_$address_of($t0));

    // assume Identical($t4, global<account::Account>($t3)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:248:9+36
    assume {:print "$at(58,11460,11496)"} true;
    assume ($t4 == $ResourceValue($1_account_Account_$memory, $t3));

    // trace_local[account_signer]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:653:5+1
    assume {:print "$at(57,37805,37806)"} true;
    assume {:print "$track_local(17,5,0):", $t0} $t0 == $t0;

    // $t5 := signer::address_of($t0) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:654:20+34
    assume {:print "$at(57,37903,37937)"} true;
    call $t5 := $1_signer_address_of($t0);
    if ($abort_flag) {
        assume {:print "$at(57,37903,37937)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,5):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_local[addr]($t5) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:654:13+4
    assume {:print "$track_local(17,5,2):", $t5} $t5 == $t5;

    // $t7 := borrow_global<account::Account>($t5) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:655:23+17
    assume {:print "$at(57,37961,37978)"} true;
    if (!$ResourceExists($1_account_Account_$memory, $t5)) {
        call $ExecFailureAbort();
    } else {
        $t7 := $Mutation($Global($t5), EmptyVec(), $ResourceValue($1_account_Account_$memory, $t5));
    }
    if ($abort_flag) {
        assume {:print "$at(57,37961,37978)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,5):", $t6} $t6 == $t6;
        goto L2;
    }

    // trace_local[account]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:655:13+7
    $temp_0'$1_account_Account' := $Dereference($t7);
    assume {:print "$track_local(17,5,1):", $temp_0'$1_account_Account'} $temp_0'$1_account_Account' == $temp_0'$1_account_Account';

    // $t8 := borrow_field<account::Account>.guid_creation_num($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:28+30
    assume {:print "$at(57,38022,38052)"} true;
    $t8 := $ChildMutation($t7, 2, $guid_creation_num#$1_account_Account($Dereference($t7)));

    // $t9 := guid::create($t5, $t8) on_abort goto L2 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:9+50
    call $t9,$t8 := $1_guid_create($t5, $t8);
    if ($abort_flag) {
        assume {:print "$at(57,38003,38053)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(17,5):", $t6} $t6 == $t6;
        goto L2;
    }

    // write_back[Reference($t7).guid_creation_num (u64)]($t8) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:9+50
    $t7 := $UpdateMutation($t7, $Update'$1_account_Account'_guid_creation_num($Dereference($t7), $Dereference($t8)));

    // pack_ref_deep($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:9+50

    // write_back[account::Account@]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:9+50
    $1_account_Account_$memory := $ResourceUpdate($1_account_Account_$memory, $GlobalLocationAddress($t7),
        $Dereference($t7));

    // trace_return[0]($t9) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:656:9+50
    assume {:print "$track_return(17,5,0):", $t9} $t9 == $t9;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:657:5+1
    assume {:print "$at(57,38058,38059)"} true;
L1:

    // return $t9 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:657:5+1
    assume {:print "$at(57,38058,38059)"} true;
    $ret0 := $t9;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:657:5+1
L2:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.move:657:5+1
    assume {:print "$at(57,38058,38059)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// struct coin::Coin<#0> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:74:5+112
type {:datatype} $1_coin_Coin'#0';
function {:constructor} $1_coin_Coin'#0'($value: int): $1_coin_Coin'#0';
function {:inline} $Update'$1_coin_Coin'#0''_value(s: $1_coin_Coin'#0', x: int): $1_coin_Coin'#0' {
    $1_coin_Coin'#0'(x)
}
function $IsValid'$1_coin_Coin'#0''(s: $1_coin_Coin'#0'): bool {
    $IsValid'u64'($value#$1_coin_Coin'#0'(s))
}
function {:inline} $IsEqual'$1_coin_Coin'#0''(s1: $1_coin_Coin'#0', s2: $1_coin_Coin'#0'): bool {
    s1 == s2
}

// struct coin::CoinStore<#0> at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:92:5+206
type {:datatype} $1_coin_CoinStore'#0';
function {:constructor} $1_coin_CoinStore'#0'($coin: $1_coin_Coin'#0', $frozen: bool, $deposit_events: $1_event_EventHandle'$1_coin_DepositEvent', $withdraw_events: $1_event_EventHandle'$1_coin_WithdrawEvent'): $1_coin_CoinStore'#0';
function {:inline} $Update'$1_coin_CoinStore'#0''_coin(s: $1_coin_CoinStore'#0', x: $1_coin_Coin'#0'): $1_coin_CoinStore'#0' {
    $1_coin_CoinStore'#0'(x, $frozen#$1_coin_CoinStore'#0'(s), $deposit_events#$1_coin_CoinStore'#0'(s), $withdraw_events#$1_coin_CoinStore'#0'(s))
}
function {:inline} $Update'$1_coin_CoinStore'#0''_frozen(s: $1_coin_CoinStore'#0', x: bool): $1_coin_CoinStore'#0' {
    $1_coin_CoinStore'#0'($coin#$1_coin_CoinStore'#0'(s), x, $deposit_events#$1_coin_CoinStore'#0'(s), $withdraw_events#$1_coin_CoinStore'#0'(s))
}
function {:inline} $Update'$1_coin_CoinStore'#0''_deposit_events(s: $1_coin_CoinStore'#0', x: $1_event_EventHandle'$1_coin_DepositEvent'): $1_coin_CoinStore'#0' {
    $1_coin_CoinStore'#0'($coin#$1_coin_CoinStore'#0'(s), $frozen#$1_coin_CoinStore'#0'(s), x, $withdraw_events#$1_coin_CoinStore'#0'(s))
}
function {:inline} $Update'$1_coin_CoinStore'#0''_withdraw_events(s: $1_coin_CoinStore'#0', x: $1_event_EventHandle'$1_coin_WithdrawEvent'): $1_coin_CoinStore'#0' {
    $1_coin_CoinStore'#0'($coin#$1_coin_CoinStore'#0'(s), $frozen#$1_coin_CoinStore'#0'(s), $deposit_events#$1_coin_CoinStore'#0'(s), x)
}
function $IsValid'$1_coin_CoinStore'#0''(s: $1_coin_CoinStore'#0'): bool {
    $IsValid'$1_coin_Coin'#0''($coin#$1_coin_CoinStore'#0'(s))
      && $IsValid'bool'($frozen#$1_coin_CoinStore'#0'(s))
      && $IsValid'$1_event_EventHandle'$1_coin_DepositEvent''($deposit_events#$1_coin_CoinStore'#0'(s))
      && $IsValid'$1_event_EventHandle'$1_coin_WithdrawEvent''($withdraw_events#$1_coin_CoinStore'#0'(s))
}
function {:inline} $IsEqual'$1_coin_CoinStore'#0''(s1: $1_coin_CoinStore'#0', s2: $1_coin_CoinStore'#0'): bool {
    s1 == s2
}
var $1_coin_CoinStore'#0'_$memory: $Memory $1_coin_CoinStore'#0';

// struct coin::DepositEvent at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:123:5+64
type {:datatype} $1_coin_DepositEvent;
function {:constructor} $1_coin_DepositEvent($amount: int): $1_coin_DepositEvent;
function {:inline} $Update'$1_coin_DepositEvent'_amount(s: $1_coin_DepositEvent, x: int): $1_coin_DepositEvent {
    $1_coin_DepositEvent(x)
}
function $IsValid'$1_coin_DepositEvent'(s: $1_coin_DepositEvent): bool {
    $IsValid'u64'($amount#$1_coin_DepositEvent(s))
}
function {:inline} $IsEqual'$1_coin_DepositEvent'(s1: $1_coin_DepositEvent, s2: $1_coin_DepositEvent): bool {
    s1 == s2
}

// struct coin::WithdrawEvent at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:128:5+65
type {:datatype} $1_coin_WithdrawEvent;
function {:constructor} $1_coin_WithdrawEvent($amount: int): $1_coin_WithdrawEvent;
function {:inline} $Update'$1_coin_WithdrawEvent'_amount(s: $1_coin_WithdrawEvent, x: int): $1_coin_WithdrawEvent {
    $1_coin_WithdrawEvent(x)
}
function $IsValid'$1_coin_WithdrawEvent'(s: $1_coin_WithdrawEvent): bool {
    $IsValid'u64'($amount#$1_coin_WithdrawEvent(s))
}
function {:inline} $IsEqual'$1_coin_WithdrawEvent'(s1: $1_coin_WithdrawEvent, s2: $1_coin_WithdrawEvent): bool {
    s1 == s2
}

// fun coin::extract<#0> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:343:5+252
procedure {:inline 1} $1_coin_extract'#0'(_$t0: $Mutation ($1_coin_Coin'#0'), _$t1: int) returns ($ret0: $1_coin_Coin'#0', $ret1: $Mutation ($1_coin_Coin'#0'))
{
    // declare local variables
    var $t2: int;
    var $t3: bool;
    var $t4: int;
    var $t5: int;
    var $t6: int;
    var $t7: int;
    var $t8: int;
    var $t9: $Mutation (int);
    var $t10: $1_coin_Coin'#0';
    var $t0: $Mutation ($1_coin_Coin'#0');
    var $t1: int;
    var $temp_0'$1_coin_Coin'#0'': $1_coin_Coin'#0';
    var $temp_0'u64': int;
    $t0 := _$t0;
    $t1 := _$t1;

    // bytecode translation starts here
    // trace_local[coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:343:5+1
    assume {:print "$at(79,13184,13185)"} true;
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,13,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // trace_local[amount]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:343:5+1
    assume {:print "$track_local(22,13,1):", $t1} $t1 == $t1;

    // $t2 := get_field<coin::Coin<#0>>.value($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:17+10
    assume {:print "$at(79,13287,13297)"} true;
    $t2 := $value#$1_coin_Coin'#0'($Dereference($t0));

    // $t3 := >=($t2, $t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:28+2
    call $t3 := $Ge($t2, $t1);

    // if ($t3) goto L1 else goto L0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    if ($t3) { goto L1; } else { goto L0; }

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
L1:

    // goto L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    assume {:print "$at(79,13279,13356)"} true;
    goto L2;

    // label L0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
L0:

    // destroy($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    assume {:print "$at(79,13279,13356)"} true;

    // $t4 := 6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:63+21
    $t4 := 6;
    assume $IsValid'u64'($t4);

    // $t5 := error::invalid_argument($t4) on_abort goto L4 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:39+46
    call $t5 := $1_error_invalid_argument($t4);
    if ($abort_flag) {
        assume {:print "$at(79,13309,13355)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(22,13):", $t6} $t6 == $t6;
        goto L4;
    }

    // trace_abort($t5) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    assume {:print "$at(79,13279,13356)"} true;
    assume {:print "$track_abort(22,13):", $t5} $t5 == $t5;

    // $t6 := move($t5) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    $t6 := $t5;

    // goto L4 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:344:9+77
    goto L4;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:22+4
    assume {:print "$at(79,13379,13383)"} true;
L2:

    // $t7 := get_field<coin::Coin<#0>>.value($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:22+10
    assume {:print "$at(79,13379,13389)"} true;
    $t7 := $value#$1_coin_Coin'#0'($Dereference($t0));

    // $t8 := -($t7, $t1) on_abort goto L4 with $t6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:33+1
    call $t8 := $Sub($t7, $t1);
    if ($abort_flag) {
        assume {:print "$at(79,13390,13391)"} true;
        $t6 := $abort_code;
        assume {:print "$track_abort(22,13):", $t6} $t6 == $t6;
        goto L4;
    }

    // $t9 := borrow_field<coin::Coin<#0>>.value($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:9+10
    $t9 := $ChildMutation($t0, 0, $value#$1_coin_Coin'#0'($Dereference($t0)));

    // write_ref($t9, $t8) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:9+32
    $t9 := $UpdateMutation($t9, $t8);

    // write_back[Reference($t0).value (u64)]($t9) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:9+32
    $t0 := $UpdateMutation($t0, $Update'$1_coin_Coin'#0''_value($Dereference($t0), $Dereference($t9)));

    // trace_local[coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:345:9+32
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,13,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // $t10 := pack coin::Coin<#0>($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:346:9+22
    assume {:print "$at(79,13408,13430)"} true;
    $t10 := $1_coin_Coin'#0'($t1);

    // trace_return[0]($t10) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:346:9+22
    assume {:print "$track_return(22,13,0):", $t10} $t10 == $t10;

    // trace_local[coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:346:9+22
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,13,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // label L3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:347:5+1
    assume {:print "$at(79,13435,13436)"} true;
L3:

    // return $t10 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:347:5+1
    assume {:print "$at(79,13435,13436)"} true;
    $ret0 := $t10;
    $ret1 := $t0;
    return;

    // label L4 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:347:5+1
L4:

    // abort($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:347:5+1
    assume {:print "$at(79,13435,13436)"} true;
    $abort_code := $t6;
    $abort_flag := true;
    return;

}

// fun coin::is_account_registered<#0> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:242:5+129
procedure {:inline 1} $1_coin_is_account_registered'#0'(_$t0: int) returns ($ret0: bool)
{
    // declare local variables
    var $t1: bool;
    var $t0: int;
    var $temp_0'address': int;
    var $temp_0'bool': bool;
    $t0 := _$t0;

    // bytecode translation starts here
    // trace_local[account_addr]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:242:5+1
    assume {:print "$at(79,8900,8901)"} true;
    assume {:print "$track_local(22,21,0):", $t0} $t0 == $t0;

    // $t1 := exists<coin::CoinStore<#0>>($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:243:9+6
    assume {:print "$at(79,8982,8988)"} true;
    $t1 := $ResourceExists($1_coin_CoinStore'#0'_$memory, $t0);

    // trace_return[0]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:243:9+41
    assume {:print "$track_return(22,21,0):", $t1} $t1 == $t1;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:244:5+1
    assume {:print "$at(79,9028,9029)"} true;
L1:

    // return $t1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:244:5+1
    assume {:print "$at(79,9028,9029)"} true;
    $ret0 := $t1;
    return;

}

// fun coin::merge<#0> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:465:5+292
procedure {:inline 1} $1_coin_merge'#0'(_$t0: $Mutation ($1_coin_Coin'#0'), _$t1: $1_coin_Coin'#0') returns ($ret0: $Mutation ($1_coin_Coin'#0'))
{
    // declare local variables
    var $t2: int;
    var $t3: int;
    var $t4: int;
    var $t5: int;
    var $t6: $Mutation (int);
    var $t7: int;
    var $t0: $Mutation ($1_coin_Coin'#0');
    var $t1: $1_coin_Coin'#0';
    var $temp_0'$1_coin_Coin'#0'': $1_coin_Coin'#0';
    $t0 := _$t0;
    $t1 := _$t1;

    // bytecode translation starts here
    // trace_local[dst_coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:465:5+1
    assume {:print "$at(79,18205,18206)"} true;
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,24,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // trace_local[source_coin]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:465:5+1
    assume {:print "$track_local(22,24,1):", $t1} $t1 == $t1;

    // assume Le(Add(select coin::Coin.value($t0), select coin::Coin.value($t1)), 18446744073709551615) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:467:13+53
    assume {:print "$at(79,18321,18374)"} true;
    assume (($value#$1_coin_Coin'#0'($Dereference($t0)) + $value#$1_coin_Coin'#0'($t1)) <= 18446744073709551615);

    // $t2 := get_field<coin::Coin<#0>>.value($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:26+14
    assume {:print "$at(79,18411,18425)"} true;
    $t2 := $value#$1_coin_Coin'#0'($Dereference($t0));

    // $t3 := get_field<coin::Coin<#0>>.value($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:43+17
    $t3 := $value#$1_coin_Coin'#0'($t1);

    // $t4 := +($t2, $t3) on_abort goto L2 with $t5 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:41+1
    call $t4 := $AddU64($t2, $t3);
    if ($abort_flag) {
        assume {:print "$at(79,18426,18427)"} true;
        $t5 := $abort_code;
        assume {:print "$track_abort(22,24):", $t5} $t5 == $t5;
        goto L2;
    }

    // $t6 := borrow_field<coin::Coin<#0>>.value($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:9+14
    $t6 := $ChildMutation($t0, 0, $value#$1_coin_Coin'#0'($Dereference($t0)));

    // write_ref($t6, $t4) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:9+51
    $t6 := $UpdateMutation($t6, $t4);

    // write_back[Reference($t0).value (u64)]($t6) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:9+51
    $t0 := $UpdateMutation($t0, $Update'$1_coin_Coin'#0''_value($Dereference($t0), $Dereference($t6)));

    // trace_local[dst_coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:469:9+51
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,24,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // $t7 := unpack coin::Coin<#0>($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:470:13+17
    assume {:print "$at(79,18459,18476)"} true;
    $t7 := $value#$1_coin_Coin'#0'($t1);

    // destroy($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:470:27+1

    // trace_local[dst_coin]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:470:44+1
    $temp_0'$1_coin_Coin'#0'' := $Dereference($t0);
    assume {:print "$track_local(22,24,0):", $temp_0'$1_coin_Coin'#0''} $temp_0'$1_coin_Coin'#0'' == $temp_0'$1_coin_Coin'#0'';

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:471:5+1
    assume {:print "$at(79,18496,18497)"} true;
L1:

    // return () at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:471:5+1
    assume {:print "$at(79,18496,18497)"} true;
    $ret0 := $t0;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:471:5+1
L2:

    // abort($t5) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:471:5+1
    assume {:print "$at(79,18496,18497)"} true;
    $abort_code := $t5;
    $abort_flag := true;
    return;

}

// fun coin::withdraw<#0> [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:526:5+697
procedure {:inline 1} $1_coin_withdraw'#0'(_$t0: $signer, _$t1: int) returns ($ret0: $1_coin_Coin'#0')
{
    // declare local variables
    var $t2: int;
    var $t3: $Mutation ($1_coin_CoinStore'#0');
    var $t4: int;
    var $t5: $1_coin_CoinStore'#0';
    var $t6: int;
    var $t7: int;
    var $t8: int;
    var $t9: bool;
    var $t10: int;
    var $t11: int;
    var $t12: $Mutation ($1_coin_CoinStore'#0');
    var $t13: bool;
    var $t14: bool;
    var $t15: int;
    var $t16: int;
    var $t17: $Mutation ($1_event_EventHandle'$1_coin_WithdrawEvent');
    var $t18: $1_coin_WithdrawEvent;
    var $t19: $Mutation ($1_coin_Coin'#0');
    var $t20: $1_coin_Coin'#0';
    var $t0: $signer;
    var $t1: int;
    var $1_coin_CoinStore'#0'_$modifies: [int]bool;
    var $temp_0'$1_coin_Coin'#0'': $1_coin_Coin'#0';
    var $temp_0'$1_coin_CoinStore'#0'': $1_coin_CoinStore'#0';
    var $temp_0'address': int;
    var $temp_0'signer': $signer;
    var $temp_0'u64': int;
    $t0 := _$t0;
    $t1 := _$t1;

    // bytecode translation starts here
    // assume Identical($t4, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:260:9+47
    assume {:print "$at(80,9803,9850)"} true;
    assume ($t4 == $1_signer_$address_of($t0));

    // assume Identical($t5, global<coin::CoinStore<#0>>($t4)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:261:9+59
    assume {:print "$at(80,9859,9918)"} true;
    assume ($t5 == $ResourceValue($1_coin_CoinStore'#0'_$memory, $t4));

    // assume Identical($t6, select coin::Coin.value(select coin::CoinStore.coin($t5))) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:262:9+36
    assume {:print "$at(80,9927,9963)"} true;
    assume ($t6 == $value#$1_coin_Coin'#0'($coin#$1_coin_CoinStore'#0'($t5)));

    // trace_local[account]($t0) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:526:5+1
    assume {:print "$at(79,20379,20380)"} true;
    assume {:print "$track_local(22,35,0):", $t0} $t0 == $t0;

    // trace_local[amount]($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:526:5+1
    assume {:print "$track_local(22,35,1):", $t1} $t1 == $t1;

    // $t7 := signer::address_of($t0) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:530:28+27
    assume {:print "$at(79,20527,20554)"} true;
    call $t7 := $1_signer_address_of($t0);
    if ($abort_flag) {
        assume {:print "$at(79,20527,20554)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // trace_local[account_addr]($t7) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:530:13+12
    assume {:print "$track_local(22,35,2):", $t7} $t7 == $t7;

    // $t9 := coin::is_account_registered<#0>($t7) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:532:13+45
    assume {:print "$at(79,20585,20630)"} true;
    call $t9 := $1_coin_is_account_registered'#0'($t7);
    if ($abort_flag) {
        assume {:print "$at(79,20585,20630)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // if ($t9) goto L1 else goto L0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
    assume {:print "$at(79,20564,20698)"} true;
    if ($t9) { goto L1; } else { goto L0; }

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
L1:

    // goto L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
    assume {:print "$at(79,20564,20698)"} true;
    goto L2;

    // label L0 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:533:30+25
    assume {:print "$at(79,20661,20686)"} true;
L0:

    // $t10 := 5 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:533:30+25
    assume {:print "$at(79,20661,20686)"} true;
    $t10 := 5;
    assume $IsValid'u64'($t10);

    // $t11 := error::not_found($t10) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:533:13+43
    call $t11 := $1_error_not_found($t10);
    if ($abort_flag) {
        assume {:print "$at(79,20644,20687)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // trace_abort($t11) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
    assume {:print "$at(79,20564,20698)"} true;
    assume {:print "$track_abort(22,35):", $t11} $t11 == $t11;

    // $t8 := move($t11) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
    $t8 := $t11;

    // goto L7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:531:9+134
    goto L7;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:536:65+12
    assume {:print "$at(79,20765,20777)"} true;
L2:

    // $t12 := borrow_global<coin::CoinStore<#0>>($t7) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:536:26+17
    assume {:print "$at(79,20726,20743)"} true;
    if (!$ResourceExists($1_coin_CoinStore'#0'_$memory, $t7)) {
        call $ExecFailureAbort();
    } else {
        $t12 := $Mutation($Global($t7), EmptyVec(), $ResourceValue($1_coin_CoinStore'#0'_$memory, $t7));
    }
    if ($abort_flag) {
        assume {:print "$at(79,20726,20743)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // trace_local[coin_store]($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:536:13+10
    $temp_0'$1_coin_CoinStore'#0'' := $Dereference($t12);
    assume {:print "$track_local(22,35,3):", $temp_0'$1_coin_CoinStore'#0''} $temp_0'$1_coin_CoinStore'#0'' == $temp_0'$1_coin_CoinStore'#0'';

    // $t13 := get_field<coin::CoinStore<#0>>.frozen($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:538:14+17
    assume {:print "$at(79,20810,20827)"} true;
    $t13 := $frozen#$1_coin_CoinStore'#0'($Dereference($t12));

    // $t14 := !($t13) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:538:13+1
    call $t14 := $Not($t13);

    // if ($t14) goto L4 else goto L3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    assume {:print "$at(79,20788,20885)"} true;
    if ($t14) { goto L4; } else { goto L3; }

    // label L4 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
L4:

    // goto L5 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    assume {:print "$at(79,20788,20885)"} true;
    goto L5;

    // label L3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
L3:

    // destroy($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    assume {:print "$at(79,20788,20885)"} true;

    // $t15 := 10 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:539:38+7
    assume {:print "$at(79,20866,20873)"} true;
    $t15 := 10;
    assume $IsValid'u64'($t15);

    // $t16 := error::permission_denied($t15) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:539:13+33
    call $t16 := $1_error_permission_denied($t15);
    if ($abort_flag) {
        assume {:print "$at(79,20841,20874)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // trace_abort($t16) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    assume {:print "$at(79,20788,20885)"} true;
    assume {:print "$track_abort(22,35):", $t16} $t16 == $t16;

    // $t8 := move($t16) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    $t8 := $t16;

    // goto L7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:537:9+97
    goto L7;

    // label L5 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:543:18+10
    assume {:print "$at(79,20947,20957)"} true;
L5:

    // $t17 := borrow_field<coin::CoinStore<#0>>.withdraw_events($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:543:13+31
    assume {:print "$at(79,20942,20973)"} true;
    $t17 := $ChildMutation($t12, 3, $withdraw_events#$1_coin_CoinStore'#0'($Dereference($t12)));

    // $t18 := pack coin::WithdrawEvent($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:544:13+24
    assume {:print "$at(79,20987,21011)"} true;
    $t18 := $1_coin_WithdrawEvent($t1);

    // opaque begin: event::emit_event<coin::WithdrawEvent>($t17, $t18) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:542:9+126
    assume {:print "$at(79,20896,21022)"} true;

    // opaque end: event::emit_event<coin::WithdrawEvent>($t17, $t18) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:542:9+126

    // write_back[Reference($t12).withdraw_events (event::EventHandle<coin::WithdrawEvent>)]($t17) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:542:9+126
    $t12 := $UpdateMutation($t12, $Update'$1_coin_CoinStore'#0''_withdraw_events($Dereference($t12), $Dereference($t17)));

    // $t19 := borrow_field<coin::CoinStore<#0>>.coin($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:547:17+20
    assume {:print "$at(79,21041,21061)"} true;
    $t19 := $ChildMutation($t12, 0, $coin#$1_coin_CoinStore'#0'($Dereference($t12)));

    // $t20 := coin::extract<#0>($t19, $t1) on_abort goto L7 with $t8 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:547:9+37
    call $t20,$t19 := $1_coin_extract'#0'($t19, $t1);
    if ($abort_flag) {
        assume {:print "$at(79,21033,21070)"} true;
        $t8 := $abort_code;
        assume {:print "$track_abort(22,35):", $t8} $t8 == $t8;
        goto L7;
    }

    // write_back[Reference($t12).coin (coin::Coin<#0>)]($t19) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:547:9+37
    $t12 := $UpdateMutation($t12, $Update'$1_coin_CoinStore'#0''_coin($Dereference($t12), $Dereference($t19)));

    // write_back[coin::CoinStore<#0>@]($t12) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:547:9+37
    $1_coin_CoinStore'#0'_$memory := $ResourceUpdate($1_coin_CoinStore'#0'_$memory, $GlobalLocationAddress($t12),
        $Dereference($t12));

    // trace_return[0]($t20) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:547:9+37
    assume {:print "$track_return(22,35,0):", $t20} $t20 == $t20;

    // label L6 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:548:5+1
    assume {:print "$at(79,21075,21076)"} true;
L6:

    // return $t20 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:548:5+1
    assume {:print "$at(79,21075,21076)"} true;
    $ret0 := $t20;
    return;

    // label L7 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:548:5+1
L7:

    // abort($t8) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.move:548:5+1
    assume {:print "$at(79,21075,21076)"} true;
    $abort_code := $t8;
    $abort_flag := true;
    return;

}

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/chain_status.move:33:5+90
function {:inline} $1_chain_status_$is_operating($1_chain_status_GenesisEndMarker_$memory: $Memory $1_chain_status_GenesisEndMarker): bool {
    $ResourceExists($1_chain_status_GenesisEndMarker_$memory, 1)
}

// struct chain_status::GenesisEndMarker at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/chain_status.move:12:5+34
type {:datatype} $1_chain_status_GenesisEndMarker;
function {:constructor} $1_chain_status_GenesisEndMarker($dummy_field: bool): $1_chain_status_GenesisEndMarker;
function {:inline} $Update'$1_chain_status_GenesisEndMarker'_dummy_field(s: $1_chain_status_GenesisEndMarker, x: bool): $1_chain_status_GenesisEndMarker {
    $1_chain_status_GenesisEndMarker(x)
}
function $IsValid'$1_chain_status_GenesisEndMarker'(s: $1_chain_status_GenesisEndMarker): bool {
    $IsValid'bool'($dummy_field#$1_chain_status_GenesisEndMarker(s))
}
function {:inline} $IsEqual'$1_chain_status_GenesisEndMarker'(s1: $1_chain_status_GenesisEndMarker, s2: $1_chain_status_GenesisEndMarker): bool {
    s1 == s2
}
var $1_chain_status_GenesisEndMarker_$memory: $Memory $1_chain_status_GenesisEndMarker;

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.spec.move:22:10+111
function {:inline} $1_timestamp_spec_now_microseconds($1_timestamp_CurrentTimeMicroseconds_$memory: $Memory $1_timestamp_CurrentTimeMicroseconds): int {
    $microseconds#$1_timestamp_CurrentTimeMicroseconds($ResourceValue($1_timestamp_CurrentTimeMicroseconds_$memory, 1))
}

// struct timestamp::CurrentTimeMicroseconds at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:12:5+73
type {:datatype} $1_timestamp_CurrentTimeMicroseconds;
function {:constructor} $1_timestamp_CurrentTimeMicroseconds($microseconds: int): $1_timestamp_CurrentTimeMicroseconds;
function {:inline} $Update'$1_timestamp_CurrentTimeMicroseconds'_microseconds(s: $1_timestamp_CurrentTimeMicroseconds, x: int): $1_timestamp_CurrentTimeMicroseconds {
    $1_timestamp_CurrentTimeMicroseconds(x)
}
function $IsValid'$1_timestamp_CurrentTimeMicroseconds'(s: $1_timestamp_CurrentTimeMicroseconds): bool {
    $IsValid'u64'($microseconds#$1_timestamp_CurrentTimeMicroseconds(s))
}
function {:inline} $IsEqual'$1_timestamp_CurrentTimeMicroseconds'(s1: $1_timestamp_CurrentTimeMicroseconds, s2: $1_timestamp_CurrentTimeMicroseconds): bool {
    s1 == s2
}
var $1_timestamp_CurrentTimeMicroseconds_$memory: $Memory $1_timestamp_CurrentTimeMicroseconds;

// fun timestamp::now_microseconds [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:60:5+153
procedure {:inline 1} $1_timestamp_now_microseconds() returns ($ret0: int)
{
    // declare local variables
    var $t0: int;
    var $t1: $1_timestamp_CurrentTimeMicroseconds;
    var $t2: int;
    var $t3: int;
    var $temp_0'u64': int;

    // bytecode translation starts here
    // $t0 := 0x1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:61:48+16
    assume {:print "$at(112,2499,2515)"} true;
    $t0 := 1;
    assume $IsValid'address'($t0);

    // $t1 := get_global<timestamp::CurrentTimeMicroseconds>($t0) on_abort goto L2 with $t2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:61:9+13
    if (!$ResourceExists($1_timestamp_CurrentTimeMicroseconds_$memory, $t0)) {
        call $ExecFailureAbort();
    } else {
        $t1 := $ResourceValue($1_timestamp_CurrentTimeMicroseconds_$memory, $t0);
    }
    if ($abort_flag) {
        assume {:print "$at(112,2460,2473)"} true;
        $t2 := $abort_code;
        assume {:print "$track_abort(27,0):", $t2} $t2 == $t2;
        goto L2;
    }

    // $t3 := get_field<timestamp::CurrentTimeMicroseconds>.microseconds($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:61:9+69
    $t3 := $microseconds#$1_timestamp_CurrentTimeMicroseconds($t1);

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:61:9+69
    assume {:print "$track_return(27,0,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:62:5+1
    assume {:print "$at(112,2534,2535)"} true;
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:62:5+1
    assume {:print "$at(112,2534,2535)"} true;
    $ret0 := $t3;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:62:5+1
L2:

    // abort($t2) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:62:5+1
    assume {:print "$at(112,2534,2535)"} true;
    $abort_code := $t2;
    $abort_flag := true;
    return;

}

// fun timestamp::now_seconds [baseline] at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:65:5+123
procedure {:inline 1} $1_timestamp_now_seconds() returns ($ret0: int)
{
    // declare local variables
    var $t0: int;
    var $t1: int;
    var $t2: int;
    var $t3: int;
    var $temp_0'u64': int;

    // bytecode translation starts here
    // $t0 := timestamp::now_microseconds() on_abort goto L2 with $t1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:66:9+18
    assume {:print "$at(112,2656,2674)"} true;
    call $t0 := $1_timestamp_now_microseconds();
    if ($abort_flag) {
        assume {:print "$at(112,2656,2674)"} true;
        $t1 := $abort_code;
        assume {:print "$track_abort(27,1):", $t1} $t1 == $t1;
        goto L2;
    }

    // $t2 := 1000000 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:66:30+23
    $t2 := 1000000;
    assume $IsValid'u64'($t2);

    // $t3 := /($t0, $t2) on_abort goto L2 with $t1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:66:28+1
    call $t3 := $Div($t0, $t2);
    if ($abort_flag) {
        assume {:print "$at(112,2675,2676)"} true;
        $t1 := $abort_code;
        assume {:print "$track_abort(27,1):", $t1} $t1 == $t1;
        goto L2;
    }

    // trace_return[0]($t3) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:66:9+44
    assume {:print "$track_return(27,1,0):", $t3} $t3 == $t3;

    // label L1 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:67:5+1
    assume {:print "$at(112,2705,2706)"} true;
L1:

    // return $t3 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:67:5+1
    assume {:print "$at(112,2705,2706)"} true;
    $ret0 := $t3;
    return;

    // label L2 at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:67:5+1
L2:

    // abort($t1) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.move:67:5+1
    assume {:print "$at(112,2705,2706)"} true;
    $abort_code := $t1;
    $abort_flag := true;
    return;

}

// spec fun at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/reconfiguration.move:153:5+155
function {:inline} $1_reconfiguration_$last_reconfiguration_time($1_reconfiguration_Configuration_$memory: $Memory $1_reconfiguration_Configuration): int {
    $last_reconfiguration_time#$1_reconfiguration_Configuration($ResourceValue($1_reconfiguration_Configuration_$memory, 1))
}

// struct reconfiguration::Configuration at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/reconfiguration.move:32:5+306
type {:datatype} $1_reconfiguration_Configuration;
function {:constructor} $1_reconfiguration_Configuration($epoch: int, $last_reconfiguration_time: int, $events: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'): $1_reconfiguration_Configuration;
function {:inline} $Update'$1_reconfiguration_Configuration'_epoch(s: $1_reconfiguration_Configuration, x: int): $1_reconfiguration_Configuration {
    $1_reconfiguration_Configuration(x, $last_reconfiguration_time#$1_reconfiguration_Configuration(s), $events#$1_reconfiguration_Configuration(s))
}
function {:inline} $Update'$1_reconfiguration_Configuration'_last_reconfiguration_time(s: $1_reconfiguration_Configuration, x: int): $1_reconfiguration_Configuration {
    $1_reconfiguration_Configuration($epoch#$1_reconfiguration_Configuration(s), x, $events#$1_reconfiguration_Configuration(s))
}
function {:inline} $Update'$1_reconfiguration_Configuration'_events(s: $1_reconfiguration_Configuration, x: $1_event_EventHandle'$1_reconfiguration_NewEpochEvent'): $1_reconfiguration_Configuration {
    $1_reconfiguration_Configuration($epoch#$1_reconfiguration_Configuration(s), $last_reconfiguration_time#$1_reconfiguration_Configuration(s), x)
}
function $IsValid'$1_reconfiguration_Configuration'(s: $1_reconfiguration_Configuration): bool {
    $IsValid'u64'($epoch#$1_reconfiguration_Configuration(s))
      && $IsValid'u64'($last_reconfiguration_time#$1_reconfiguration_Configuration(s))
      && $IsValid'$1_event_EventHandle'$1_reconfiguration_NewEpochEvent''($events#$1_reconfiguration_Configuration(s))
}
function {:inline} $IsEqual'$1_reconfiguration_Configuration'(s1: $1_reconfiguration_Configuration, s2: $1_reconfiguration_Configuration): bool {
    s1 == s2
}
var $1_reconfiguration_Configuration_$memory: $Memory $1_reconfiguration_Configuration;

// struct reconfiguration::NewEpochEvent at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/reconfiguration.move:27:5+64
type {:datatype} $1_reconfiguration_NewEpochEvent;
function {:constructor} $1_reconfiguration_NewEpochEvent($epoch: int): $1_reconfiguration_NewEpochEvent;
function {:inline} $Update'$1_reconfiguration_NewEpochEvent'_epoch(s: $1_reconfiguration_NewEpochEvent, x: int): $1_reconfiguration_NewEpochEvent {
    $1_reconfiguration_NewEpochEvent(x)
}
function $IsValid'$1_reconfiguration_NewEpochEvent'(s: $1_reconfiguration_NewEpochEvent): bool {
    $IsValid'u64'($epoch#$1_reconfiguration_NewEpochEvent(s))
}
function {:inline} $IsEqual'$1_reconfiguration_NewEpochEvent'(s1: $1_reconfiguration_NewEpochEvent, s2: $1_reconfiguration_NewEpochEvent): bool {
    s1 == s2
}

// struct per_second_v8::CloseSessionEvent at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:60:5+236
type {:datatype} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent;
function {:constructor} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester: int, $receiver: int, $started_at: int, $finished_at: int, $second_rate: int, $paid_amount: int, $refunded_amount: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent;
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_requester(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(x, $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_receiver(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x, $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_started_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x, $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_finished_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x, $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_second_rate(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x, $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_paid_amount(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x, $refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'_refunded_amount(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), $paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s), x)
}
function $IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent): bool {
    $IsValid'address'($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'address'($receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'u64'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'u64'($finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'u64'($second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'u64'($paid_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
      && $IsValid'u64'($refunded_amount#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent(s))
}
function {:inline} $IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'(s1: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent, s2: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent): bool {
    s1 == s2
}

// struct per_second_v8::CreateSessionEvent at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:40:5+188
type {:datatype} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent;
function {:constructor} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($requester: int, $max_duration: int, $second_rate: int, $room_id: $1_string_String, $created_at: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent;
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'_requester(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(x, $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'_max_duration(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), x, $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'_second_rate(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), x, $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'_room_id(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, x: $1_string_String): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), x, $created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'_created_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s), x)
}
function $IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent): bool {
    $IsValid'address'($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
      && $IsValid'u64'($max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
      && $IsValid'u64'($second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
      && $IsValid'$1_string_String'($room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
      && $IsValid'u64'($created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s))
}
function {:inline} $IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'(s1: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent, s2: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent): bool {
    $IsEqual'address'($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s1), $requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s2))
    && $IsEqual'u64'($max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s1), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s2))
    && $IsEqual'u64'($second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s1), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s2))
    && $IsEqual'$1_string_String'($room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s1), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s2))
    && $IsEqual'u64'($created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s1), $created_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent(s2))}

// struct per_second_v8::JoinSessionEvent at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:48:5+126
type {:datatype} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent;
function {:constructor} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent($requester: int, $receiver: int, $joined_at: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent;
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'_requester(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(x, $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s), $joined_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'_receiver(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s), x, $joined_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'_joined_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s), x)
}
function $IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent): bool {
    $IsValid'address'($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s))
      && $IsValid'address'($receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s))
      && $IsValid'u64'($joined_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent(s))
}
function {:inline} $IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'(s1: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent, s2: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent): bool {
    s1 == s2
}

// struct per_second_v8::Session<#0> at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:25:5+521
type {:datatype} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';
function {:constructor} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at: int, $finished_at: int, $max_duration: int, $second_rate: int, $room_id: $1_string_String, $receiver: int, $deposit: $1_coin_Coin'#0', $create_session_events: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent', $join_session_events: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent', $start_session_events: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent', $close_session_events: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_started_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(x, $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_finished_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_max_duration(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_second_rate(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_room_id(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_string_String): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_receiver(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_deposit(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_coin_Coin'#0'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_create_session_events(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_join_session_events(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_start_session_events(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x, $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_close_session_events(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', x: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0' {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s), x)
}
function $IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'): bool {
    $IsValid'u64'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'u64'($finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'u64'($max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'u64'($second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_string_String'($room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'address'($receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_coin_Coin'#0''($deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''($create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''($join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''($start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
      && $IsValid'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''($close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s))
}
function {:inline} $IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''(s1: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0', s2: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'): bool {
    $IsEqual'u64'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'u64'($finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'u64'($max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'u64'($second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_string_String'($room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'address'($receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_coin_Coin'#0''($deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent''($create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent''($join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $join_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent''($start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $start_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))
    && $IsEqual'$1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent''($close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s1), $close_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'(s2))}
var $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory: $Memory $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';

// struct per_second_v8::StartSessionEvent at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:54:5+128
type {:datatype} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent;
function {:constructor} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent($requester: int, $receiver: int, $started_at: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent;
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'_requester(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(x, $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s), $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'_receiver(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s), x, $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s))
}
function {:inline} $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'_started_at(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent, x: int): $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent {
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s), $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s), x)
}
function $IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent): bool {
    $IsValid'address'($requester#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s))
      && $IsValid'address'($receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s))
      && $IsValid'u64'($started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent(s))
}
function {:inline} $IsEqual'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'(s1: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent, s2: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent): bool {
    s1 == s2
}

// fun per_second_v8::create_session [verification] at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1992
procedure {:timeLimit 40} $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_create_session$verify(_$t0: $signer, _$t1: int, _$t2: int, _$t3: $1_string_String) returns ()
{
    // declare local variables
    var $t4: int;
    var $t5: int;
    var $t6: $Mutation ($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0');
    var $t7: int;
    var $t8: int;
    var $t9: int;
    var $t10: int;
    var $t11: bool;
    var $t12: $Mutation ($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0');
    var $t13: int;
    var $t14: int;
    var $t15: bool;
    var $t16: int;
    var $t17: int;
    var $t18: int;
    var $t19: $Mutation (int);
    var $t20: int;
    var $t21: $Mutation (int);
    var $t22: $Mutation (int);
    var $t23: $Mutation (int);
    var $t24: $Mutation ($1_string_String);
    var $t25: int;
    var $t26: $Mutation (int);
    var $t27: $Mutation ($1_coin_Coin'#0');
    var $t28: int;
    var $t29: $1_coin_CoinStore'#0';
    var $t30: int;
    var $t31: $1_coin_Coin'#0';
    var $t32: int;
    var $t33: int;
    var $t34: int;
    var $t35: int;
    var $t36: $1_coin_CoinStore'#0';
    var $t37: int;
    var $t38: $1_coin_Coin'#0';
    var $t39: int;
    var $t40: $1_account_Account;
    var $t41: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent';
    var $t42: int;
    var $t43: $1_account_Account;
    var $t44: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent';
    var $t45: int;
    var $t46: $1_account_Account;
    var $t47: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent';
    var $t48: int;
    var $t49: $1_account_Account;
    var $t50: $1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent';
    var $t51: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';
    var $t52: $Mutation ($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0');
    var $t53: $Mutation ($1_event_EventHandle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent');
    var $t54: int;
    var $t55: $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent;
    var $t0: $signer;
    var $t1: int;
    var $t2: int;
    var $t3: $1_string_String;
    var $temp_0'$1_string_String': $1_string_String;
    var $temp_0'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'': $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0';
    var $temp_0'address': int;
    var $temp_0'signer': $signer;
    var $temp_0'u64': int;
    $t0 := _$t0;
    $t1 := _$t1;
    $t2 := _$t2;
    $t3 := _$t3;

    // verification entrypoint assumptions
    call $InitVerification();

    // bytecode translation starts here
    // assume WellFormed($t0) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume {:print "$at(2,2277,2278)"} true;
    assume $IsValid'signer'($t0) && $1_signer_is_txn_signer($t0) && $1_signer_is_txn_signer_addr($addr#$signer($t0));

    // assume WellFormed($t1) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume $IsValid'u64'($t1);

    // assume WellFormed($t2) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume $IsValid'u64'($t2);

    // assume WellFormed($t3) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume $IsValid'$1_string_String'($t3);

    // assume forall $rsc: ResourceDomain<account::Account>(): And(WellFormed($rsc), And(Le(Len<address>(select option::Option.vec(select account::CapabilityOffer.for(select account::Account.rotation_capability_offer($rsc)))), 1), Le(Len<address>(select option::Option.vec(select account::CapabilityOffer.for(select account::Account.signer_capability_offer($rsc)))), 1))) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($1_account_Account_$memory, $a_0)}(var $rsc := $ResourceValue($1_account_Account_$memory, $a_0);
    (($IsValid'$1_account_Account'($rsc) && ((LenVec($vec#$1_option_Option'address'($for#$1_account_CapabilityOffer'$1_account_RotationCapability'($rotation_capability_offer#$1_account_Account($rsc)))) <= 1) && (LenVec($vec#$1_option_Option'address'($for#$1_account_CapabilityOffer'$1_account_SignerCapability'($signer_capability_offer#$1_account_Account($rsc)))) <= 1))))));

    // assume forall $rsc: ResourceDomain<coin::CoinStore<#0>>(): WellFormed($rsc) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($1_coin_CoinStore'#0'_$memory, $a_0)}(var $rsc := $ResourceValue($1_coin_CoinStore'#0'_$memory, $a_0);
    ($IsValid'$1_coin_CoinStore'#0''($rsc))));

    // assume forall $rsc: ResourceDomain<chain_status::GenesisEndMarker>(): WellFormed($rsc) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($1_chain_status_GenesisEndMarker_$memory, $a_0)}(var $rsc := $ResourceValue($1_chain_status_GenesisEndMarker_$memory, $a_0);
    ($IsValid'$1_chain_status_GenesisEndMarker'($rsc))));

    // assume forall $rsc: ResourceDomain<timestamp::CurrentTimeMicroseconds>(): WellFormed($rsc) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($1_timestamp_CurrentTimeMicroseconds_$memory, $a_0)}(var $rsc := $ResourceValue($1_timestamp_CurrentTimeMicroseconds_$memory, $a_0);
    ($IsValid'$1_timestamp_CurrentTimeMicroseconds'($rsc))));

    // assume forall $rsc: ResourceDomain<reconfiguration::Configuration>(): WellFormed($rsc) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($1_reconfiguration_Configuration_$memory, $a_0)}(var $rsc := $ResourceValue($1_reconfiguration_Configuration_$memory, $a_0);
    ($IsValid'$1_reconfiguration_Configuration'($rsc))));

    // assume forall $rsc: ResourceDomain<per_second_v8::Session<#0>>(): WellFormed($rsc) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume (forall $a_0: int :: {$ResourceValue($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $a_0)}(var $rsc := $ResourceValue($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $a_0);
    ($IsValid'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''($rsc))));

    // assume Implies(chain_status::$is_operating(), exists<timestamp::CurrentTimeMicroseconds>(1)) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1992
    // global invariant at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/timestamp.spec.move:4:9+93
    assume ($1_chain_status_$is_operating($1_chain_status_GenesisEndMarker_$memory) ==> $ResourceExists($1_timestamp_CurrentTimeMicroseconds_$memory, 1));

    // assume Implies(chain_status::$is_operating(), Ge(timestamp::spec_now_microseconds(), reconfiguration::$last_reconfiguration_time())) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1992
    // global invariant at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/reconfiguration.spec.move:8:9+137
    assume ($1_chain_status_$is_operating($1_chain_status_GenesisEndMarker_$memory) ==> ($1_timestamp_spec_now_microseconds($1_timestamp_CurrentTimeMicroseconds_$memory) >= $1_reconfiguration_$last_reconfiguration_time($1_reconfiguration_Configuration_$memory)));

    // assume Identical($t7, signer::$address_of($t0)) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.spec.move:10:9+51
    assume {:print "$at(3,292,343)"} true;
    assume ($t7 == $1_signer_$address_of($t0));

    // trace_local[requester]($t0) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume {:print "$at(2,2277,2278)"} true;
    assume {:print "$track_local(55,1,0):", $t0} $t0 == $t0;

    // trace_local[max_duration]($t1) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume {:print "$track_local(55,1,1):", $t1} $t1 == $t1;

    // trace_local[second_rate]($t2) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume {:print "$track_local(55,1,2):", $t2} $t2 == $t2;

    // trace_local[room_id]($t3) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:71:5+1
    assume {:print "$track_local(55,1,3):", $t3} $t3 == $t3;

    // $t8 := signer::address_of($t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:72:30+29
    assume {:print "$at(2,2449,2478)"} true;
    call $t8 := $1_signer_address_of($t0);
    if ($abort_flag) {
        assume {:print "$at(2,2449,2478)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // trace_local[requester_addr]($t8) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:72:13+14
    assume {:print "$track_local(55,1,5):", $t8} $t8 == $t8;

    // $t10 := *($t1, $t2) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:73:43+1
    assume {:print "$at(2,2522,2523)"} true;
    call $t10 := $MulU64($t1, $t2);
    if ($abort_flag) {
        assume {:print "$at(2,2522,2523)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // trace_local[deposit_amount]($t10) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:73:13+14
    assume {:print "$track_local(55,1,4):", $t10} $t10 == $t10;

    // $t11 := exists<per_second_v8::Session<#0>>($t8) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:75:13+6
    assume {:print "$at(2,2550,2556)"} true;
    $t11 := $ResourceExists($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t8);

    // if ($t11) goto L1 else goto L0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:75:9+1432
    if ($t11) { goto L1; } else { goto L0; }

    // label L1 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:76:64+14
    assume {:print "$at(2,2658,2672)"} true;
L1:

    // $t12 := borrow_global<per_second_v8::Session<#0>>($t8) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:76:27+17
    assume {:print "$at(2,2621,2638)"} true;
    if (!$ResourceExists($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t8)) {
        call $ExecFailureAbort();
    } else {
        $t12 := $Mutation($Global($t8), EmptyVec(), $ResourceValue($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t8));
    }
    if ($abort_flag) {
        assume {:print "$at(2,2621,2638)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // trace_local[session]($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:76:17+7
    $temp_0'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'' := $Dereference($t12);
    assume {:print "$track_local(55,1,6):", $temp_0'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''} $temp_0'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'' == $temp_0'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'';

    // $t13 := get_field<per_second_v8::Session<#0>>.finished_at($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:21+19
    assume {:print "$at(2,2695,2714)"} true;
    $t13 := $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12));

    // $t14 := 0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:43+1
    $t14 := 0;
    assume $IsValid'u64'($t14);

    // $t15 := >($t13, $t14) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:41+1
    call $t15 := $Gt($t13, $t14);

    // if ($t15) goto L3 else goto L2 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    if ($t15) { goto L3; } else { goto L2; }

    // label L3 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
L3:

    // goto L4 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    assume {:print "$at(2,2687,2768)"} true;
    goto L4;

    // label L2 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
L2:

    // destroy($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    assume {:print "$at(2,2687,2768)"} true;

    // $t16 := 1 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:67+25
    $t16 := 1;
    assume $IsValid'u64'($t16);

    // $t17 := error::invalid_state($t16) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:46+47
    call $t17 := $1_error_invalid_state($t16);
    if ($abort_flag) {
        assume {:print "$at(2,2720,2767)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // trace_abort($t17) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    assume {:print "$at(2,2687,2768)"} true;
    assume {:print "$track_abort(55,1):", $t17} $t17 == $t17;

    // $t9 := move($t17) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    $t9 := $t17;

    // goto L7 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:77:13+81
    goto L7;

    // label L4 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:80:34+1
    assume {:print "$at(2,2850,2851)"} true;
L4:

    // $t18 := 0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:80:34+1
    assume {:print "$at(2,2850,2851)"} true;
    $t18 := 0;
    assume $IsValid'u64'($t18);

    // $t19 := borrow_field<per_second_v8::Session<#0>>.started_at($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:80:13+18
    $t19 := $ChildMutation($t12, 0, $started_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t19, $t18) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:80:13+22
    $t19 := $UpdateMutation($t19, $t18);

    // write_back[Reference($t12).started_at (u64)]($t19) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:80:13+22
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_started_at($Dereference($t12), $Dereference($t19)));

    // $t20 := 0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:81:35+1
    assume {:print "$at(2,2887,2888)"} true;
    $t20 := 0;
    assume $IsValid'u64'($t20);

    // $t21 := borrow_field<per_second_v8::Session<#0>>.finished_at($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:81:13+19
    $t21 := $ChildMutation($t12, 1, $finished_at#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t21, $t20) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:81:13+23
    $t21 := $UpdateMutation($t21, $t20);

    // write_back[Reference($t12).finished_at (u64)]($t21) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:81:13+23
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_finished_at($Dereference($t12), $Dereference($t21)));

    // $t22 := borrow_field<per_second_v8::Session<#0>>.max_duration($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:82:13+20
    assume {:print "$at(2,2902,2922)"} true;
    $t22 := $ChildMutation($t12, 2, $max_duration#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t22, $t1) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:82:13+35
    $t22 := $UpdateMutation($t22, $t1);

    // write_back[Reference($t12).max_duration (u64)]($t22) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:82:13+35
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_max_duration($Dereference($t12), $Dereference($t22)));

    // $t23 := borrow_field<per_second_v8::Session<#0>>.second_rate($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:83:13+19
    assume {:print "$at(2,2951,2970)"} true;
    $t23 := $ChildMutation($t12, 3, $second_rate#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t23, $t2) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:83:13+33
    $t23 := $UpdateMutation($t23, $t2);

    // write_back[Reference($t12).second_rate (u64)]($t23) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:83:13+33
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_second_rate($Dereference($t12), $Dereference($t23)));

    // $t24 := borrow_field<per_second_v8::Session<#0>>.room_id($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:84:13+15
    assume {:print "$at(2,2998,3013)"} true;
    $t24 := $ChildMutation($t12, 4, $room_id#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t24, $t3) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:84:13+25
    $t24 := $UpdateMutation($t24, $t3);

    // write_back[Reference($t12).room_id (string::String)]($t24) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:84:13+25
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_room_id($Dereference($t12), $Dereference($t24)));

    // $t25 := 0x0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:85:32+4
    assume {:print "$at(2,3056,3060)"} true;
    $t25 := 0;
    assume $IsValid'address'($t25);

    // $t26 := borrow_field<per_second_v8::Session<#0>>.receiver($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:85:13+16
    $t26 := $ChildMutation($t12, 5, $receiver#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // write_ref($t26, $t25) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:85:13+23
    $t26 := $UpdateMutation($t26, $t25);

    // write_back[Reference($t12).receiver (address)]($t26) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:85:13+23
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_receiver($Dereference($t12), $Dereference($t26)));

    // $t27 := borrow_field<per_second_v8::Session<#0>>.deposit($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:25+20
    assume {:print "$at(2,3086,3106)"} true;
    $t27 := $ChildMutation($t12, 6, $deposit#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t12)));

    // assume Identical($t28, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:260:9+47
    assume {:print "$at(80,9803,9850)"} true;
    assume ($t28 == $1_signer_$address_of($t0));

    // assume Identical($t29, global<coin::CoinStore<#0>>($t28)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:261:9+59
    assume {:print "$at(80,9859,9918)"} true;
    assume ($t29 == $ResourceValue($1_coin_CoinStore'#0'_$memory, $t28));

    // assume Identical($t30, select coin::Coin.value(select coin::CoinStore.coin($t29))) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:262:9+36
    assume {:print "$at(80,9927,9963)"} true;
    assume ($t30 == $value#$1_coin_Coin'#0'($coin#$1_coin_CoinStore'#0'($t29)));

    // $t31 := coin::withdraw<#0>($t0, $t10) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:47+51
    assume {:print "$at(2,3108,3159)"} true;
    call $t31 := $1_coin_withdraw'#0'($t0, $t10);
    if ($abort_flag) {
        assume {:print "$at(2,3108,3159)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // coin::merge<#0>($t27, $t31) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:13+86
    call $t27 := $1_coin_merge'#0'($t27, $t31);
    if ($abort_flag) {
        assume {:print "$at(2,3074,3160)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // write_back[Reference($t12).deposit (coin::Coin<#0>)]($t27) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:13+86
    $t12 := $UpdateMutation($t12, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_deposit($Dereference($t12), $Dereference($t27)));

    // write_back[per_second_v8::Session<#0>@]($t12) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:13+86
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory := $ResourceUpdate($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $GlobalLocationAddress($t12),
        $Dereference($t12));

    // goto L5 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:86:99+1
    goto L5;

    // label L0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:88:21+9
    assume {:print "$at(2,3199,3208)"} true;
L0:

    // $t32 := 0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:89:29+1
    assume {:print "$at(2,3248,3249)"} true;
    $t32 := 0;
    assume $IsValid'u64'($t32);

    // $t33 := 0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:90:30+1
    assume {:print "$at(2,3280,3281)"} true;
    $t33 := 0;
    assume $IsValid'u64'($t33);

    // $t34 := 0x0 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:94:27+4
    assume {:print "$at(2,3429,3433)"} true;
    $t34 := 0;
    assume $IsValid'address'($t34);

    // assume Identical($t35, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:260:9+47
    assume {:print "$at(80,9803,9850)"} true;
    assume ($t35 == $1_signer_$address_of($t0));

    // assume Identical($t36, global<coin::CoinStore<#0>>($t35)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:261:9+59
    assume {:print "$at(80,9859,9918)"} true;
    assume ($t36 == $ResourceValue($1_coin_CoinStore'#0'_$memory, $t35));

    // assume Identical($t37, select coin::Coin.value(select coin::CoinStore.coin($t36))) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/coin.spec.move:262:9+36
    assume {:print "$at(80,9927,9963)"} true;
    assume ($t37 == $value#$1_coin_Coin'#0'($coin#$1_coin_CoinStore'#0'($t36)));

    // $t38 := coin::withdraw<#0>($t0, $t10) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:95:26+51
    assume {:print "$at(2,3520,3571)"} true;
    call $t38 := $1_coin_withdraw'#0'($t0, $t10);
    if ($abort_flag) {
        assume {:print "$at(2,3520,3571)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // assume Identical($t39, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t39 == $1_signer_$address_of($t0));

    // assume Identical($t40, global<account::Account>($t39)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t40 == $ResourceValue($1_account_Account_$memory, $t39));

    // $t41 := account::new_event_handle<per_second_v8::CreateSessionEvent>($t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:97:40+56
    assume {:print "$at(2,3613,3669)"} true;
    call $t41 := $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent'($t0);
    if ($abort_flag) {
        assume {:print "$at(2,3613,3669)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // assume Identical($t42, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t42 == $1_signer_$address_of($t0));

    // assume Identical($t43, global<account::Account>($t42)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t43 == $ResourceValue($1_account_Account_$memory, $t42));

    // $t44 := account::new_event_handle<per_second_v8::JoinSessionEvent>($t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:98:38+54
    assume {:print "$at(2,3708,3762)"} true;
    call $t44 := $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_JoinSessionEvent'($t0);
    if ($abort_flag) {
        assume {:print "$at(2,3708,3762)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // assume Identical($t45, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t45 == $1_signer_$address_of($t0));

    // assume Identical($t46, global<account::Account>($t45)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t46 == $ResourceValue($1_account_Account_$memory, $t45));

    // $t47 := account::new_event_handle<per_second_v8::StartSessionEvent>($t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:99:39+55
    assume {:print "$at(2,3802,3857)"} true;
    call $t47 := $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_StartSessionEvent'($t0);
    if ($abort_flag) {
        assume {:print "$at(2,3802,3857)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // assume Identical($t48, signer::$address_of($t0)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:257:9+39
    assume {:print "$at(58,11841,11880)"} true;
    assume ($t48 == $1_signer_$address_of($t0));

    // assume Identical($t49, global<account::Account>($t48)) at /Users/seb/.move/https___github_com_aptos-labs_aptos-core_git_devnet/aptos-move/framework/aptos-framework/sources/account.spec.move:258:9+36
    assume {:print "$at(58,11889,11925)"} true;
    assume ($t49 == $ResourceValue($1_account_Account_$memory, $t48));

    // $t50 := account::new_event_handle<per_second_v8::CloseSessionEvent>($t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:100:39+55
    assume {:print "$at(2,3897,3952)"} true;
    call $t50 := $1_account_new_event_handle'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CloseSessionEvent'($t0);
    if ($abort_flag) {
        assume {:print "$at(2,3897,3952)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // $t51 := pack per_second_v8::Session<#0>($t32, $t33, $t1, $t2, $t3, $t34, $t38, $t41, $t44, $t47, $t50) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:88:32+757
    assume {:print "$at(2,3210,3967)"} true;
    $t51 := $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($t32, $t33, $t1, $t2, $t3, $t34, $t38, $t41, $t44, $t47, $t50);

    // move_to<per_second_v8::Session<#0>>($t51, $t0) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:88:13+7
    if ($ResourceExists($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $addr#$signer($t0))) {
        call $ExecFailureAbort();
    } else {
        $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory := $ResourceUpdate($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $addr#$signer($t0), $t51);
    }
    if ($abort_flag) {
        assume {:print "$at(2,3191,3198)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // label L5 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:104:60+14
    assume {:print "$at(2,4040,4054)"} true;
L5:

    // $t52 := borrow_global<per_second_v8::Session<#0>>($t8) on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:104:23+17
    assume {:print "$at(2,4003,4020)"} true;
    if (!$ResourceExists($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t8)) {
        call $ExecFailureAbort();
    } else {
        $t52 := $Mutation($Global($t8), EmptyVec(), $ResourceValue($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t8));
    }
    if ($abort_flag) {
        assume {:print "$at(2,4003,4020)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // $t53 := borrow_field<per_second_v8::Session<#0>>.create_session_events($t52) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:27+34
    assume {:print "$at(2,4083,4117)"} true;
    $t53 := $ChildMutation($t52, 7, $create_session_events#$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'($Dereference($t52)));

    // $t54 := timestamp::now_seconds() on_abort goto L7 with $t9 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:106:88+24
    assume {:print "$at(2,4227,4251)"} true;
    call $t54 := $1_timestamp_now_seconds();
    if ($abort_flag) {
        assume {:print "$at(2,4227,4251)"} true;
        $t9 := $abort_code;
        assume {:print "$track_abort(55,1):", $t9} $t9 == $t9;
        goto L7;
    }

    // $t55 := pack per_second_v8::CreateSessionEvent($t8, $t1, $t2, $t3, $t54) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:63+142
    assume {:print "$at(2,4119,4261)"} true;
    $t55 := $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_CreateSessionEvent($t8, $t1, $t2, $t3, $t54);

    // opaque begin: event::emit_event<per_second_v8::CreateSessionEvent>($t53, $t55) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:9+197

    // opaque end: event::emit_event<per_second_v8::CreateSessionEvent>($t53, $t55) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:9+197

    // write_back[Reference($t52).create_session_events (event::EventHandle<per_second_v8::CreateSessionEvent>)]($t53) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:9+197
    $t52 := $UpdateMutation($t52, $Update'$e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0''_create_session_events($Dereference($t52), $Dereference($t53)));

    // write_back[per_second_v8::Session<#0>@]($t52) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:105:9+197
    $e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory := $ResourceUpdate($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $GlobalLocationAddress($t52),
        $Dereference($t52));

    // label L6 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:108:5+1
    assume {:print "$at(2,4268,4269)"} true;
L6:

    // assert exists<per_second_v8::Session<#0>>($t7) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.spec.move:11:9+50
    assume {:print "$at(3,352,402)"} true;
    assert {:msg "assert_failed(3,352,402): post-condition does not hold"}
      $ResourceExists($e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c_per_second_v8_Session'#0'_$memory, $t7);

    // return () at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.spec.move:11:9+50
    return;

    // label L7 at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:108:5+1
    assume {:print "$at(2,4268,4269)"} true;
L7:

    // abort($t9) at /Users/seb/repo/hunt/persecond/move_module/sources/per_second.move:108:5+1
    assume {:print "$at(2,4268,4269)"} true;
    $abort_code := $t9;
    $abort_flag := true;
    return;

}
