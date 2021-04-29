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
