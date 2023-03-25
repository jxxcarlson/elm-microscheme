
(define my-hours (list (cons 1 20) (cons 2 40)))
(define (hours-from-hours-minutes h m) (roundTo 2 (+ h (/ m 60.0))))
(define (hours-from-hours-minutes-pair pair) (hours-from-hours-minutes (car pair) (cdr pair)))
(define (compute-hours hm-pairs) (map hours-from-hours-minutes-pair hm-pairs))
(define (compute-earnings rate hm-pairs) (* rate (compute-hours hm-pairs)))

(define (compute-hours-aux hm-pairs) (map hours-from-hours-minutes-pair hm-pairs))
(define (round2 x) (roundTo 2 x))
(define (compute-hours hours) (map round2 (compute-hours-aux hours)))

(map (lambda (x) (* 2 x)) 1 2 3) ; oK

(+ (map (lambda (x) (* 2 x)) (1 2 3))); ERROR
; EvalError 1 "Could not unwrap argument to evalPlus" ,
; expr (L [Sym "+",L [Sym "map",Lambda (L [Str "x"]) (L [Sym "*",Z 2,Str "x"]),L [Z 1,Z 2,Z 3]]])

foo = (L [Sym "+",L [Sym "map",Lambda (L [Str "x"]) (L [Sym "*",Z 2,Str "x"]),L [Z 1,Z 2,Z 3]]])

;> (hours-from-hours-minutes 1 30)
;1.5

;> (hours-from-hours-minutes-pair (cons 1 30))
;1.5

;> (compute-hours-aux my-hours)
;(1.3333333333333333 2.6666666666666665)
;
;> (compute-hours my-hours)
;(1.33 2.67)

