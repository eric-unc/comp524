% Problem 1
member(_, []) :- false.
member(X, [X | _]).
member(X, [_ | Rest]) :- member(X, Rest).

% Problem 2
last([], _) :- false.
last([X | _], X).
last([_ | Rest], X) :- last(Rest, X).
