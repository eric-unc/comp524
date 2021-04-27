(* Useful to get out of REPL *)
(* OS.Process.exit(OS.Process.success); *)

(* Problem 1 *)
(* int -> int list‌‍‍‎‍ *)
fun countdown n =
	if n < 0 then
		[]
	else
		n::countdown(n - 1)

(* Problem 2 *)
(* ('a list * 'b list) -> ('a * 'b) list‌‍‍‎‍ *)
fun zip(list1, list2) =
	if length list1 = 0 orelse length list2 = 0 then
		[]
	else
		(hd list1, hd list2)::zip(tl list1, tl list2)

(* Problem 3 *)
(* 'a list * 'a list -> 'a list‌‍‍‎‍ *)
fun append(list1, list2) = list1 @ list2

(* Problem 4 *)
(* This version does it backwards (whoops!) *)
(*fun binaryToNatural(list) =
	let fun exp2(n) =
		if n = 0 then
			1
		else
			2*exp2(n)
	in
		if length list = 0 then
			0
		else
			if hd list = 1 then
				exp2(length list - 1) + binaryToNatural(tl list)
			else
				binaryToNatural(tl list)
	end*)
(* int list -> int‌‍‍‎‍ *)
fun binaryToNatural(list) =
	let
		fun exp2 n =
			if n = 0 then
				1
			else
				2*exp2(n - 1)

		fun binaryToNaturalInner(lst, n) =
			if length lst = 0 then
				0
			else
				if hd lst = 1 then
					exp2 n + binaryToNaturalInner(tl lst, n + 1)
				else
					binaryToNaturalInner(tl lst, n + 1)
	in binaryToNaturalInner(list, 0)
	end

(* Problem 5 *)
(* ''a * ''a * ''a list -> ''a list‌‍‍‎‍ *)
fun insertAfterEvery(toFind, toPut, list) =
	if length list = 0 then
		[]
	else
		if hd list = toFind then
			hd list::toPut::insertAfterEvery(toFind, toPut, tl list)
		else
			hd list::insertAfterEvery(toFind, toPut, tl list)

(* Problem 6 *)
datatype aexp = Num of int
			| Plus of aexp * aexp
			| Minus of aexp * aexp
			| Times of aexp * aexp
			| Divide of aexp * aexp

(* Problem 7 *)
fun eval_aexp(exp) =
	case exp
		of Num n => n
		| Plus(e1, e2) => eval_aexp e1 + eval_aexp e2
		| Minus(e1, e2) => eval_aexp e1 - eval_aexp e2
		| Times(e1, e2) => eval_aexp e1 * eval_aexp e2
		| Divide(e1, e2) => eval_aexp e1 div eval_aexp e2

(* Problem 8 *)
datatype str_exp = String of string
				| StringConcat of str_exp * str_exp

datatype bool_exp = Not of bool_exp
				| StringEqual of str_exp * str_exp
				| IntEqual of aexp * aexp
				| StringLessThan of str_exp * str_exp
				| IntLessThan of aexp * aexp

(* Problem 9 *)
fun eval_str_exp(exp) =
	case exp
		of String s => s
		| StringConcat(e1, e2) => eval_str_exp e1 ^ eval_str_exp e2

fun eval_bool_exp(exp) =
	case exp
		of Not e => not (eval_bool_exp e)
		| StringEqual(e1, e2) => eval_str_exp e1 = eval_str_exp e2
		| IntEqual(e1, e2) => eval_aexp e1 = eval_aexp e2
		| StringLessThan(e1, e2) => eval_str_exp e1 < eval_str_exp e2
		| IntLessThan(e1, e2) => eval_aexp e1 < eval_aexp e2

(* Problem 10 *)
datatype dsexp = Num of int
			| Plus of dsexp * dsexp
			| Minus of dsexp * dsexp
			| Times of dsexp * dsexp
			| Divide of dsexp * dsexp
			| String of string
			| StringConcat of dsexp * dsexp
			| Not of dsexp
			| StringEqual of dsexp * dsexp
			| IntEqual of dsexp * dsexp
			| StringLessThan of dsexp * dsexp
			| IntLessThan of dsexp * dsexp

(* Problem 11 *)
datatype value = NumV of int
			| StringV of string
			| BoolV of bool
			| ErrorV

fun eval_dsexp exp =
	case exp
		of Num n => NumV n
		| Plus(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => NumV(n1 + n2)
								| _ => ErrorV)
		| Minus(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => NumV(n1 - n2)
								| _ => ErrorV)
		| Times(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => NumV(n1 * n2)
								| _ => ErrorV)
		| Divide(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => NumV(n1 div n2)
								| _ => ErrorV)
		| String s => StringV s
		| StringConcat(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (StringV s1, StringV s2) => StringV(s1 ^ s2)
								| _ => ErrorV)
		| Not e => (case eval_dsexp e
						of BoolV b => BoolV(not b)
						| _ => ErrorV)
		| StringEqual(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (StringV s1, StringV s2) => BoolV(s1 = s2)
								| _ => ErrorV)
		| IntEqual(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => BoolV(n1 = n2)
								| _ => ErrorV)
		| StringLessThan(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (StringV s1, StringV s2) => BoolV(s1 < s2)
								| _ => ErrorV)
		| IntLessThan(e1, e2) => (case (eval_dsexp e1, eval_dsexp e2)
								of (NumV n1, NumV n2) => BoolV(n1 < n2)
								| _ => ErrorV)
