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
