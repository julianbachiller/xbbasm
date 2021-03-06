;============================================================
;    some initialization and interrupt redirect setup
;============================================================

           sei                 ; set interrupt disable flag
            
           jsr init_screen     ; clear the screen
	   jsr init_text       ; write lines of text
           jsr sid_init	       ; init music routine now

           ldy #$7f            ; $7f = %01111111
           sty $dc0d           ; Turn off CIAs Timer interrupts
           sty $dd0d           ; Turn off CIAs Timer interrupts
           lda $dc0d           ; cancel all CIA-IRQs in queue/unprocessed
           lda $dd0d           ; cancel all CIA-IRQs in queue/unprocessed
          
           lda #$01            ; Set Interrupt Request Mask...
           sta $d01a           ; ...we want IRQ by Rasterbeam

           lda #[<b irq]       ; point IRQ Vector to our custom irq routine
           ldx #[>b irq] 
           sta $314            ; store in $314/$315
           stx $315   

           lda #$00            ; trigger first interrupt at row zero
           sta $d012

           lda $d011           ; Bit#0 of $d011 is basically...
           and #$7f            ; ...the 9th Bit for $d012
           sta $d011           ; we need to make sure it is set to zero 

           cli                 ; clear interrupt disable flag
same      jmp same             ; infinite loop


;============================================================
;    custom interrupt routine
;============================================================

irq        dec $d019        ; acknowledge IRQ

           jsr colwash      ; jump to color cycling routine
           jsr play_music   ; jump to play music routine


           jmp $ea81        ; return to kernel interrupt routine
