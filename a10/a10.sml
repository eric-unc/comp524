(* Useful to get out of REPL *)
(* OS.Process.exit(OS.Process.success); *)

(* Problem 1 *)
(* int -> int list‌‍‍‎‍ *)
fun countdown(n: int) =
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
		fun exp2(n) =
			if n = 0 then
				1
			else
				2*exp2(n - 1)

		fun binaryToNaturalInner(lst, n) =
			if length lst = 0 then
				0
			else
				if hd lst = 1 then
					exp2(n) + binaryToNaturalInner(tl lst, n + 1)
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
			hd(list)::toPut::insertAfterEvery(toFind, toPut, tl list)
		else
			hd(list)::insertAfterEvery(toFind, toPut, tl list)

(* Problem 6 *)
datatype aexp = Num of int
			| Plus of aexp * aexp
			| Minus of aexp * aexp
			| Times of aexp * aexp
			| Divide of aexp * aexp

(* Problem 7 *)
fun eval_aexp(exp: aexp): int =
	case exp
		of Num n => n
		| Plus(e1, e2) => eval_aexp(e1) + eval_aexp(e2)
		| Minus(e1, e2) => eval_aexp(e1) - eval_aexp(e2)
		| Times(e1, e2) => eval_aexp(e1) * eval_aexp(e2)
		| Divide(e1, e2) => eval_aexp(e1) div eval_aexp(e2)

(* Problem 8 *)
datatype str_exp = String of string
				| StringConcat of str_exp * str_exp

datatype bool_exp = Not of bool_exp
				| StringEqual of str_exp * str_exp
				| IntEqual of aexp * aexp
				| StringLessThan of str_exp * str_exp
				| IntLessThan of aexp * aexp

(* Problem 9 *)
fun eval_str_exp(exp): string =
	case exp
		of String s => s
		| StringConcat(e1, e2) => eval_str_exp(e1) ^ eval_str_exp(e2)

fun eval_bool_exp(exp): bool =
	case exp
		of Not e => not (eval_bool_exp e)
		| StringEqual(e1, e2) => eval_str_exp(e1) = eval_str_exp(e2)
		| IntEqual(e1, e2) => eval_aexp(e1) = eval_aexp(e2)
		| StringLessThan(e1, e2) => eval_str_exp(e1) < eval_str_exp(e2)
		| IntLessThan(e1, e2) => eval_aexp(e1) < eval_aexp(e2)
