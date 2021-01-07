#|
Chris Swagler + Ty Marshall
11/22/2020
|#

;; TETRIS ;;
(require 2htdp/image)
(require 2htdp/universe)

;;;;;;; DATA DEFINITIONS ;;;;;;;;;;
(define-struct world [piece pile score])
;; A World is a (make-world Piece Pile NatNum)
;; Interpretation: The World State of our game
;; _piece_ is the current piece
;; _pile_ is the current pile
;; _score_ which represents the current score

(define-struct brick [x y color])
;; A Brick is a (make-brick Integer Integer Color)
;; Interpretation: A (make-brick x-g y-g c) represents a square brick
;; at position (x-g, y-g) in the grid, to be rendered in color c.

;; A ListOfBricks (LOB) is one of
;; - (cons Brick empty)
;; - (cons Brick LOB)
;; represents a list of bricks.

;; A PieceShape is one of :
;; - "O"
;; - "I"
;; - "L"
;; - "J"
;; - "T"
;; - "Z"
;; - "S"
;; - "1"
;; - "5"
;; Represents the shape of the piece.

(define-struct piece [center bricks])
;; A Piece is a (make-piece Posn PieceShape LOB)
;; A (make-piece center pieceshape bricks) represents a tetris piece where
;; _center_ is a Posn representing the center of the teris piece
;; _pieceshape_ is a PieceShape representing the shape of the tetris piece
;; and _bricks_ is a LOB representing the bricks that make up the piece.


;A Pile is a ListOfBricks that does not move and sits in the world.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS: things we need to keep track of that never change

;;;;;; CONSTANTS ;;;;;;;
(define GRIDSIZE-SQSIZE 20) ;; width and height of the grid squares
(define BOARD-HEIGHT 20) ;; height of game board
(define BOARD-WIDTH 10) ;; width of game board
(define BOARD-HEIGHT/PIX (* BOARD-HEIGHT GRIDSIZE-SQSIZE)) ; game board height in pixels
(define BOARD-WIDTH/PIX (* BOARD-WIDTH GRIDSIZE-SQSIZE)) ; game board width in pixels
(define BACKGROUND (empty-scene BOARD-WIDTH/PIX BOARD-HEIGHT/PIX)) ;; image for the background
(define TICK-RATE 0.25) ;; tick-rate for big-bang


;; EXAMPLES :
;; Examples for Brick

(define ex-brick1 (make-brick 8 7 "green"))
(define ex-brick2 (make-brick 3 2 "orange"))
(define ex-brick3 (make-brick 5 4 "red"))

;; Examples for LOB
;; "O"
(define ex-lob1 (list (make-brick 4 17 "green")
                      (make-brick 5 17 "green")
                      (make-brick 4 16 "green")
                      (make-brick 5 16 "green")))
;; "I"
(define ex-lob2 (list (make-brick 4 20 "blue")
                      (make-brick 5 20 "blue")
                      (make-brick 6 20 "blue")
                      (make-brick 7 20 "blue")))

;; "L"
(define ex-lob3 (list (make-brick 4 19 "purple")
                      (make-brick 5 19 "purple")
                      (make-brick 6 19 "purple")
                      (make-brick 6 20 "purple")))

;; "J"
(define ex-lob4 (list (make-brick 4 19 "turquoise")
                      (make-brick 5 19 "turquoise")
                      (make-brick 6 19 "turquoise")
                      (make-brick 6 20 "turquoise")))

;; "T"
(define ex-lob5 (list (make-brick 4 20 "orange")
                      (make-brick 5 20 "orange")
                      (make-brick 5 19 "orange")
                      (make-brick 6 20 "orange")))

;; "Z"
(define ex-lob6 (list (make-brick 4 20 "salmon")
                      (make-brick 5 20 "salmon")
                      (make-brick 5 19 "salmon")
                      (make-brick 6 19 "salmon")))

;; "S"
(define ex-lob7 (list (make-brick 4 19 "red")
                      (make-brick 5 19 "red")
                      (make-brick 5 20 "red")
                      (make-brick 6 20 "red")))

;; "1"
(define ex-lob10 (list (make-brick 4 19 "magenta")))

;; "5"
(define ex-lob11 (list (make-brick 4 19 "darkgreen")
                       (make-brick 5 19 "darkgreen")
                       (make-brick 6 19 "darkgreen")
                       (make-brick 7 19 "darkgreen")
                       (make-brick 8 19 "darkgreen")))


;; Out of Bounds
(define ex-lob8 (list (make-brick -4 -3 "red")
                      (make-brick -3 -3 "red")
                      (make-brick -3 -2 "red")
                      (make-brick -2 -2 "red")))

;; List of Bricks inside the Boundaries
(define ex-lob9 (list (make-brick 4 13 "red")
                      (make-brick 5 13 "red")
                      (make-brick 5 14 "red")
                      (make-brick 6 14 "red")))

;Piles
(define PILE0 (list (make-brick 4 17 "red")
                    (make-brick 5 0 "green")
                    (make-brick 7 0 "blue")
                    (make-brick 6 0 "yellow")
                    (make-brick 3 2 "darkgreen")
                    (make-brick 0 0 "magenta")))

(define PILE1 (list (make-brick 4 0 "red")
                    (make-brick 2 5 "green")
                    (make-brick 4 3 "blue")
                    (make-brick 1 7 "yellow")
                    (make-brick 1 2 "darkgreen")
                    (make-brick 5 0 "magenta")))

(define PILE2 (list (make-brick 0 0 "red")
                    (make-brick 8 7 "green")
                    (make-brick 2 2 "blue")
                    (make-brick 3 3 "yellow")
                    (make-brick 4 4 "darkgreen")
                    (make-brick 5 5 "magenta")))

(define PILE3 (list (make-brick 5 0 "red")
                    (make-brick 4 1 "green")
                    (make-brick 3 2 "blue")
                    (make-brick 2 3 "yellow")
                    (make-brick 1 4 "darkgreen")
                    (make-brick 0 5 "magenta")))

(define PILE4 (list (make-brick 0 5 "red")
                    (make-brick 2 1 "green")
                    (make-brick 4 3 "blue")
                    (make-brick 6 5 "yellow")
                    (make-brick 8 7 "darkgreen")
                    (make-brick 9 9 "magenta")))

(define PILE5 (list (make-brick 0 5 "red")
                    (make-brick 2 1 "green")
                    (make-brick 1 1 "green")
                    (make-brick 0 1 "green")
                    (make-brick 3 1 "green")
                    (make-brick 4 1 "green")
                    (make-brick 5 1 "green")
                    (make-brick 6 1 "green")
                    (make-brick 7 1 "green")
                    (make-brick 8 1 "green")
                    (make-brick 9 1 "green")
                    (make-brick 2 4 "green")
                    (make-brick 1 4 "green")
                    (make-brick 0 4 "green")
                    (make-brick 3 4 "green")
                    (make-brick 4 4 "green")
                    (make-brick 5 4 "green")
                    (make-brick 6 4 "green")
                    (make-brick 7 4 "green")
                    (make-brick 8 4 "green")
                    (make-brick 9 4 "green")
                    (make-brick 4 3 "blue")
                    (make-brick 6 5 "yellow")
                    (make-brick 8 7 "darkgreen")
                    (make-brick 9 9 "magenta")))

(define PILE6 (list (make-brick 0 5 "red")
                    (make-brick 2 1 "green")
                    (make-brick 1 1 "green")
                    (make-brick 0 1 "green")
                    (make-brick 3 1 "green")
                    (make-brick 4 1 "green")
                    (make-brick 5 1 "green")
                    (make-brick 3 5 "red")
                    (make-brick 6 1 "darkgreen")
                    (make-brick 7 1 "green")
                    (make-brick 8 1 "green")
                    (make-brick 9 1 "green")
                    (make-brick 2 2 "green")
                    (make-brick 1 2 "green")
                    (make-brick 0 2 "green")
                    (make-brick 3 2 "darkgreen")
                    (make-brick 4 2 "green")
                    (make-brick 5 2 "green")
                    (make-brick 6 2 "green")
                    (make-brick 7 2 "green")
                    (make-brick 8 2 "green")
                    (make-brick 9 2 "green")
                    (make-brick 4 3 "blue")
                    (make-brick 6 5 "yellow")
                    (make-brick 8 7 "darkgreen")
                    (make-brick 0 6 "yellow")
                    (make-brick 2 6 "yellow")
                    (make-brick 1 6 "yellow")
                    (make-brick 3 6 "yellow")
                    (make-brick 4 6 "yellow")
                    (make-brick 5 6 "yellow")
                    (make-brick 6 6 "yellow")
                    (make-brick 7 6 "yellow")
                    (make-brick 8 6 "yellow")
                    (make-brick 5 0 "magenta")
                    (make-brick 3 0 "magenta")
                    (make-brick 9 9 "magenta")))

;Example Scores
(define SCORE0 30)
(define SCORE1 120)
(define SCORE2 40)
(define SCORE3 300)
(define SCORE4 150)


;; Examples for Piece

(define ex-piece1 (make-piece (make-posn 4 17) ex-lob1))
(define ex-piece2 (make-piece (make-posn 4 20) ex-lob2))
(define ex-piece3 (make-piece (make-posn 4 19) ex-lob3))
(define ex-piece4 (make-piece (make-posn 4 20) ex-lob4))
(define ex-piece5 (make-piece (make-posn 4 20) ex-lob5))
(define ex-piece6 (make-piece (make-posn 4 20) ex-lob6))
(define ex-piece7 (make-piece (make-posn 4 20) ex-lob7))
(define ex-piece10 (make-piece (make-posn 4 20) ex-lob10))
(define ex-piece11 (make-piece (make-posn 4 20) ex-lob11))
;; example piece for out of bounds
(define ex-piece8 (make-piece (make-posn -3 -3) ex-lob8))
;; example piece for inside the boundaries
(define ex-piece9 (make-piece (make-posn 5 13) ex-lob9))

;; Examples for PieceShape
(define ex-pieceshape1 "O")
(define ex-pieceshape2 "I")
(define ex-pieceshape3 "L")
(define ex-pieceshape4 "J")
(define ex-pieceshape5 "T")
(define ex-pieceshape6 "Z")
(define ex-pieceshape7 "S")
(define ex-pieceshape8 "1")
(define ex-pieceshape9 "5")


;; Example for World

(define ex-world1 (make-world ex-piece3 PILE1 SCORE0))
(define ex-world2 (make-world ex-piece1 PILE3 SCORE1))
(define ex-world3 (make-world ex-piece2 PILE5 SCORE2))
(define ex-world4 (make-world ex-piece4 PILE4 SCORE3))
(define ex-world5 (make-world ex-piece5 PILE2 SCORE4))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Templates

;; world-templ : World -> ???
#; (define (world-templ w)
     (... (piece-templ (world-piece w)) ... (lob-templ (world-pile w)) ... (world-score w)))

;; brick-templ : Brick -> ???
#; (define (brick-templ b)
     (... (brick-x b) ...
          (brick-y b) ...
          (brick-color b) ...))

;; lob-templ : LOB -> ???
#; (define (lob-templ lob)
     (cond
       [(empty? (rest lob)) (... (brick-templ (first lob) ...))]
       [(cons? (rest lob)) (... (brick-templ (first lob)) ... (lob-templ (rest lob)) ...)]))

;; pieceshape-templ : PieceShape -> ???
#; (define (pieceshape-templ ps)
     (cond
       [(string=? "O" ps) ...]
       [(string=? "I" ps) ...]
       [(string=? "L" ps) ...]
       [(string=? "J" ps) ...]
       [(string=? "T" ps) ...]
       [(string=? "Z" ps) ...]
       [(string=? "S" ps) ...]
       [(string=? "1" ps) ...]
       [(string=? "5" ps) ...]))

; piece-templ : Piece -> ???
#; (define (piece-templ p)
     (... (piece-center p) ...
          (lob-templ (piece-bricks p) ...)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; RESPAWN / DROP PIECE FUNCTIONS ;;;;;;;;;;;;;;;;;;;;
;d-p : Piece Pile -> Piece
;; Given a Piece, checks to see if all the blocks within the piece have left the screen or hit Pile
;; and if so, creates a new piece at the top of the screen. Otherwise, drop the piece down.
(check-expect (d-p ex-piece2 PILE1) (dropdown-piece ex-piece2))
(check-expect (d-p ex-piece3 PILE2) (dropdown-piece ex-piece3))
(check-random (d-p ex-piece4 (list (make-brick 4 19 "red") (make-brick 4 18 "blue")))
              (piece-assignment (add1 (random 9))))
(define (d-p p pile)
  (cond
    [(piece-to-respawn? p pile) (piece-assignment (add1 (random 9)))]
    [else (dropdown-piece p)]))

;;piece-to-respawn?: Piece Pile -> Boolean
;;given a Piece and a Pile, determines if the piece needs to be respawned
(check-expect (piece-to-respawn? ex-piece8 PILE0) #t)
(check-expect (piece-to-respawn? ex-piece3 PILE3) #f)
(check-expect (piece-to-respawn? ex-piece2
                                 (list (make-brick 5 20 "green") (make-brick 5 19 "green"))) #t)
(define (piece-to-respawn? p pile)
  (or (all-piece-collide? (dropdown-piece p));;checks if falling piece collides with wall
      (brick-pile-collide?
       (piece-bricks (dropdown-piece p)) pile)))

;; piece-to-pile : Piece Pile -> Pile
;; Given a Pile and Piece, if the piece needs to respawn it will be added to the Pile
(check-expect (piece-to-pile ex-piece3 PILE3) PILE3)
(check-expect (piece-to-pile ex-piece2 (list (make-brick 5 20 "green") (make-brick 5 19 "green")))
              (append (list (make-brick 5 20 "green") (make-brick 5 19 "green"))
                      (piece-bricks ex-piece2)))
(define (piece-to-pile p pile)
  (if (piece-to-respawn? p pile) (pile-append p pile) pile))

;pile-append : Piece Pile -> Pile
;appends the ListOfBricks onto the existing pile
(check-expect (pile-append ex-piece1 PILE1) (append PILE1 (piece-bricks ex-piece1)))
(check-expect (pile-append ex-piece2 PILE0) (append PILE0 (piece-bricks ex-piece2)))
(define (pile-append p1 p2)
  (append p2 (piece-bricks p1)))

;; piece-assignment : Number -> Piece
;; given a Number [1, 7], assigns a Piece
(check-random (piece-assignment 1) (o-build (random 9)))
(check-random (piece-assignment 2) (i-build (random 10)))
(check-random (piece-assignment 3) (l-build (+ 1 (random 8))))
(check-random (piece-assignment 4) (j-build (+ 1 (random 8))))
(check-random (piece-assignment 5) (t-build (+ 1 (random 8))))
(check-random (piece-assignment 6) (z-build (+ 1 (random 8))))
(check-random (piece-assignment 7) (s-build (+ 1 (random 8))))
(check-random (piece-assignment 8) (single-build (random 10)))
(check-random (piece-assignment 9) (five-build (+ 2 (random 6))))
(define (piece-assignment n)
  (cond
    [(equal? 1 n) (o-build (random 9))]
    [(equal? 2 n) (i-build (random 10))]
    [(equal? 3 n) (l-build (+ 1 (random 8)))]
    [(equal? 4 n) (j-build (+ 1 (random 8)))]
    [(equal? 5 n) (t-build (+ 1 (random 8)))]
    [(equal? 6 n) (z-build (+ 1 (random 8)))]
    [(equal? 7 n) (s-build (+ 1 (random 8)))]
    [(equal? 8 n) (single-build (random 10))]
    [(equal? 9 n) (five-build (+ 2 (random 6)))]))



;;;;;;;;;; FUNCTIONS TO BUILD EACH INDIVIDUAL PIECE ;;;;;;;;;;;;;;;;;;;;;
;o-build : Number -> Piece
;; Given a number, builds the O piece at the x position corresponding to the number
(check-expect (o-build 3)  (make-piece (make-posn 3 19)
                                       (list (make-brick 3 19 "green")
                                             (make-brick (add1 3) 19 "green")
                                             (make-brick 3 18 "green")
                                             (make-brick (add1 3) 18 "green"))))

(check-expect (o-build 5)  (make-piece (make-posn 5 19)
                                       (list (make-brick 5 19 "green")
                                             (make-brick (add1 5) 19 "green")
                                             (make-brick 5 18 "green")
                                             (make-brick (add1 5) 18 "green"))))
(define (o-build n)
  (make-piece (make-posn n 19)
              (list (make-brick n 19 "green")
                    (make-brick (add1 n) 19 "green")
                    (make-brick n 18 "green")
                    (make-brick (add1 n) 18 "green"))))
             

;i-build : Number -> Piece
;; Given a number, builds the I piece at the x position corresponding to the number
(check-expect (i-build 4) (make-piece (make-posn 4 19)
                                      (list (make-brick 4 19 "blue")
                                            (make-brick 4 18 "blue")
                                            (make-brick 4 17 "blue")
                                            (make-brick 4 16 "blue"))))
(check-expect (i-build 6) (make-piece (make-posn 6 19)
                                      (list (make-brick 6 19 "blue")
                                            (make-brick 6 18 "blue")
                                            (make-brick 6 17 "blue")
                                            (make-brick 6 16 "blue"))))
(define (i-build n)
  (make-piece (make-posn n 19)
              (list (make-brick n 19 "blue")
                    (make-brick n 18 "blue")
                    (make-brick n 17 "blue")
                    (make-brick n 16 "blue"))))

;l-build : Number -> Piece
;; Given a number, builds the L piece at the x position corresponding to the number
(check-expect (l-build 1)   (make-piece (make-posn 1 19)
                                        (list (make-brick (sub1 1) 18 "purple")
                                              (make-brick 1 18 "purple")
                                              (make-brick (add1 1) 18 "purple")
                                              (make-brick (add1 1) 19 "purple"))))
(check-expect (l-build 18)   (make-piece (make-posn 18 19)
                                         (list (make-brick (sub1 18) 18 "purple")
                                               (make-brick 18 18 "purple")
                                               (make-brick (add1 18) 18 "purple")
                                               (make-brick (add1 18) 19 "purple"))))
(define (l-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (sub1 n) 18 "purple")
                    (make-brick n 18 "purple")
                    (make-brick (add1 n) 18 "purple")
                    (make-brick (add1 n) 19 "purple"))))


;j-build : Number -> Piece
;; Given a number, builds the J piece at the x position corresponding to the number
(check-expect (j-build 10)  (make-piece (make-posn 10 19)
                                        (list (make-brick 9 19 "turquoise")
                                              (make-brick 10 19 "turquoise")
                                              (make-brick 11 19 "turquoise")
                                              (make-brick 11 18 "turquoise"))))
(check-expect (j-build 15)  (make-piece (make-posn 15 19)
                                        (list (make-brick 14 19 "turquoise")
                                              (make-brick 15 19 "turquoise")
                                              (make-brick 16 19 "turquoise")
                                              (make-brick 16 18 "turquoise"))))
(define (j-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (sub1 n) 19 "turquoise")
                    (make-brick n 19 "turquoise")
                    (make-brick (add1 n) 19 "turquoise")
                    (make-brick (add1 n) 18 "turquoise"))))

;t-build : Number -> Piece
;; Given a number, builds the T piece at the x position corresponding to the number
(check-expect (t-build 4) (make-piece (make-posn 4 19)
                                      (list (make-brick (sub1 4) 19 "orange")
                                            (make-brick 4 19 "orange")
                                            (make-brick 4 18 "orange")
                                            (make-brick (add1 4) 19 "orange"))))
(check-expect (t-build 2) (make-piece (make-posn 2 19)
                                      (list (make-brick (sub1 2) 19 "orange")
                                            (make-brick 2 19 "orange")
                                            (make-brick 2 18 "orange")
                                            (make-brick (add1 2) 19 "orange"))))
(define (t-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (sub1 n) 19 "orange")
                    (make-brick n 19 "orange")
                    (make-brick n 18 "orange")
                    (make-brick (add1 n) 19 "orange"))))

;z-build : Number -> Piece
;; Given a number, builds the Z piece at the x position corresponding to the number
(check-expect (z-build 1)  (make-piece (make-posn 1 19)
                                       (list (make-brick (sub1 1) 19 "salmon")
                                             (make-brick 1 19 "salmon")
                                             (make-brick 1 18 "salmon")
                                             (make-brick (add1 1) 18 "salmon"))))
(check-expect (z-build 3)  (make-piece (make-posn 3 19)
                                       (list (make-brick (sub1 3) 19 "salmon")
                                             (make-brick 3 19 "salmon")
                                             (make-brick 3 18 "salmon")
                                             (make-brick (add1 3) 18 "salmon"))))
(define (z-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (sub1 n) 19 "salmon")
                    (make-brick n 19 "salmon")
                    (make-brick n 18 "salmon")
                    (make-brick (add1 n) 18 "salmon"))))

;s-build : Number -> Piece
;; Given a number, builds the S piece at the x position corresponding to the number
(check-expect (s-build 17)  (make-piece (make-posn 17 19)
                                        (list (make-brick (sub1 17) 18 "red")
                                              (make-brick 17 18 "red")
                                              (make-brick 17 19 "red")
                                              (make-brick (add1 17) 19 "red"))))
(check-expect (s-build 7)  (make-piece (make-posn 7 19)
                                       (list (make-brick (sub1 7) 18 "red")
                                             (make-brick 7 18 "red")
                                             (make-brick 7 19 "red")
                                             (make-brick (add1 7) 19 "red"))))
(define (s-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (sub1 n) 18 "red")
                    (make-brick n 18 "red")
                    (make-brick n 19 "red")
                    (make-brick (add1 n) 19 "red"))))

;single-build : Number -> Piece
;; Given a number, builds the 1 piece at the x position corresponding to the number
(check-expect (single-build 17)  (make-piece (make-posn 17 19)
                                             (list (make-brick 17 19 "magenta"))))
(check-expect (single-build 7)  (make-piece (make-posn 7 19)
                                            (list (make-brick 7 19 "magenta"))))
(define (single-build n)
  (make-piece (make-posn n 19)
              (list (make-brick n 19 "magenta"))))

;five-build : Number -> Piece
;; Given a number, builds the 5 piece at the x position corresponding to the number
(check-expect (five-build 17)  (make-piece (make-posn 17 19)
                                           (list (make-brick 15 19 "darkgreen")
                                                 (make-brick 16 19 "darkgreen")
                                                 (make-brick 17 19 "darkgreen")
                                                 (make-brick 18 19 "darkgreen")
                                                 (make-brick 19 19 "darkgreen"))))
(check-expect (five-build 7)  (make-piece (make-posn 7 19)
                                          (list (make-brick 5 19 "darkgreen")
                                                (make-brick 6 19 "darkgreen")
                                                (make-brick 7 19 "darkgreen")
                                                (make-brick 8 19 "darkgreen")
                                                (make-brick 9 19 "darkgreen"))))
(define (five-build n)
  (make-piece (make-posn n 19)
              (list (make-brick (- n 2) 19 "darkgreen")
                    (make-brick (sub1 n) 19 "darkgreen")
                    (make-brick n 19 "darkgreen")
                    (make-brick (add1 n) 19 "darkgreen")
                    (make-brick (+ n 2) 19 "darkgreen"))))

;;;;;;;;;;; DROPDOWN FUNCTIONS ;;;;;;;;;;;;;;

;; dropdown-piece : Piece -> Piece
;; Given a piece, lowers the y position of all blocks within the piece's list of blocks by 1.
(check-expect (dropdown-piece ex-piece1) (make-piece
                                          (make-posn 4 16)
                                          (list
                                           (make-brick 4 16 "green")
                                           (make-brick 5 16 "green")
                                           (make-brick 4 15 "green")
                                           (make-brick 5 15 "green"))))
(check-expect (dropdown-piece ex-piece2) (make-piece
                                          (make-posn 4 19)
                                          (list
                                           (make-brick 4 19 "blue")
                                           (make-brick 5 19 "blue")
                                           (make-brick 6 19 "blue")
                                           (make-brick 7 19 "blue"))))
(define (dropdown-piece p)
  (make-piece (make-posn (posn-x (piece-center p)) (- (posn-y (piece-center p)) 1))
              (map dropdown-brick (piece-bricks p))))
           

;; dropdown-brick : Brick -> Brick
;; Given a brick, lowers the y position of the brick.
(check-expect (dropdown-brick ex-brick1) (make-brick 8 6 "green"))
(check-expect (dropdown-brick ex-brick2) (make-brick 3 1 "orange"))
(define (dropdown-brick b)
  (make-brick (brick-x b) (- (brick-y b) 1) (brick-color b)))



;;;;;;;;;;;;;;;  DRAWING FUNCTIONS    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; piece->scene : Piece Image -> Scene
;; Given a piece, draws the piece onto the background.
(check-expect (piece->scene ex-piece3 BACKGROUND) (lob->scene (piece-bricks ex-piece3) BACKGROUND))
(define (piece->scene p bkg)
  (lob->scene (piece-bricks p) bkg))

;; lob->scene : LOB Image -> Scene
;; Draws a list of bricks onto the background.
(check-expect (lob->scene ex-lob3 BACKGROUND) (foldr brick->scene BACKGROUND ex-lob3))
(define (lob->scene lob bkg)
  (foldr brick->scene bkg lob))

;; brick->scene : Brick Image -> Scene
;; Given a brick, places it into the scene.
(check-expect (brick->scene ex-brick3 BACKGROUND)
              (place-image-on-grid
               (draw-brick ex-brick3) (brick-x ex-brick3) (brick-y ex-brick3) BACKGROUND))
(define (brick->scene b bkg)
  (place-image-on-grid (draw-brick b) (brick-x b) (brick-y b) bkg))

;; draw-brick : Brick -> Image
;; Given a brick, draws it.
(check-expect (draw-brick ex-brick3) (overlay (square GRIDSIZE-SQSIZE "outline" "black")
                                              (square GRIDSIZE-SQSIZE "solid"
                                                      (brick-color ex-brick3))))
(define (draw-brick b)
  (overlay (square GRIDSIZE-SQSIZE "outline" "black")
           (square GRIDSIZE-SQSIZE "solid" (brick-color b))))

;; place-image-on-grid : Image Number Number Image -> Image
;; Just like place-image, but takes x,y in grid coordinates
(check-expect (place-image-on-grid (draw-brick ex-brick3) 7 9 BACKGROUND)
              (place-image (draw-brick ex-brick3)
                           (+ (* GRIDSIZE-SQSIZE 7) (quotient GRIDSIZE-SQSIZE 2))
                           (- BOARD-HEIGHT/PIX
                              (+ (* GRIDSIZE-SQSIZE 9) (quotient GRIDSIZE-SQSIZE 2)))
                           BACKGROUND))
(define (place-image-on-grid img1 x y img2)
  (place-image img1
               (+ (* GRIDSIZE-SQSIZE x) (quotient GRIDSIZE-SQSIZE 2))
               (- BOARD-HEIGHT/PIX
                  (+ (* GRIDSIZE-SQSIZE y) (quotient GRIDSIZE-SQSIZE 2)))
               img2))

;;score->scene : Score -> Image
;;given a Score, draws the score as a block Image
(check-expect (score->scene 80) (overlay (text (string-append "Score: "
                                                              (number->string 80)) 24 "black")
                                         (empty-scene 150 60)))
(define (score->scene s)
  (overlay (text (string-append "Score: " (number->string s)) 24 "black")
           (empty-scene 150 60)))


;;;;;;;;;;;;;;;;;;;;; ROW REMOVAL FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;

;clear-rows : Pile -> Pile
;takes in a pile and returns a pile with the rows that were full cleared
(check-expect (clear-rows PILE5) (list
                                  (make-brick 0 3 "red")
                                  (make-brick 4 2 "blue")
                                  (make-brick 6 3 "yellow")
                                  (make-brick 8 5 "darkgreen")
                                  (make-brick 9 7 "magenta")))
(check-expect (clear-rows PILE6)
              (list
               (make-brick 0 3 "red")
               (make-brick 3 3 "red")
               (make-brick 4 1 "blue")
               (make-brick 6 3 "yellow")
               (make-brick 8 5 "darkgreen")
               (make-brick 0 4 "yellow")
               (make-brick 2 4 "yellow")
               (make-brick 1 4 "yellow")
               (make-brick 3 4 "yellow")
               (make-brick 4 4 "yellow")
               (make-brick 5 4 "yellow")
               (make-brick 6 4 "yellow")
               (make-brick 7 4 "yellow")
               (make-brick 8 4 "yellow")
               (make-brick 5 0 "magenta")
               (make-brick 3 0 "magenta")
               (make-brick 9 7 "magenta")))
(define (clear-rows pob)
  (foldl (lambda (x y) (drop-above x (row-remove y x))) pob (rows-to-clear pob)))

;rows-to-clear : Pile -> ListofNumbers
;takes in a pile and returns a list representing the lists that have to be cleared
(check-expect (rows-to-clear PILE3) '())
(check-expect (rows-to-clear PILE5) (list 4 1))
(define (rows-to-clear pob)
  (lon-maker pob 19))

;lon-maker : Pile Number -> ListOfNumbers
;takes in a pile and outputs a list of numbers representing rows to be cleared
(check-expect (lon-maker PILE3 19) '())
(check-expect (lon-maker PILE5 19) (list 4 1))
(define (lon-maker pob n)
  (cond
    [(negative? n) '()]
    [else (if (<= 10 (length (filter (lambda (x) (= (brick-y x) n)) pob)))
              (cons n (lon-maker pob (sub1 n)))
              (lon-maker pob (sub1 n)))]))

;drop-above : PileOfBricks Number -> PileOfBricks
;takes a pile and drops down any brick that has a y coordinate
;greater than the given number
(check-expect (drop-above 0 (row-remove PILE0 0)) (list
                                                   (make-brick 4 16 "red")
                                                   (make-brick 3 1 "darkgreen")))
(check-expect (drop-above 5 (row-remove PILE4 5)) (list
                                                   (make-brick 2 1 "green")
                                                   (make-brick 4 3 "blue")
                                                   (make-brick 8 6 "darkgreen")
                                                   (make-brick 9 8 "magenta")))
(define (drop-above n pob)
  (map (lambda (x) (if (> (brick-y x) n)
                       (dropdown-brick x)
                       x))
       pob))

;row-remove : PileOfBricks Number -> PileOfBricks
;takes in a pile of bricks and removes all within the given row number
(check-expect (row-remove PILE0 0) (list
                                    (make-brick 4 17 "red")
                                    (make-brick 3 2 "darkgreen")))
(check-expect (row-remove PILE4 5) (list
                                    (make-brick 2 1 "green")
                                    (make-brick 4 3 "blue")
                                    (make-brick 8 7 "darkgreen")
                                    (make-brick 9 9 "magenta")))
(define (row-remove pob n)
  (filter (lambda (z) (not (equal? (brick-y z) n))) pob))



;;;;;;;;;;;; ROTATING FUNCTIONS ;;;;;;;;;;;;;;

; world-rotate-ccw : World -> World
; Rotate the world 90 degrees counterclockwise around the center _c_
(check-expect (world-rotate-ccw ex-world1) (make-world
                                            (make-piece
                                             (make-posn 4 19)
                                             (list
                                              (make-brick 4 19 "purple")
                                              (make-brick 5 19 "purple")
                                              (make-brick 6 19 "purple")
                                              (make-brick 6 20 "purple")))
                                            (world-pile ex-world1)
                                            (world-score ex-world1)))
(check-expect (world-rotate-ccw ex-world2) (make-world
                                            (make-piece
                                             (make-posn 4 17)
                                             (list
                                              (make-brick 4 17 "green")
                                              (make-brick 4 18 "green")
                                              (make-brick 5 17 "green")
                                              (make-brick 5 18 "green")))
                                            (world-pile ex-world2)
                                            (world-score ex-world2)))
(define (world-rotate-ccw w)
  (make-world (p-r-ccw (world-piece w) (world-pile w)) (world-pile w) (world-score w)))

;p-r-ccw : Piece Pile -> Piece
;; rotates the piece counterclockwise if the piece is not colliding with any of the boundaries.
(check-expect (p-r-ccw ex-piece1 PILE0) ex-piece1)
(check-expect (p-r-ccw ex-piece2 PILE1) ex-piece2)
(check-expect (p-r-cw ex-piece3 PILE3)
              (make-piece
               (make-posn 4 19)
               (list
                (make-brick 4 19 "purple")
                (make-brick 5 19 "purple")
                (make-brick 6 19 "purple")
                (make-brick 6 20 "purple"))))
(define (p-r-ccw p pi)
  (cond
    [(or (piece-collide? (piece-rotate-ccw p))
         (brick-pile-collide? (piece-bricks (piece-rotate-ccw p)) pi)) p]
    [else (piece-rotate-ccw p)]))

; piece-rotate-ccw : Piece -> Piece
;; Rotate the list of bricks within the piece 90 degrees counterclockwise around the center _c_.
(check-expect (piece-rotate-ccw ex-piece1) (make-piece
                                            (make-posn 4 17)
                                            (list
                                             (make-brick 4 17 "green")
                                             (make-brick 4 18 "green")
                                             (make-brick 5 17 "green")
                                             (make-brick 5 18 "green"))))
(check-expect (piece-rotate-ccw ex-piece2) (make-piece
                                            (make-posn 4 20)
                                            (list
                                             (make-brick 4 20 "blue")
                                             (make-brick 4 21 "blue")
                                             (make-brick 4 22 "blue")
                                             (make-brick 4 23 "blue"))))
(define (piece-rotate-ccw p)
  (make-piece (piece-center p)
              (local
                [;;define the variable _center_ locally to be the piece center
                 (define center (piece-center p))
                 ;;brick-r-ccw: Brick -> Brick
                 ;;given a single Brick input, rotates the Brick based on the _center_
                 (define (brick-r-ccw brick)
                   (brick-rotate-ccw center brick))]
                (map brick-r-ccw (piece-bricks p)))))

; brick-rotate-ccw : Posn Brick -> Brick
; Rotate the brick _b_ 90 degrees counterclockwise around the center _c_.
(check-expect (brick-rotate-ccw (make-posn 5 5) ex-brick1) (make-brick 3 8 "green"))
(check-expect (brick-rotate-ccw (make-posn 5 5) ex-brick2) (make-brick 8 3 "orange"))
(define (brick-rotate-ccw c b)
  (make-brick (+ (posn-x c)
                 (- (posn-y c)
                    (brick-y b)))
              (+ (posn-y c)
                 (- (brick-x b)
                    (posn-x c)))
              (brick-color b)))



; world-rotate-cw : World -> World
; Rotate the world 90 degrees clockwise around the center _c_
(check-expect (world-rotate-cw ex-world1) (make-world
                                           (make-piece
                                            (make-posn 4 19)
                                            (list
                                             (make-brick 4 19 "purple")
                                             (make-brick 5 19 "purple")
                                             (make-brick 6 19 "purple")
                                             (make-brick 6 20 "purple")))
                                           (world-pile ex-world1)
                                           (world-score ex-world1)))
(check-expect (world-rotate-cw ex-world2) (make-world
                                           (make-piece
                                            (make-posn 4 17)
                                            (list
                                             (make-brick 4 17 "green")
                                             (make-brick 4 16 "green")
                                             (make-brick 3 17 "green")
                                             (make-brick 3 16 "green")))
                                           (world-pile ex-world2)
                                           (world-score ex-world2)))
(define (world-rotate-cw w)
  (make-world (p-r-cw (world-piece w) (world-pile w)) (world-pile w) (world-score w)))


;p-r-cw : Piece Pile -> Piece
;; rotates the piece clockwise if the piece is not colliding with the boundaries.
(check-expect (p-r-cw ex-piece3 PILE3)
              (make-piece
               (make-posn 4 19)
               (list
                (make-brick 4 19 "purple")
                (make-brick 5 19 "purple")
                (make-brick 6 19 "purple")
                (make-brick 6 20 "purple"))))
(check-expect (p-r-cw ex-piece2 PILE1) ex-piece2)
(define (p-r-cw p pi)
  (cond
    [(or (piece-collide? (piece-rotate-cw p))
         (brick-pile-collide? (piece-bricks (piece-rotate-cw p)) pi)) p]
    [else (piece-rotate-cw p)]))

; piece-rotate-cw : Piece -> Piece
;; Rotate the list of bricks within the piece 90 degrees clockwise around the center _c_.
(check-expect (piece-rotate-cw ex-piece1) (make-piece
                                           (make-posn 4 17)
                                           (list
                                            (make-brick 4 17 "green")
                                            (make-brick 4 16 "green")
                                            (make-brick 3 17 "green")
                                            (make-brick 3 16 "green"))))
(check-expect (piece-rotate-cw ex-piece2) (make-piece
                                           (make-posn 4 20)
                                           (list
                                            (make-brick 4 20 "blue")
                                            (make-brick 5 20 "blue")
                                            (make-brick 6 20 "blue")
                                            (make-brick 7 20 "blue"))))
(define (piece-rotate-cw p)
  (if (piece-collide? p)
      p
      (make-piece (piece-center p)
                  (local
                    [;;define the variable _center_ locally to be the piece center
                     (define center (piece-center p))
                     ;;brick-r-cw: Brick -> Brick
                     ;;given a single Brick input, rotates the Brick based on the _center_
                     (define (brick-r-cw brick)
                       (brick-rotate-cw center brick))]
                    (map brick-r-cw (piece-bricks p))))))

; brick-rotate-cw : Posn Brick -> Brick
; Rotate the brick _b_ 90 degrees clockwise around the center _c_.
(check-expect (brick-rotate-cw (make-posn 5 5) ex-brick1) (make-brick 7 2 "green"))
(check-expect (brick-rotate-cw (make-posn 5 5) ex-brick2) (make-brick 2 7 "orange"))
(define (brick-rotate-cw c b)
  (brick-rotate-ccw c (brick-rotate-ccw c (brick-rotate-ccw c b))))


;;;;;;;;;; SHIFTING FUNCTIONS ;;;;;;;;;;;

;; shift-world-left : World -> World
;; shifts the piece inside the World to the left.
(check-expect (shift-world-left ex-world2)
              (make-world
               (make-piece (make-posn 3 17) (map shift-brick-left (piece-bricks ex-piece1)))
               (world-pile ex-world2)
               (world-score ex-world2)))
(check-expect (shift-world-left ex-world3)
              (make-world
               (shift-p-l (world-piece ex-world3) (world-pile ex-world3))
               (world-pile ex-world3)
               (world-score ex-world3)))
(define (shift-world-left w)
  (make-world (shift-p-l (world-piece w) (world-pile w))
              (world-pile w)
              (world-score w)))

;; shift-p-l : Piece Pile -> Piece
;; shifts the bricks in the piece to the left only if the piece doesn't collide with the boundaries.
(check-expect (shift-p-l ex-piece8 PILE0) ex-piece8)
(check-expect (shift-p-l ex-piece1 PILE1) (make-piece (make-posn 3 17)
                                                      (map shift-brick-left
                                                           (piece-bricks ex-piece1))))
(define (shift-p-l p pi)
  (cond
    [(or (piece-collide? (shift-piece-left p))
         (brick-pile-collide? (piece-bricks (shift-piece-left p)) pi)) p]
    [else (shift-piece-left p)]))

;; shift-piece-left : Piece -> Piece
;; shifts the bricks in the piece to the left.
(check-expect (shift-piece-left ex-piece1) (make-piece (make-posn 3 17)
                                                       (map shift-brick-left
                                                            (piece-bricks ex-piece1))))
(check-expect (shift-piece-left ex-piece2) (make-piece (make-posn 3 20)
                                                       (map shift-brick-left
                                                            (piece-bricks ex-piece2))))
(check-expect (shift-piece-left ex-piece3) (make-piece (make-posn 3 19)
                                                       (map shift-brick-left
                                                            (piece-bricks ex-piece3))))
(define (shift-piece-left p)
  (make-piece (make-posn (- (posn-x (piece-center p)) 1) (posn-y (piece-center p)))
              (map shift-brick-left (piece-bricks p))))

;; shift-brick-left : Brick -> Brick
;; shifts a brick to the left.
(check-expect (shift-brick-left ex-brick1) (make-brick 7 7 "green"))
(check-expect (shift-brick-left ex-brick2) (make-brick 2 2 "orange"))
(check-expect (shift-brick-left ex-brick3) (make-brick 4 4 "red"))
(define (shift-brick-left b)
  (make-brick (- (brick-x b) 1) (brick-y b) (brick-color b)))


;; shift-world-right : World -> World
;; shifts a piece in the world to the right.
(check-expect (shift-world-right ex-world2)
              (make-world
               (make-piece (make-posn 5 17) (map shift-brick-right (piece-bricks ex-piece1)))
               (world-pile ex-world2)
               (world-score ex-world2)))
(check-expect (shift-world-right ex-world3)
              (make-world
               (shift-p-r (world-piece ex-world3) (world-pile ex-world3))
               (world-pile ex-world3)
               (world-score ex-world3)))
(define (shift-world-right w)
  (make-world (shift-p-r (world-piece w) (world-pile w))
              (world-pile w)
              (world-score w)))

;; shift-p-r : Piece Pile -> Piece
;; shifts a piece to the right only if the piece doesn't collide with the boundaries.
(check-expect (shift-p-r ex-piece8 PILE0) ex-piece8)
(check-expect (shift-p-r ex-piece1 PILE1) (make-piece (make-posn 5 17)
                                                      (map shift-brick-right
                                                           (piece-bricks ex-piece1))))
(define (shift-p-r p pi)
  (cond
    [(or (piece-collide? (shift-piece-right p))
         (brick-pile-collide? (piece-bricks (shift-piece-right p)) pi)) p]
    [else (shift-piece-right p)]))


;; shift-piece-right : Piece -> Piece
;; shifts a piece to the right.
(check-expect (shift-piece-right ex-piece1) (make-piece (make-posn 5 17)
                                                        (map shift-brick-right
                                                             (piece-bricks ex-piece1))))
(check-expect (shift-piece-right ex-piece2) (make-piece (make-posn 5 20)
                                                        (map shift-brick-right
                                                             (piece-bricks ex-piece2))))
(check-expect (shift-piece-right ex-piece3) (make-piece (make-posn 5 19)
                                                        (map shift-brick-right
                                                             (piece-bricks ex-piece3))))
(define (shift-piece-right p)
  (make-piece (make-posn (+ 1 (posn-x (piece-center p))) (posn-y (piece-center p)))
              (map shift-brick-right (piece-bricks p))))


;; shift-brick-right : Brick -> Brick
;; shifts a brick to the right.
(check-expect (shift-brick-right ex-brick1) (make-brick 9 7 "green"))
(check-expect (shift-brick-right ex-brick2) (make-brick 4 2 "orange"))
(check-expect (shift-brick-right ex-brick3) (make-brick 6 4 "red"))
(define (shift-brick-right b)
  (make-brick (+ (brick-x b) 1) (brick-y b) (brick-color b)))


;;;;;;;;;;;;;; COLLISION FUNCTIONS ;;;;;;;;;;;;;;;;;;;;

;; brick-pile-collide? [List-of Brick] Pile-> Boolean
;; Given a Piece's list of Bricks and the Pile, sees if the Brick collides with the Pile
(check-expect (brick-pile-collide? ex-lob1 PILE0) #t)
(check-expect (brick-pile-collide? ex-lob5 PILE3) #f)
(define (brick-pile-collide? p-bricks pile)
  (cond
    [(empty? (rest p-bricks)) (brick-brick-collide? (first p-bricks) pile)]
    [(cons? (rest p-bricks)) (or (brick-brick-collide? (first p-bricks) pile)
                                 (brick-pile-collide? (rest p-bricks) pile))]))


;; brick-brick-collide? : Brick [List-of Brick] -> Boolean
;; given a Brick
(check-expect (brick-brick-collide? ex-brick1 PILE2) #t)
(check-expect (brick-brick-collide? ex-brick2 PILE4) #f)
(define (brick-brick-collide? brick pile)
  (local [;;b-b-collide? : Brick -> Boolean
          ;;given a Brick from the Pile, compares the position to the original Piece Brick
          (define (b-b-collide? brick-pile)
            (and (= (brick-x brick) (brick-x brick-pile))
                 (= (brick-y brick) (brick-y brick-pile))))]
    (ormap b-b-collide? pile)))

;; piece-collide? : Piece -> Boolean
;; Does any part of the piece collide with a wall?
(check-expect (piece-collide? ex-piece8) #t)
(check-expect (piece-collide? ex-piece9) #f)
(define (piece-collide? p)
  (wall-collide? (piece-bricks p)))

;; wall-collide? : LOB -> Boolean
;; Does any part of the piece collide with a wall?
(check-expect (wall-collide? ex-lob1) #f)
(check-expect (wall-collide? ex-lob2) #t)
(define (wall-collide? lob)
  (ormap brick-collide? lob))

;; all-piece-collide? : Piece -> Boolean
;; Does any part of the piece collide with a wall?
(check-expect (all-piece-collide? ex-piece1) #f)
(check-expect (all-piece-collide? ex-piece2) #t)
(define (all-piece-collide? p)
  (all-wall-collide? (piece-bricks p)))

;; all-wall-collide? : LOB -> Boolean
;; Does any part of the list of bricks collide with a wall?
(check-expect (all-wall-collide? ex-lob1) #f)
(check-expect (all-wall-collide? ex-lob2) #t)
(define (all-wall-collide? lob)
  (ormap brick-collide? lob))

;; brick-collide? : Brick -> Boolean
;; does the brick cross outside of the playing screen?
(check-expect (brick-collide? (make-brick -4 -4 "red")) #t)
(check-expect (brick-collide? (make-brick 4 -4 "red")) #t)
(check-expect (brick-collide? (make-brick -4 4 "blue")) #t)
(check-expect (brick-collide? (make-brick 3 16 "green")) #f)
(define (brick-collide? b)
  (or (< (brick-x b) 0)
      (> (brick-x b) (- BOARD-WIDTH 1))
      (< (brick-y b) 0)
      (> (brick-y b) (- BOARD-HEIGHT 1))))

;;overflow? : World -> Boolean
;;given a World, determines if any of the pile has exceeded the board height
(check-expect (overflow? ex-world1) #f)
(check-expect (overflow? (make-world ex-piece1
                                     (list (make-brick 1 19 "red") (make-brick 1 20 "green"))
                                     SCORE0)) #t)
(check-expect (overflow? (make-world ex-piece1
                                     (list (make-brick 1 10 "red") (make-brick 1 11 "green"))
                                     SCORE1)) #f)
(define (overflow? w)
  (ormap (λ (b) (>= (brick-y b) (- BOARD-HEIGHT 1))) (world-pile w)))


;;;;;;;;;;;;;;;;;;;;;; DEBRIS FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;
;;note: the range for the probability and the size used for random were chosen so that
;;      the game could begin with no debris (0) or will all the rows filled (100) and so this
;;      implementation accounts for that and produces the desired results
;filter-bricks : Nat[0:19] Nat[0:100] -> Pile
;;given a Natural 0-19, representing the number of rows to fill
;;and a Natural 0-100, representing the probability of each cell being filled
;;returns the Pile with rows filled
(check-random (filter-bricks 10 50) (filter (λ (x) (< (random 100) 50)) (init-pile 10)))
(check-random (filter-bricks 0 79) (filter (λ (x) (< (random 100) 79)) (init-pile 0)))
(check-random (filter-bricks 19 100) (filter (λ (x) (< (random 100) 100)) (init-pile 19)))
(define (filter-bricks y prob)
  (filter (λ (x) (< (random 100) prob)) (init-pile y)))

;init-pile : Nat[0:19] -> Pile
;;given a Natural, 0-19, representing the number of rows to fill,
;;returns a Pile will all of the cells in the rows fully filled
(check-expect (init-pile 4) (append (row-pile 0)
                                    (row-pile 1)
                                    (row-pile 2)
                                    (row-pile 3)))
(check-expect (init-pile 0) (block-pile (blocklist-pile 0)))
(check-expect (init-pile 19) (block-pile (blocklist-pile 19)))
(define (init-pile y)
  (block-pile (blocklist-pile y)))

;block-pile : [List-of LOB] -> Pile
;;given a list of list of Bricks, appends the list to become a Pile
(check-expect (block-pile (list (row-pile 2)
                                (row-pile 1)
                                (row-pile 0))) (append (row-pile 2)
                                                       (row-pile 1)
                                                       (row-pile 0)))
(check-expect (block-pile (list (row-pile 4) (row-pile 3) (row-pile 2) (row-pile 1) (row-pile 0)))
              (foldr append '()
                     (list (row-pile 4) (row-pile 3) (row-pile 2) (row-pile 1) (row-pile 0))))
#;(define (block-pile lolob)
    (cond
      [(empty? lolob) '()]
      [(cons? lolob) (append (first lolob)
                             (block-pile (rest lolob)))]))
(define (block-pile lolob)
  (foldr append '() lolob))
                                   
;blocklist-pile : Nat[0:19] -> [List-of LOB]
;;given a Natural 0-19, representing the number of rows to fill,
;;returns a list of list of Bricks representing the list of rows fully filled
(check-expect (blocklist-pile 2) (list (row-pile 0)
                                       (row-pile 1)))
(check-expect (blocklist-pile 0) (build-list 0 row-pile))
(check-expect (blocklist-pile 19) (build-list 19 row-pile))
(define (blocklist-pile y)
  (build-list y row-pile))

;row-pile : Nat[0:19] -> LOB
;;given a Natrual 0-19, representing the number of rows to fill,
;;returns a list of Bricks that have that entire row filled with black Bricks
(check-expect (row-pile 4) (list (make-brick 0 4 "black")
                                 (make-brick 1 4 "black")
                                 (make-brick 2 4 "black")
                                 (make-brick 3 4 "black")
                                 (make-brick 4 4 "black")
                                 (make-brick 5 4 "black")
                                 (make-brick 6 4 "black")
                                 (make-brick 7 4 "black")
                                 (make-brick 8 4 "black")
                                 (make-brick 9 4 "black")))
(check-expect (row-pile 0) (list (make-brick 0 0 "black")
                                 (make-brick 1 0 "black")
                                 (make-brick 2 0 "black")
                                 (make-brick 3 0 "black")
                                 (make-brick 4 0 "black")
                                 (make-brick 5 0 "black")
                                 (make-brick 6 0 "black")
                                 (make-brick 7 0 "black")
                                 (make-brick 8 0 "black")
                                 (make-brick 9 0 "black")))
(check-expect (row-pile 19) (list (make-brick 0 19 "black")
                                  (make-brick 1 19 "black")
                                  (make-brick 2 19 "black")
                                  (make-brick 3 19 "black")
                                  (make-brick 4 19 "black")
                                  (make-brick 5 19 "black")
                                  (make-brick 6 19 "black")
                                  (make-brick 7 19 "black")
                                  (make-brick 8 19 "black")
                                  (make-brick 9 19 "black")))
(define (row-pile y)
  (list (make-brick 0 y "black")
        (make-brick 1 y "black")
        (make-brick 2 y "black")
        (make-brick 3 y "black")
        (make-brick 4 y "black")
        (make-brick 5 y "black")
        (make-brick 6 y "black")
        (make-brick 7 y "black")
        (make-brick 8 y "black")
        (make-brick 9 y "black")))



;;;;;;;;;;;;;;;;;;;;;;;; SCORE UPDATE FUNCTION ;;;;;;;;;;;;;;;;;;;;;;;;;
;;update-score : Score Pile -> Score
;;given a Score and a Pile, updates the Score depending on the number of rows to clear in the Pile
(check-expect (update-score 40 PILE5) 80)
(check-expect (update-score 30 PILE1) 30)
(define (update-score s p)
  (+ s (* 10 (sqr (length (rows-to-clear p))))))


;;;;;;;;;;;;;;;;;;;;; KEY HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key-handler : World Key-Event -> World
;; handle things when the user hits a key on the keyboard.
(check-expect (key-handler ex-world1 "left") (shift-world-left ex-world1))
(check-expect (key-handler ex-world1 "right") (shift-world-right ex-world1))
(check-expect (key-handler ex-world1 "s") (world-rotate-cw ex-world1))
(check-expect (key-handler ex-world1 "a") (world-rotate-ccw ex-world1))
(check-expect (key-handler ex-world1 "v") ex-world1)
(define (key-handler w ke)
  (cond
    [(key=? ke "left") (shift-world-left w)]
    [(key=? ke "right") (shift-world-right w)]
    [(key=? ke "s") (world-rotate-cw w)]
    [(key=? ke "a") (world-rotate-ccw w)]
    [else w]))

;;;;;;;;;;;;;;;;;;;;;;; BIG WORLD FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world->scene : World -> Scene
;; Given a world, draws the scene
(check-expect (world->scene ex-world1)
              (beside/align "top"
                            (piece->scene (world-piece ex-world1)
                                          (lob->scene (world-pile ex-world1) BACKGROUND))
                            (score->scene (world-score ex-world1))))
(check-expect (world->scene ex-world2)
              (beside/align "top"
                            (piece->scene (world-piece ex-world2)
                                          (lob->scene (world-pile ex-world2) BACKGROUND))
                            (score->scene (world-score ex-world2))))
(check-expect (world->scene ex-world3)
              (beside/align "top"
                            (piece->scene (world-piece ex-world3)
                                          (lob->scene (world-pile ex-world3) BACKGROUND))
                            (score->scene (world-score ex-world3))))
(define (world->scene w)
  (beside/align "top"
                (piece->scene (world-piece w) (lob->scene (world-pile w) BACKGROUND))
                (score->scene (world-score w))))

;; world->world : World -> World
;; Updates the world to accommodate the piece dropping down and the pile with it
(check-expect (world->world ex-world1)
              (make-world (d-p (world-piece ex-world1) (world-pile ex-world1))
                          (piece-to-pile (world-piece ex-world1) (world-pile ex-world1))
                          (update-score
                           (world-score ex-world1) (piece-to-pile (world-piece ex-world1)
                                                                  (world-pile ex-world1)))))
(check-expect (world->world ex-world2)
              (make-world (d-p (world-piece ex-world2) (world-pile ex-world2))
                          (piece-to-pile (world-piece ex-world2) (world-pile ex-world2))
                          (update-score
                           (world-score ex-world2) (piece-to-pile (world-piece ex-world2)
                                                                  (world-pile ex-world2)))))
(check-expect (world->world ex-world3)
              (make-world (d-p (world-piece ex-world3) (world-pile ex-world3))
                          (clear-rows (piece-to-pile (world-piece ex-world3) (world-pile ex-world3)))
                          (update-score
                           (world-score ex-world3) (piece-to-pile (world-piece ex-world3)
                                                                  (world-pile ex-world3)))))
(define (world->world w)
  (make-world (d-p (world-piece w) (world-pile w))
              (clear-rows (piece-to-pile (world-piece w) (world-pile w)))
              (update-score (world-score w) (piece-to-pile (world-piece w) (world-pile w)))))

;;tetris : Nat[0:19] Nat[0:100] -> Score
;;given a Natural in the range 0 to 19, representing the number of rows to fill
;;and a Natural in the range 0-100, representing the probability of each cell being filled,
;;creates the world state for the game and returns the Score when the game concludes
(define (tetris y prob)
  ;;this line sets the initial state to a (make-world piece pile)
  ;;with a piece randomly generated with piece-assignment and a random number 1-9
  ;;and the pile randomly generated with filter-bricks and the inputted _y_ and _prob_
  (world-score (big-bang (make-world (piece-assignment (add1 (random 8))) (filter-bricks y prob) 0)
                 (stop-when overflow?)
                 (to-draw world->scene)
                 (on-tick world->world TICK-RATE)
                 (on-key key-handler))))
