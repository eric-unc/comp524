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
% Helper
reverse([], X, X).
reverse([X], Y, Z) :- reverse([], Y, [X, Z]).
reverse([X | RestX], Y, Z) :- reverse(RestX, Y, [X, Z]).

% Main prederate
reverse([], []).
reverse([_], []) :- false.
reverse([], [_]) :- false.
reverse([X], [X]).
reverse(X, Y) :- reverse(X, Y, []).
