externdef sfRenderWindow_create:proc
externdef sfRenderWindow_isOpen:proc
externdef sfRenderWindow_destroy:proc
externdef sfRenderWindow_pollEvent:proc
externdef sfRenderWindow_close:proc
externdef sfRenderWindow_clear:proc
externdef sfRenderWindow_display:proc
externdef sfFont_createFromFile:proc
externdef sfText_create:proc
externdef sfText_setString:proc
externdef sfText_setFont:proc
externdef sfRenderWindow_drawText:proc
externdef sfRectangleShape_create:proc
externdef sfRectangleShape_setSize:proc
externdef sfRenderWindow_drawRectangleShape:proc
externdef sfRectangleShape_setPosition:proc
externdef sfRectangleShape_move:proc
externdef sfCircleShape_create:proc
externdef sfCircleShape_setRadius:proc
externdef sfRenderWindow_drawCircleShape:proc
externdef sfCircleShape_setPosition:proc
externdef sfCircleShape_move:proc
externdef sfWindow_setFramerateLimit:proc
externdef sfCircleShape_getPosition:proc
externdef sfRectangleShape_getPosition:proc

.data
    font dq 0;
    fontName db 'tuffy.ttf', 0

    displayText db 'Zepta!', 0
    text dq 0

    window dq 0
    windowName db 'Zepta!', 0

    leftPaddle dq 0
    rightPaddle dq 0

    circle dq 0

    upperBoarder REAL4 560.0
    lowerBoarder REAL4 0.0

    rightBoarder REAL4 800.0
    leftBoarder REAL4 -40.0

    inverterSpeed REAL4 -1.0


    color struct
        r BYTE ?
        g BYTE ?
        b BYTE ?
        a BYTE ?
    color ENDS

    modeStruct struct
        widths DWORD ?
        height DWORD ?
        bitsPerPixel DWORD ?
    modeStruct ENDS

    keyStruct struct
        events   DWORD ?
        keyCode DWORD ?
        scanCode DWORD ?
        alt DWORD ?
        control DWORD ?
        shift DWORD ?
        system DWORD ?
    keyStruct ENDS

    eventUnion union
        types DWORD ? ; 4 bytes for enum
        keys keyStruct <>
    eventUnion ENDS

    vector2D struct
        x REAL4 ?
        y REAL4 ?
    vector2D ENDS

    xSpeed REAL4 0.0 ;
    ySpeed REAL4 -6.0 ;
    ySpeedInv REAL4 6.0 ;

    xSize REAL4 20.0 ;
    ySize REAL4 60.0 ;

    leftPaddleX REAL4 10.0 ;
    leftPaddleY REAL4 270.0 ;

    rightPaddleX REAL4 770.0 ;
    rightPaddleY REAL4 270.0 ;

    circleRadius REAL4 20.0 ;

    backgroundColor color <0,0,0, 255>

    paddleSize vector2D <>
    paddleMoveUpVector vector2D <>
    paddleMoveDownVector vector2D <>
    circleMoveSpeedVector vector2D <1.0, 3.0>
    circlePosition vector2D <400.0, 300.0>

    paddleLeftPos vector2D <> 
    paddleRightPos vector2D <> 

    rightPaddleMovedDown db 0
    rightPaddleMovedUp db 0
    leftPaddleMovedDown db 0
    leftPaddleMovedUp db 0

    mode modeStruct <>
    eventU eventUnion <>



.code

main proc

push    rbx

; Create font from file
lea rcx, fontName
call sfFont_createFromFile
mov font, rax

; Create text struct
call sfText_create
mov text, rax

; Set text string

mov rcx, text
lea  rdx, displayText
call sfText_setString

; Set font for text

mov rcx, text
mov  rdx, font
call sfText_setFont

; Create left peddle
call sfRectangleShape_create
mov leftPaddle, rax

finit
fld xSize
fstp paddleSize.x
fld ySize
fstp paddleSize.y

mov rcx, leftPaddle
mov rdx, paddleSize
call sfRectangleShape_setSize

fld leftPaddleX
fstp paddleLeftPos.x
fld leftPaddleY
fstp paddleLeftPos.y
mov rcx, leftPaddle
mov rdx, paddleLeftPos
call sfRectangleShape_setPosition

; Create right peddle
call sfRectangleShape_create
mov rightPaddle, rax

fld xSize
fstp paddleSize.x
fld ySize
fstp paddleSize.y

mov rcx, rightPaddle
mov rdx, paddleSize
call sfRectangleShape_setSize

fld rightPaddleX
fstp paddleRightPos.x
fld rightPaddleY
fstp paddleRightPos.y
mov rcx, rightPaddle
mov rdx, paddleRightPos
call sfRectangleShape_setPosition

;Create move vectors

fld xSpeed
fstp paddleMoveUpVector.x
fld ySpeed
fstp paddleMoveUpVector.y

fld xSpeed
fstp paddleMoveDownVector.x
fld ySpeedInv
fstp paddleMoveDownVector.y

; Create circle

call sfCircleShape_create
mov circle, rax


mov rcx, circle
movss   xmm1,circleRadius
call sfCircleShape_setRadius

mov rcx, circle
mov rdx, circlePosition
call sfCircleShape_setPosition


; Populate the mode string, which defines window width, height etc
mov     mode.widths, 320h
mov     mode.height, 258h
mov     mode.bitsPerPixel, 20h
lea     rcx, mode               ; Param 1
lea     rdx, windowName         ; Param 2
mov     r8d, 6                  ; Param 3
xor     r9d, r9d                ; Param 4 NULL
call    sfRenderWindow_create
mov window, rax

mov rcx, window
mov rdx, 30
call sfWindow_setFramerateLimit

cmp rax, 0
je program_end                       ; Check if return value is NULL, then we branch to end

while_loop:
    
    mov rcx, window
    call sfRenderWindow_isOpen
    cmp rax, 0
    je program_end


inner_while_loop:
    mov rcx, window
    lea rdx, eventU
    call sfRenderWindow_pollEvent

    cmp rax, 0
    je out_inner_loop

    cmp eventU.types, 5
    jne closed_check

    cmp eventU.keys.keyCode, 22 ; key w
    jne key_s
    mov leftPaddleMovedUp, 1

key_s:

    cmp eventU.keys.keyCode, 18 ; key s
    jne key_up
    mov leftPaddleMovedDown, 1

key_up:

    cmp eventU.keys.keyCode, 73 ; key Up
    jne key_down
    mov rightPaddleMovedUp, 1

key_down:

    cmp eventU.keys.keyCode, 74 ; key Down
    jne closed_check
    mov rightPaddleMovedDown, 1

closed_check:
    cmp eventU.types, 0 ; sfEvtClosed
    jnz skip_close
    mov rcx, window
    call sfRenderWindow_close
    jmp program_end
skip_close:
    jmp inner_while_loop

out_inner_loop:
    
    cmp leftPaddleMovedUp, 1
    jne skip1
    mov rcx, leftPaddle
    mov rdx, paddleMoveUpVector
    call sfRectangleShape_move

    mov leftPaddleMovedUp, 0
skip1:


    cmp leftPaddleMovedDown, 1
    jne skip2
    mov rcx, leftPaddle
    mov rdx, paddleMoveDownVector
    call sfRectangleShape_move

    mov leftPaddleMovedDown, 0

skip2:

    cmp rightPaddleMovedUp, 1
    jne skip3
    mov rcx, rightPaddle
    mov rdx, paddleMoveUpVector
    call sfRectangleShape_move

    mov rightPaddleMovedUp, 0

skip3:

    cmp rightPaddleMovedDown, 1
    jne skip4
    mov rcx, rightPaddle
    mov rdx, paddleMoveDownVector
    call sfRectangleShape_move

    mov rightPaddleMovedDown, 0


skip4:

    mov rcx, window
    lea rdx, backgroundColor
    call sfRenderWindow_clear


    ;CIRCLE STUFF

    mov rcx, circle
    call sfCircleShape_getPosition;
    mov circlePosition, rax

    ; Detect if ball goes to lower screen
    fld circlePosition.y

    fld upperBoarder
    fcompp
    fnstsw ax
    sahf 

    ja skip5

    fld circleMoveSpeedVector.y
    fld inverterSpeed
    fmulp  st(1), st(0)
    fstp circleMoveSpeedVector.y


skip5:
;Detect if ball goes to upper screen
    fld lowerBoarder
    fld circlePosition.y
    fcompp
    fnstsw ax
    sahf 
    ja skip6

    fld circleMoveSpeedVector.y
    fld inverterSpeed
    fmulp  st(1), st(0)
    fstp circleMoveSpeedVector.y

skip6:
;Detect if ball goes to right screen
    fld circlePosition.x
    fld rightBoarder
    fcompp
    fnstsw ax
    sahf 
    ja skip7

    jmp program_end ; quit game
skip7:
;Detect if ball goes to right screen
    fld leftBoarder
    fld circlePosition.x
    fcompp
    fnstsw ax
    sahf 
    ja skip8

    jmp program_end ; quit game

skip8:
;Detect if ball hits right paddle

    mov rcx, leftPaddle
    call sfRectangleShape_getPosition
    mov paddleLeftPos, rax

    fld paddleLeftPos.x
    fld circlePosition.x
    fcompp
    fnstsw ax
    sahf 
    ja skip9
    
    fld paddleLeftPos.y
    fld circlePosition.y
    fcompp
    fnstsw ax
    sahf 
    ja skip9

    fld circleMoveSpeedVector.x
    fld inverterSpeed
    fmulp  st(1), st(0)
    fstp circleMoveSpeedVector.x

skip9:
;Detect if ball 

    mov rcx, rightPaddle
    call sfRectangleShape_getPosition
    mov paddleRightPos, rax

    fld circlePosition.x
    fld paddleRightPos.x
    fcompp
    fnstsw ax
    sahf 
    ja skip10

   fld circlePosition.y
   fld paddleRightPos.y

    fcompp
    fnstsw ax
    sahf 
    ja skip10

    fld circleMoveSpeedVector.x
    fld inverterSpeed
    fmulp  st(1), st(0)
    fstp circleMoveSpeedVector.x

skip10:
    mov rcx, circle
    mov rdx, circleMoveSpeedVector
    call sfCircleShape_move


    ;CIRCLE STUFF END


    mov rcx, window
    mov rdx, circle
    mov r8d, 0
    call sfRenderWindow_drawCircleShape

    mov rcx, window
    mov rdx, text
    mov r8d, 0
    call sfRenderWindow_drawText

    mov rcx, window
    mov rdx, leftPaddle
    mov r8d, 0
    call sfRenderWindow_drawRectangleShape

    mov rcx, window
    mov rdx, rightPaddle
    mov r8d, 0
    call sfRenderWindow_drawRectangleShape

    mov rcx, window
    call sfRenderWindow_display
    jmp while_loop


program_end:

    mov rcx, window
    call sfRenderWindow_destroy
    pop    rbx

    xor rax, rax
    ret
main endp

end