; Name:			Jill Mercer
; Course:		CpSc 370
; Instructor:		Dr. Conlon
; Date started:		February 3, 2015
; Last modification:	February 11, 2015
; Purpose of program:	Create elementary program that produces some video output SMILEY

	.CR	6502	; Assemble 6502 language.
	.LI on,toff	; Listing on, no timings included.
	.TF Project.prg,BIN	; Object file and format


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

	.OR $0300
start	cld		;Set binary mode.

	lda #$20
	sta $7150	;nose
	lda #$20
	sta $708b	;eye
	lda #$20
	sta $7085	;eye
	lda #$20
	sta $7155	;right mouth
	lda #$20
	sta $714b	;left mouth	
	lda #$20	
	sta $719b	;left mouth	
	lda #$20	
	sta $719c	
	lda #$20	
	sta $719d	
	lda #$20	
	sta $719e	
	lda #$20	
	sta $719f	
	lda #$20
	sta $71a0	
	lda #$20	
	sta $71a1	
	lda #$20	
	sta $71a2	
	lda #$20	
	sta $71a3	
	lda #$20	
	sta $71a4	
	lda #$20
	sta $71a5
	lda #$20	
	sta $7173	;left mouth
	lda #$20	
	sta $717d	;right mouth
	brk
