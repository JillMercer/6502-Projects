; Name:			Emily Van Horn
;			&Jill Mercer
; Course:		CpSc 370
; Instructor:		Dr. Conlon
; Date started:		March 17, 2015
; Last modification:	April 5, 2015
; Purpose of program:	contains all snake movements and accompanying
;			subroutines.
;			--up
;			--down
;			--left
;			--right
;			--check for win/lose
;			--check state

	.CR	6502	; Assemble 6502 language.
	.LI on,toff	; Listing on, no timings included.
	.TF newSnake.prg,BIN	; Object file and format

space 	= $20
box	= 230
home	= $7000		;Address of home on video screen
homel	= $00
homeh	= $70
scrend	= $73e8		;Address of bottom right of video screen
screndl	= $e8
screndh	= $73
rowsize	= 40		;Screen is 25 rows by 40 columns.
rowcnt	= 25
rbase	= $10		;base of the array of rows
temp	= $12		;a temporary pointer to screen locations
snPtr	= $14		;a pointer to the head of the snake
snHead	= $7400		;an array representing the snake
			;	each link requires 2 byte: 
			;	one for x coordinate and one for y0A
foodX	= $6038		;x coordinate of foodBit
foodY	= $6039		;y coordinate of foodBit
state	= $20		;what direction the snake should be moving
			; initiated to right

	.OR $0300
start	cld		;Set binary mode.
	jsr clear	
	jsr mkary
	
	lda #%0001	;initiate state
	sta state

	lda #25		;initiate foodBit TEMPORARY
	sta foodX
	lda #8
	sta foodY

	ldy foodY	;save a foodBit
	lda (rbase),Y	
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy foodX
	lda #box
	sta (temp),Y

	lda #$04	;initate first block
	sta snHead
	sta xVal
	lda #$08
	sta snHead+1
	sta yVal
	
	ldy yVal	;save an initial block
	lda (rbase),Y	
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy xVal
	lda #box
	sta (temp),Y

movelp	lda snHead+1	;pass x and y as parameters
	pha

	lda snHead
	pha
	
	ldx #$00	;check state for direction
	lda state,X
	cmp #%1000	;up
	beq upLnk
	cmp #%0100	;down
	beq dnLnk
	cmp #%0010	;left
	beq lftLnk
	cmp #%0001	;right
	beq rtLnk
	
upLnk	jsr up
	jmp update
dnLnk	jsr down
	jmp update
lftLnk	jsr left
	jmp update
rtLnk	jsr right

update	pla		;get updated xVal
	sta snHead

	pla		;get updated yVal
	sta snHead+1

	jsr slow
	
	jmp movelp
	brk

xVal	.DW $ff
yVal	.DW $ff

;************************
;*****CLEAR SCREEN*******
;************************
; code referenced from Linus Åkerlund 

clear	ldx #$00
	lda #space
clar	sta $7000,x	;store the space into first block and copy zero into the $7100 address
	sta $7100,x	;since the accumulator can only store 8 bits you must do each 100 increase seperate
	sta $7200,x 	;by decrementing 0 in hex it makes the value ff  and can cycle through all hex values
	dex
	bne clar	;will continue with program once x is 0

	ldx #$00	;load the zero place on the last line with a blank
	sta $7300,x	; store it
	ldx #$e8	;load x with the screen end amount
clear2	sta $7300,x	;store that
        dex
        bne clear2	;do this until x is equal to 0
	rts



; ********************* MKARY ***************************************************
; a subroutine to implement an array used to access memory locations in the
; video screen. Array rbase keeps track of the first location in each of the 25
; rows these locations can be saved to temp in order to access locations

mkary	lda #$00	;Set rbase to it's location
	sta rbase
	lda #$60
	sta rbase+1

	lda #$00	;Save locations of each row into array
	ldx #$70
	ldy #$00
add	sta (rbase),Y
	pha
	txa
	iny
	sta (rbase),Y
	tax
	pla
	clc
	adc #$28
	bcs carry
	iny
	cpy #50
	bne add
	jmp out
carry	inx
	iny
	cpy #50
	bne add
out	rts

; *********************** RIGHT ***********************************************
; moves snake one space to the right by incrementing its 'x' value and clearing
; the old space.
; checks the space ahead for foodBits and itself before moving
; receives an x value and a y value
; appears high-end first (entered low-end first)

right	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	pla		;get X value
	sta localX

	pla		;get Y value
	sta localY

	ldx localX	;increment x register
	inx

	; *********check for food bit**************
	cpx foodX
	bne good
	ldy localY
	cpy foodY
	bne good
	
	;inc score
	;inc length
	;jmp good

	jmp wallR
	
	; *********check for bites   **************

good	cpx #40
	beq wallR	

	; *********good to move********************
	ldy localY	;erase previous location
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	
	ldy localX
	lda #space
	sta (temp),Y

	inc localX	;update localX to its new location

	ldy localY	;print block
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #box
	sta (temp),Y

	lda localY	;return y value
	pha

	lda localX	;return x value
	pha
	
	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

wallR	ldx #0
rptR	lda mess,X	;pass mess to stack
	beq passR
	inx
	pha
	jmp rptR
passR	txa		;pass x to stack; saves the length of the 
	pha
	jsr printh
	brk

; *********************** LEFT ************************************************
; moves snake one space to the left by decrementing its 'x' value and clearing
; the old space.
; checks the space ahead for foodBits and itself before moving
; receives an x value and a y value
; appears high-end first (entered low-end first)

left	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	pla		;get X value
	sta localX

	pla		;get Y value
	sta localY

	ldx localX	;decrement x register
	dex

	; *********check for food bit**************
	; *********check for bites   **************

	cpx #0
	bmi wallL	

	; *********good to move********************
	ldy localY	;erase previous location
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #space
	sta (temp),Y

	dec localX	;update localX to its new location

	ldy localY	;print block
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #box
	sta (temp),Y

	lda localY	;return y value
	pha

	lda localX	;return x value
	pha
	
	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

wallL	ldx #0
rptL	lda mess,X	;pass mess to stack
	beq passL
	inx
	pha
	jmp rptL
passL	txa		;pass x to stack; saves the length of the 
	pha
	jsr printh
	brk

localX	.DW $ffff
localY	.DW $ffff
mess	.AS 'Game Over',#0

; *********************** UP **************************************************
; moves snake one space up by decrementing its 'y' value and clearing
; the old space.
; checks the space ahead for foodBits and itself before moving
; receives an x value and a y value
; appears high-end first (entered low-end first)

up	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	pla		;get X value
	sta localX

	pla		;get Y value
	sta localY

	ldx localY	;decrement x register twice (each space is actually
	dex		;two memory cells)
	dex

	; *********check for food bit**************
	; *********check for bites   **************

	cpx #0
	bmi wallU	

	; *********good to move********************
	ldy localY	;erase previous location
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #space
	sta (temp),Y

	dec localY	;update localX to its new location
	dec localY

	ldy localY	;print block
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #box
	sta (temp),Y

	lda localY	;return y value
	pha

	lda localX	;return x value
	pha
	
	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

wallU	ldx #0
rptU	lda mess,X	;pass mess to stack
	beq passU
	inx
	pha
	jmp rptU
passU	txa		;pass x to stack; saves the length of the 
	pha
	jsr printh
	brk

; *********************** DOWN ************************************************
; moves snake one space down by incrementing its 'y' value and clearing
; the old space.
; checks the space ahead for foodBits and itself before moving
; receives an x value and a y value
; appears high-end first (entered low-end first)

down	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	pla		;get X value
	sta localX

	pla		;get Y value
	sta localY

	ldx localY	;increment x register twice (each space is actually
	inx		;two memory cells)
	inx

	; *********check for food bit**************
	; *********check for bites   **************

	cpx #48
	beq wallD	

	; *********good to move********************
	ldy localY	;erase previous location
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #space
	sta (temp),Y

	inc localY	;update localX to its new location
	inc localY

	ldy localY	;print block
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	ldy localX
	lda #box
	sta (temp),Y

	lda localY	;return y value
	pha

	lda localX	;return x value
	pha
	
	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

wallD	ldx #0
rptD	lda mess,X	;pass mess to stack
	beq passD
	inx
	pha
	jmp rptD
passD	txa		;pass x to stack; saves the length of the 
	pha
	jsr printh
	brk

; ************************ PRINTH *********************************************
; prints a message passed from the stack in the lower left corner of the screen
; text appears backwards (is entered forwards)

printh	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	ldy #48		;save the address of the last row to temp
	lda (rbase),Y
	sta temp
	iny
	lda (rbase),Y
	sta temp+1
	
	pla		;retreive x
	tax
	dex

sv	pla		;save mssg
	sta mssg,X
	dex
	bne sv
	pla
	sta mssg,X

	ldy #0		;print mssg
	ldx #0
loop	lda mssg,X
	cmp #0
	beq done
	sta (temp),Y
	inx
	iny
	jmp loop

done	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

mssg	.BS 40


retAdd	.DW $ffff
score	.DW $00
length	.DW $01


; ************************ SLOW *********************************************

slow	pla		;Save return address
	sta retAdd
	pla 
	sta retAdd+1

	ldx #$00	;start here
	lda #$05
	sta counter,X
	inx
	lda #$00
	sta counter,X
	inx
	lda #$00
	sta counter,X

loop1	ldx #$02
	dec counter,X
	bne loop1

loop2	ldx #01
	dec counter,X
	beq loop3
	jmp loop1

loop3	ldx #00
	dec counter,X
	beq doneSl
	jmp loop1

doneSl	lda retAdd+1	;Push return address back into the stack
	pha
	lda retAdd
	pha
	rts

counter	.EQ $0100






	




