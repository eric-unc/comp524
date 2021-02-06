#lang racket

(define (token type [data #f])
  (list type data))

; Token types
(define (skip-match str) #f)

(define (punctuation-token str)
  (token
    (case str
      [("(") 'OPAREN]
      [(")") 'RPAREN]
      [("{") 'OBRACE]
      [("}") 'CBRACE]
      [(",") 'COMMA]
      [(";") 'SEMICOLON]
      [(".") 'PERIOD])))

; TODO: int v. float
(define (number-token str)
  (token 'NUM (string->number str)))

; TODO: get rid of ", "
(define (string-token str)
  (token 'STRING str))

(define (name-or-keyword-token str)
  (case str
    [("def" "fun", "if", "not", "and", "or")
     (token (string->symbol (string-upcase (string-trim str))))]
    [else (token 'NAME (string->symbol str))]))

; Matching table
; TODO
(define re-table
  (list
    (list #rx"^[ \r\n\t]+" skip-match) ; whitespace
    (list #rx"^//[^\n]+(\n|$)" skip-match) ; // comments
    (list #rx"^[=+/;]" punctuation-token)
    (list #rx"^[0-9]+" number-token)
    (list #rx"^[A-Za-z]+" name-or-keyword-token)))

; Lex function
(define (lex str) null)
