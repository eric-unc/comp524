# Proposed Exam Question

## The Question
Define a function `triple` in Racket that given a list, returns a new list with each element multiplied by `3`. The function should be recursive, and using `if` and `cons` is recommend.

## Sample Answer
```rkt
(define (triple lst)
  (if (empty? lst)
      null
      (cons (* (first lst) 3) (triple (rest lst)))))
```

## Points
4 points
