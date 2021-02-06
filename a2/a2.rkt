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
(define re-table
  (list
    (list #px"^[ \r\n\t]+" skip-match) ; whitespace
    (list #px"^//[^\n]+(\n|$)" skip-match) ; // comments
    (list #px"^/\\*(?:.|\n)*\\*/" skip-match) ; /* comments */
    (list #px"^[(){},;.]" punctuation-token)
    (list #px"^-?\\d+(?:\\.\\d+)?" number-token)
    (list #px"^\".*\"" string-token)
    (list #px"^[^(){},;.\" \r\n\t\\d][^(){},;.\" \r\n\t]*" name-or-keyword-token)))

; Lex function
(define (lex str) null)
