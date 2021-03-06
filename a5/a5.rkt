#lang racket
(require "a3.rkt")

(define (eval code)
  (eval-program (parse code)))

(define (eval-program program)
  (eval-expr-list (second program)))

(define (eval-expr-list expr-list)
  (if (equal? expr-list null)
      null
      (cons (eval-expr (second expr-list)) (eval-opt-expr-list (third expr-list)))))

(define (eval-opt-expr-list opt-expr-list)
  (if (< (length opt-expr-list) 2) ; (equal? opt-expr-list null)
      null
      (eval-expr-list (second opt-expr-list))))

; todo
(define (eval-expr expr)
  expr); (second expr))

(define (eval-atom)
  null)

(define (eval-invocation)
  null)
