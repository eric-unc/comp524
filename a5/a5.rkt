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
  (if (equal? opt-expr-list null)
      null
      (eval-expr (second opt-expr-list))))

; todo
(define (eval-expr expr)
  (second expr))
