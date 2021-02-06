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

(define (number-token str)
  (if (string-contains? str ".")
      (token 'FLOAT (string->number str))
      (token 'INT (string->number str))))

(define (string-token str)
  (token 'STRING (substring str 1 (- (string-length str) 1))))

(define (name-or-keyword-token str)
  (case str
    [("def" "fun", "if", "not", "and", "or")
     (token (string->symbol (string-upcase (string-trim str))))]
    [else (token 'NAME (string->symbol str))]))

(define (invalid-token str)
  (token 'INVALID str))

; Matching table
(define re-table
  (list
    (list #px"^[ \r\n\t]+" skip-match) ; whitespace
    (list #px"^//[^\n]+(\n|$)" skip-match) ; // comments
    (list #px"^/\\*(?:.|\n)*\\*/" skip-match) ; /* comments */
    (list #px"^[(){},;.]" punctuation-token)
    (list #px"^-?\\d+(?:\\.\\d+)?(?=[\r\n\t (){},;.]|$)" number-token)
    (list #px"^\".*\"(?=[\r\n\t (){},;.]|$)" string-token)
    (list #px"^[^(){},;.\" \r\n\t\\d][^(){},;.\" \r\n\t]*(?=[\r\n\t (){},;.]|$)" name-or-keyword-token)))

; Lex function
(define (lex str) null)
