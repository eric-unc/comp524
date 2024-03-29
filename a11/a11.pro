:- use_module(library(clpfd)).

% Problem 1
member(_, []) :- false.
member(X, [X | _]).
member(X, [_ | Rest]) :- member(X, Rest).

% Problem 2
last([], _) :- false.
last([X | _], X).
last([_ | Rest], X) :- last(Rest, X).

% Problem 3
% TODO: maybe could be cleaned up somehow
append(X, [], X).
append([], X, X).
append([X | RestX], Y, [Z | RestZ]) :- X = Z, append(RestX, Y, RestZ).

% Problem 4
zip([], [], _).
zip([], _, []).
zip([(A, B)], [A], [B]).
zip([(A, B) | Rest1], [A | RestA], [B | RestB]) :- zip(Rest1, RestA, RestB).

% Problem 5
% Maybe this could also be simplified.
% Helper
reverse([], X, X).
reverse([X], Y, Z) :- reverse([], Y, [X | Z]).
reverse([X | RestX], Y, Z) :- reverse(RestX, Y, [X | Z]).

% Main prederate
reverse([], []).
reverse([_], []) :- false.
reverse([], [_]) :- false.
reverse([X], [X]).
reverse(X, Y) :- reverse(X, Y, []).

% Problem 6
/*
% "Do not worry about the details. Just make sure you copy-paste this into all your answers."
type(N, int) :- catch(clpfd:in(N, '..'(inf, sup)), error(type_error(integer, N), _), false).

type(plus(L, R), int) :-
	type(L, int),
	type(R, int).

type(minus(L, R), int) :-
	type(L, int),
	type(R, int).

type(times(L, R), int) :-
	type(L, int),
	type(R, int).

type(divide(L, R), int) :-
	type(L, int),
	type(R, int).

% Problem 7
type(zerop(X), bool) :-
	type(X, int).

type(lt(X, Y), bool) :-
	type(X, int),
	type(Y, int).

% Problem 8
test(if(Test, Consequent, Alternate), T) :-
	type(Test, bool),
	type(Consequent, T),
	type(Alternative, T).

type(nil, list(_)).
type(cons(Head, Tail), list(T)) :-
	type(Head, T),
	type(Tail, list(T)).

type(nilp(List), bool) :-
	type(List, list(_)).

type(head(List), T) :-
	type(List, list(T)).

type(tail(List), list(T)) :-
	type(List, list(T)).

% Problem 9
type(pair(X, Y), tuple(A, B)) :-
	type(X, A),
	type(Y, B).

type(first(P), T) :-
	type(P, tuple(T, _)).

type(second(P), T) :-
	type(P, tuple(_, T)).
*/
% Problem 10
in_env(Binding, [Binding|_]) :- !.
in_env(Binding, [_|T]) :- in_env(Binding, T).

type(N, _, int) :- catch(clpfd:in(N, '..'(inf, sup)), error(type_error(integer, N), _), false).

type(name(X), Env, T) :- in_env(binding(X, T), Env).

type(plus(L, R), Env, int) :-
	type(L, Env, int),
	type(R, Env, int).

type(minus(L, R), Env, int) :-
	type(L, Env, int),
	type(R, Env, int).

type(times(L, R), Env, int) :-
	type(L, Env, int),
	type(R, Env, int).

type(divide(L, R), Env, int) :-
	type(L, Env, int),
	type(R, Env, int).

type(zerop(X), Env, bool) :-
	type(X, Env, int).

type(lt(X, Y), Env, bool) :-
	type(X, Env, int),
	type(Y, Env, int).

test(if(Test, Consequent, Alternative), Env, T) :-
	type(Test, Env, bool),
	type(Consequent, Env, T),
	type(Alternative, Env, T).

type(nil, _, list(_)).
type(cons(Head, Tail), Env, list(T)) :-
	type(Head, Env, T),
	type(Tail, Env, list(T)).

type(nilp(List), Env, bool) :-
	type(List, Env, list(_)).

type(head(List), Env, T) :-
	type(List, Env, list(T)).

type(tail(List), Env, list(T)) :-
	type(List, Env, list(T)).

type(pair(X, Y), Env, tuple(A, B)) :-
	type(X, Env, A),
	type(Y, Env, B).

type(first(P), Env, T) :-
	type(P, Env, tuple(T, _)).

type(second(P), Env, T) :-
	type(P, Env, tuple(_, T)).

% Problem 11
:- set_prolog_flag(occurs_check, true).

type(invoke(Proc, Arg), Env, Tresult) :-
	type(Proc, Env, func(Targ, Tresult)),
	type(Arg, Env, Targ).

type(proc(Param, Body), Env, func(Tin, Tout)) :-
	type(Body, [binding(Param, Tin) | Env], Tout).

%% Some test queries:
% type(invoke(proc(x, plus(first(name(x)), second(name(x)))), pair(5,3)), [], T).
% T = int.

% type(invoke(proc(x, nilp(name(x))), cons(1, nil)), [], T).
% T = bool.

% type(proc(x, name(x)), [], T).
% T = func(_42290, _42290).

% type(proc(x, plus(first(name(x)), second(name(x)))), [], T).
% T = func(tuple(int, int), int).

% type(proc(f, proc(x, invoke(name(f), invoke(name(f), name(x))))), [], T).
