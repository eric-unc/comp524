(* Useful to get out of REPL *)
(* OS.Process.exit(OS.Process.success); *)

(* Problem 1 *)
(* int -> int list‌‍‍‎‍ *)
fun countdown(n: int) =
	if n < 0 then
		[]
	else
		n::countdown(n - 1)

(* Problem 2 (WIP) *)
(* ('a list * 'b list) -> ('a * 'b) list‌‍‍‎‍ *)
fun zip(list1, list2) =
	if list1 = [] orelse list2 = [] then
		[]
	else
		(hd list1, hd list2)::zip(tl list1, tl list2)

(* Problem 3 *)
fun append(list1, list2) = list1 @ list2

(* Problem 4 (WIP) *)
fun binaryToNatural‌‍‍‎‍ list =
	let fun exp2(n) =
		if n = 0
			1
		else
			2*exp2(n)
	in
		exp2(list)
