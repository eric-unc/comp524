(* Useful to get out of REPL *)
(* OS.Process.exit(OS.Process.success) *)

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
		(first::rest = list1 => first, first::rest = list2 -> first)::zip(first::rest = list1 => rest, first::rest = list2 -> rest)
