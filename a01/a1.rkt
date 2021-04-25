#lang racket

(require racket/trace)

; Problem 1
#;(define (countdown n)
  (if (< n 0) '() (cons n (countdown (- n 1)))))

; Problem 2
; Ideal solution
#;(define (remove-first item lst)
  (cond
    [(empty? lst) '()]
    [(equal? item (car lst)) (cdr lst)]
    [else (cons (car lst) (remove-first item (cdr lst)))]))

; More messy solution that should work
(define (remove-first item lst)
  (if (empty? lst) '() ; if
      (if (equal? item (car lst)) (cdr lst) ; else if
          (cons (car lst) (remove-first item (cdr lst)))))) ; else

; Problem 3
(define (insert-after-every to-find to-add lst)
  (if (empty? lst) '() ; if
      (if (equal? to-find (car lst))
          (cons to-find (cons to-add (insert-after-every to-find to-add (cdr lst)))) ; then
          (cons (car lst) (insert-after-every to-find to-add (cdr lst)))))) ; else

; Problem 4
; Works locally
#;(define (zip lst1 lst2)
  (if (or (empty? lst1) (empty? lst2)) null ; if
      (cons (cons (car lst1) (car lst2)) (zip (cdr lst1) (cdr lst2)))))

; Submitted
#;(define (zip lst1 lst2)
  (if (or (empty? lst1) (empty? lst2)) null ; if
      (cons (list (car lst1) (car lst2)) (zip (cdr lst1) (cdr lst2)))))

; Problem 5
(define (append lst1 lst2)
  (if (empty? lst1) lst2
      (cons (car lst1) (append (cdr lst1) lst2))))

; Problem 6
(define (binary->natural lst)
  (letrec ([bin->natural-from (lambda (lst b)
                                (if (empty? lst) 0
                                    (+
                                     (if (equal? (car lst) 1) (expt 2 b) 0)
                                     (bin->natural-from (cdr lst) (+ b 1)))))])
    (bin->natural-from lst 0)))

; Problem 7
(define (index-of-item item lst)
  (letrec ([index-of-item-from (lambda (item lst index)
                                 (if (equal? item (car lst)) index
                                     (index-of-item-from item (cdr lst) (+ index 1))))]) ; else
    (index-of-item-from item lst 0)))

; Problem 8
(define (divide num div)
  (letrec ([divide-from (lambda (num i)
                          (if (<= num 0) i
                              (divide-from (- num div) (+ i 1))))])
    (divide-from num 0)))

; Problem 9
(define (countdown n)
  (range n -1 -1))

; Problem 10
(define (zip lst1 lst2)
  (map (lambda (e1 e2)
         (list e1 e2))
         lst1 lst2))

; Problem 11
(define (sum-of-products lst1 lst2)
  (foldl (lambda (a b acc)
           (+ acc (* a b)))
         0 lst1 lst2))

; Problem 12
(define (collatz-length n)
  (letrec ([collatz-inner (lambda (n i)
                            (if (eq? n 1) i
                                (if (odd? n) (collatz-inner (+ (* 3 n) 1) (+ i 1))
                                    (collatz-inner (/ n 2) (+ i 1)))))]) ; even
    (collatz-inner n 0)))

; Problem 13
; I don't understand this one at all.
#;(define (cartesian-product lst1 lst2)
  (append-map vector->list (list lst1 lst2)))
