[org 0x0100]

    jmp start

        oldisr: dd 0
        oldisr2: dd 0
        border: dw 0x4020
        snake: times 240 dw 0
        screenLocations: times 240 dw 0
        snakeLength: dw 20
        originalSnakeLength: dw 20

        movedRight: dw 1 ;because starting position is where snake is pointing towards right
        movedLeft: dw 0
        movedUp: dw 0
        movedDown: dw 0

        tickcount: dw 0
        tickcount2: dw 0
        tickcount3: dw 0
        tickcount4: dw 0
        speedIncreaseInterval: dw 1000


        life: db 3
        lifeMsg: db 'Life Points = ',0
        food: dw 1
        speed: dw 2

        gameEnd: dw 0
        gameWon: dw 0

        seconds: dw 59
        minutes: dw 4
        timeMsg: db 'Time left = ',0

        scoreMsg: db 'Score = '
        score: dw 0

        gameOverMsg: db 'game is joever bro', 0
        gameWinMsg: db 'WINNER WINNER CHICKEN DINNER', 0

        goodFood: dw 0x0E4F
        badFood: dw 0x024F
        healthyFood: dw 0x074F

        stage1: dw 0
        alreadyOnStage1: dw 0
        stage1Activated: dw 0
        stage2: dw 0
        alreadyOnStage2: dw 0
        stage2Activated: dw 0
        stage3: dw 0
        alreadyOnStage3: dw 0
        stage3Activated: dw 0


        rnd: dw 0

        foodEaten: dw 0
        badFoodEaten: dw 0
        healthyFoodEaten: dw 0

        restartPromptMsg: db 'Press R to Restart or E to Exit', 0





        stringLength:
            push bp
            mov bp,sp
            push cx
            push di
            push es

            push cs
            pop es

            mov di, [bp + 4]
            mov cx, 0xffff
            xor al, al
            repne scasb
            mov ax, 0xffff
            sub ax, cx
            dec ax

            pop es
            pop di
            pop cx
            pop bp
            ret 2





        printString:
            push bp
            mov bp, sp
            pusha

            push cs
            pop ds

            mov ax, 0xb800
            mov es, ax

            mov ax, [bp + 4]
            push ax
            call stringLength

            ;now ax has length of string

            mov cx, ax
            mov si, [bp + 4]
            mov di, [bp + 6]
        printLoop:
            lodsb
            mov ah, 0x07
            stosw
            loop printLoop

            popa
            pop bp
            ret 4






        printNumber:
            push bp
            mov bp, sp
            pusha

            mov ax,0xb800
            mov es,ax

            mov ax, [bp+4]
            mov bx,10
            mov cx, 0

        nextDigit:
            mov dx, 0
            div bx
            add dl, 0x30
            push dx
            inc cx
            cmp ax, 0
            jnz nextDigit

            mov di, [bp+6]

        nextPos:
            pop dx
            mov ax,dx
            mov ah, 0x07
            stosw
            loop nextPos

            popa
            pop bp
            ret 4








        clearScreen:
            pusha
            mov ax,0xb800
            mov es,ax
            xor di,di
            mov cx,2000
            mov ax, 0x0720
            rep stosw
            popa
            ret








        makeBorder:
            pusha
            mov ax, 0xb800
            mov es, ax

            cmp word[cs:gameEnd], 1
            je deathBorder


            mov ax, [cs:border]
            jmp normalBorder

            deathBorder:
                mov ax, 0x5020

            normalBorder:
                ;first row
                mov di, 160
                mov cx, 80
                rep stosw

                ;last row
                mov di, 3840
                mov cx, 80
                rep stosw

                ;left col
                mov di, 160
                mov cx, 25
            l1:
                mov [es:di], ax
                add di,160
                loop l1

                ;left col 2
                mov di, 162
                mov cx, 25
            l2:
                mov [es:di], ax
                add di,160
                loop l2

                ;right col
                mov di, 318
                mov cx, 25
            l3:
                mov [es:di], ax
                add di,160
                loop l3

                ;right col 2
                mov di, 316
                mov cx, 25
            l4:
                mov [es:di], ax
                add di,160
                loop l4

                cmp word [cs:stage1Activated], 1
                je checkStage2
                cmp word [cs:stage1], 1
                jne checkStage2
                call enterStage1

            checkStage2:
                cmp word [cs:stage2Activated], 1
                je checkStage3
                cmp word [cs:stage2], 1
                jne checkStage3
                call enterStage2

            checkStage3:
                cmp word [cs:stage3Activated], 1
                je exitBorder
                cmp word [cs:stage3], 1
                jne exitBorder
                call enterStage3

            exitBorder:
                popa
                ret







        enterStage1:
            pusha

            mov word [cs:stage1Activated], 1


            call clearScreen
            call makeBorder

            mov ax, 0xb800
            mov es, ax
            mov di, 2890
            mov ax, [cs:badFood]
            stosw
            mov di, 378
            mov ax, [cs:healthyFood]
            stosw




            mov ax, [cs:border]

            mov di, 980
            mov cx, 60
            rep stosw

            mov di, 1100
            mov cx, 14
            l5:
                mov [es:di], ax
                add di, 160
                loop l5

                mov di, 1098
                mov cx, 13
            l6:
                mov [es:di], ax
                add di, 160
                loop l6	

                mov cx, 60
                std
                rep stosw

                popa
                ret










        enterStage2:
            pusha

            mov word [cs:stage2Activated], 1

            call clearScreen
            call makeBorder

            mov ax, 0xb800
            mov es, ax
            mov di, 2890
            mov ax, [cs:badFood]
            stosw
            mov di, 378
            mov ax, [cs:healthyFood]
            stosw



            mov ax, 0xb800
            mov es, ax
            mov ax,[cs:border]

            ;left vertical bars
            mov di, 980
            mov cx, 14
            l7:
                mov [es:di], ax
                add di, 160
                loop l7

                mov di, 982
                mov cx, 14
            l8:
                mov [es:di], ax
                add di, 160
                loop l8	


                ;right vertical bars
                mov di, 1098
                mov cx, 14
            l9:
                mov [es:di], ax
                add di, 160
                loop l9

                mov di, 1100
                mov cx, 14
            l10:
                mov [es:di], ax
                add di, 160
                loop l10

                push di

                ;top horizontal
                mov di, 982
                mov cx, 30
                rep stosw

                ;bottom horizontal
                pop di
                mov cx, 30
                std
                rep stosw

                popa
                ret


        














        enterStage3:
            pusha

            mov word [cs:stage3Activated], 1

            call clearScreen
            call makeBorder


            mov ax, 0xb800
            mov es, ax

            mov ax, 0xb800
            mov es, ax
            mov di, 2890
            mov ax, [cs:badFood]
            stosw
            mov di, 378
            mov ax, [cs:healthyFood]

            mov ax, [cs:border]

            mov di, 800
            mov cx, 60
            rep stosw

            mov di,1758
            mov cx, 60
            std
            rep stosw

            mov di,2240
            mov cx, 60
            cld
            rep stosw

            mov di, 3358
            mov cx, 60
            std
            rep stosw


            popa
            ret







        initializeSnake:
            pusha

            mov ax, [originalSnakeLength]
            mov [snakeLength], ax
            mov cx, [snakeLength]
            dec cx
            mov al, '*'
            mov ah, 0xE0
            xor bx,bx

            initializeLoop:
                mov [snake + bx], ax
                add bx, 2
                loop initializeLoop

                mov al, '@'
                mov [snake + bx], ax

                popa
                ret








        displaySnake:
            pusha

            mov si, snake
            mov ax,0xb800
            mov es, ax
            mov di, 1950
            mov cx, [snakeLength]

            xor bx,bx

        printSnake:
            mov [screenLocations+bx],di
            add bx, 2
            lodsw
            stosw
            loop printSnake

            popa
            ret 







        getRand:
            pusha

            mov ax, 0xb800	
            mov es, ax

            mov al,[cs:tickcount4]
            mov bl,0xF7
            mul bl
            mov bx,0x2541
            add ax,bx
            mov bx,0x09d8
            mov dx,0

            getRand1:
            cmp ax,bx
            jb endRand
            div bx
            mov ax,dx
            mov dx,0
            jmp getRand1

            endRand:
            add ax,640
            shr ax,1
            shl ax,1
            mov di, ax

            ;to check random location isn't border
            cmp word [es:di], 0x4020    ; Changed from 0x2020 to 0x4020 (red border)
            je getRand1

            ;following checks are applied so that food doesn't appear over another food

            ;to check random location isn't goodFood
            mov si, [cs:food]
            cmp word [es:di], si
            je getRand

            ;to check random location isn't badFood
            mov si, [cs:badFood]
            cmp word [es:di], si
            je getRand1

            ;to check random location isn't healthyFood
            mov si, [cs:healthyFood]
            cmp word [es:di], si
            je getRand1

            mov [cs:rnd],ax




            mov word [cs:tickcount4], 0

            popa
            ret








        displayFood:
            pusha
            mov ax, 0xb800
            mov es, ax

            ;printing good food at fixed location
            call getRand
            mov di, [cs:rnd]
            mov ax, [cs:goodFood]
            stosw
            popa
            ret







        displayHealthyFood:
            pusha
            mov ax, 0xb800
            mov es, ax

            ;printing healthy food at fixed location
            call getRand
            mov di, [cs:rnd]
            mov ax, [cs:healthyFood]
            mov [es:di], ax

            popa
            ret







        displayBadFood:
            pusha
            mov ax, 0xb800
            mov es, ax

            ;printing healthy food at fixed location
            call getRand
            mov di, [cs:rnd]
            mov ax, [cs:badFood]
            mov [es:di], ax

            popa
            ret








        lunch:
            pusha
            mov ax, 0xb800
            mov es, ax


            ;we have to add 4 asterisk to snake at tail. For that we need to go at the head of snake in 'index array' and move it 4 spaces ahead.
            ;then do the same for previous indexes.

            ;updating score
            add word [cs:score], 10

            cmp word [cs:snakeLength], 240
            je yo
            mov cx, [cs:snakeLength]
            mov bx, cx
            shl bx,1
            sub bx, 2
            yo:
                jmp exitLunch
            shiftingSnake:
                mov si, [cs:screenLocations + bx] ;si poiting to head.
                mov [cs:screenLocations + bx + 8], si ;8 is added because we have to move 4 words (8 bytes) ahead.
                mov si, [cs:snake + bx]
                mov [cs:snake + bx + 8], si
                sub bx, 2
                loop shiftingSnake
                mov di, [cs:screenLocations]
                ;di now points to tail of snake
                mov dx, [cs:screenLocations + 2] ;second last character's screen location stored
                sub di, dx
            compare1:
                cmp di, 160
                jne compare2
                mov di, [cs:screenLocations]
                add di, 160
                jmp carryOn
            compare2:
                cmp di, -160
                jne compare3
                mov di, [cs:screenLocations]
                sub di, 160
                jmp carryOn
            compare3:
                cmp di, 2
                jne compare4
                mov di, [cs:screenLocations]
                add di, 2
            compare4:
                cmp di, -2
                mov di, [cs:screenLocations]
                sub di, 2
                jmp carryOn
            carryOn:
                mov bx, 6
                mov al, '*'
                mov ah, 0xE0        ; Changed snake growth segments to golden (0xE0)
                mov cx, 4
            growingSnake:
                mov [es:di], ax
                mov [cs:screenLocations + bx], di
                mov [cs:snake + bx], ax
                sub bx, 2
                loop growingSnake
                add word[cs:snakeLength], 4
            exitLunch:
                popa
                ret






        collision:
            pusha

            dec byte [cs:life]

            cmp word [cs:stage1], 1
            jne c2
            inc byte [cs:life]

            c2:
                cmp word [cs:stage2], 1
                jne c3
                inc byte [cs:life]

            c3:
                cmp word [cs:stage3], 1
                jne pass
                inc byte [cs:life]


            pass:
                push cs
                pop ds ;ds now points to cs. This is done becasuse the following functions don't use [cs: ...] syntax. 
                        ;the functions are being called from within an interrupt.


                ;now to remove the snake from old location
                mov cx, [cs:snakeLength]
                mov bx, cx
                shl bx, 1
                sub bx, 2
                mov di, [cs:screenLocations + bx]
                mov ax, 0x0720

            collisionLoop:
                mov [es:di], ax
                sub bx, 2
                mov di, [cs:screenLocations + bx]
                loop collisionLoop


                mov word [cs:movedRight], 1
                mov word [cs:movedLeft], 0
                mov word [cs:movedUp], 0
                mov word [cs:movedDown], 0



                call initializeSnake
                call displaySnake
                call makeBorder

                popa
                ret











        startMovingRight:
            pusha
            mov ax,0xb800
            mov es, ax
            mov ds, ax

            cmp word [cs:foodEaten], 1
            jne descendr1
            call displayFood
            mov word [cs:foodEaten], 0

            descendr1:
                cmp word [cs:badFoodEaten], 1
                jne descendr2
                call displayBadFood
                mov word [cs:badFoodEaten], 0

            descendr2:
                cmp word [cs:healthyFoodEaten], 1
                jne descendr3
                call displayHealthyFood
                mov word [cs:healthyFoodEaten], 0

            descendr3:
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2 ;bx containing index where 

                mov si, [cs:screenLocations + bx] ;si poiting to head
                mov di, si
                add di,2 ;now di points to right empty screen location after head

                ;checking collision with boundary
                mov ax, [es:di]
                cmp ax, [cs:border] 
                jne rightSelfCollision
                call collision
                jmp exitRight

            rightSelfCollision:
                cmp al, '*'
                jne foundFood1
                call collision
                jmp exitRight

            foundFood1:
                cmp ax, [cs:goodFood]
                jne foundBadFood1
                mov word [cs:foodEaten], 1
                call lunch
                jmp goRight

            foundBadFood1:
                cmp ax, [cs:badFood]
                jne foundHealthyFood1
                mov word [cs:badFoodEaten], 1
                dec byte [cs:life]
                jmp goRight

            foundHealthyFood1:
                cmp ax, [cs:healthyFood]
                jne goRight
                mov word [cs:healthyFoodEaten], 1
                inc byte [cs:life]

            goRight:
                mov cx,[cs:snakeLength]

                ;doing this again because length updates if food has been caught
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2 ;bx containing index where

            rightMove:
                mov ax, [cs:snake + bx]
                mov [es:di], ax
                mov ax, di
                mov di, [cs:screenLocations + bx]
                mov [cs:screenLocations + bx], ax
                sub bx,2
                loop rightMove

                mov ax,0x0720
                stosw

            exitRight:
                popa
                ret








        startMovingLeft:
            pusha
            mov ax,0xb800
            mov es, ax
            mov ds, ax

            ;if food eaten then display at new random location
            cmp word [cs:foodEaten], 1
            jne descendl1
            call displayFood
            mov word [cs:foodEaten], 0

            descendl1:
                cmp word [cs:badFoodEaten], 1
                jne descendl2
                call displayBadFood
                mov word [cs:badFoodEaten], 0

            descendl2:
                cmp word [cs:healthyFoodEaten], 1
                jne descendl3
                call displayHealthyFood
                mov word [cs:healthyFoodEaten], 0

            descendl3:
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2
                mov si, [cs:screenLocations + bx] ;si poiting to head

                mov di, si
                sub di,2 ;now di points to left empty screen location after head

                mov ax, [es:di]
                cmp ax, [cs:border] 
                jne leftSelfCollision
                call collision
                jmp exitLeft

            leftSelfCollision:
                cmp al, '*'
                jne foundFood2
                call collision
                jmp exitLeft

            foundFood2:
                cmp ax, [cs:goodFood]
                jne foundBadFood2
                mov word [cs:foodEaten], 1
                call lunch
                jmp goLeft

            foundBadFood2:
                cmp ax, [cs:badFood]
                jne foundHealthyFood2
                mov word [cs:badFoodEaten], 1
                dec byte [cs:life]
                jmp goLeft

            foundHealthyFood2:
                cmp ax, [cs:healthyFood]
                jne goLeft
                mov word [cs:healthyFoodEaten], 1
                inc byte [cs:life]

            goLeft:
                mov cx,[cs:snakeLength]

                ;doing this again because length updates if food has been caught
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2 ;bx containing index where

            leftMove:
                mov ax, [cs:snake + bx]
                mov [es:di], ax
                mov ax, di
                mov di, [cs:screenLocations + bx]
                mov [cs:screenLocations + bx], ax
                sub bx,2
                loop leftMove

                mov ax,0x0720
                stosw

            exitLeft:
                popa
                ret










        startMovingUp:
            pusha
            mov ax,0xb800
            mov es, ax
            mov ds, ax

            ;if food eaten then display at new random location
            cmp word [cs:foodEaten], 1
            jne descendu1
            call displayFood
            mov word [cs:foodEaten], 0

            descendu1:
                cmp word [cs:badFoodEaten], 1
                jne descendu2
                call displayBadFood
                mov word [cs:badFoodEaten], 0

            descendu2:
                cmp word [cs:healthyFoodEaten], 1
                jne descendu3
                call displayHealthyFood
                mov word [cs:healthyFoodEaten], 0

            descendu3:
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2
                mov si, [cs:screenLocations + bx] ;si poiting to head

                mov di, si
                sub di,160 ;now di points to right empty screen location after head

                mov ax, [es:di]
                cmp ax, [cs:border] 
                jne upSelfCollision
                call collision
                jmp exitUp

            upSelfCollision:
                cmp al, '*'
                jne foundFood3
                call collision
                jmp exitUp

            foundFood3:
                cmp ax, [cs:goodFood]
                jne foundBadFood3
                mov word [cs:foodEaten], 1
                call lunch
                jmp goUp

            foundBadFood3:
                cmp ax, [cs:badFood]
                jne foundHealthyFood3
                mov word [cs:badFoodEaten], 1
                dec byte [cs:life]
                jmp goUp

            foundHealthyFood3:
                cmp ax, [cs:healthyFood]
                jne goUp
                mov word [cs:healthyFoodEaten], 1
                inc byte [cs:life]


            goUp:
                mov cx,[cs:snakeLength]

                ;doing this again because length updates if food has been caught
                mov bx, [cs:snakeLength]
                shl bx,1
                sub bx, 2 ;bx containing index where

            upMove:
                mov ax, [cs:snake + bx]
                mov [es:di], ax
                mov ax, di
                mov di, [cs:screenLocations + bx]
                mov [cs:screenLocations + bx], ax
                sub bx,2
                loop upMove

                mov ax,0x0720
                stosw

            exitUp:
                popa
                ret










            startMovingDown:
                pusha
                mov ax,0xb800
                mov es, ax
                mov ds, ax

                ;if food eaten then display at new random location
                cmp word [cs:foodEaten], 1
                jne descendd1
                call displayFood
                mov word [cs:foodEaten], 0

                descendd1:
                    cmp word [cs:badFoodEaten], 1
                    jne descendd2
                    call displayBadFood
                    mov word [cs:badFoodEaten], 0

                descendd2:
                    cmp word [cs:healthyFoodEaten], 1
                    jne descendd3
                    call displayHealthyFood
                    mov word [cs:healthyFoodEaten], 0

                descendd3:
                    mov bx, [cs:snakeLength]
                    shl bx,1
                    sub bx, 2
                    mov si, [cs:screenLocations + bx] ;si poiting to head

                    mov di, si
                    add di,160 ;now di points to right empty screen location after head

                    mov ax, [es:di]
                    cmp ax, [cs:border] 
                    jne downSelfCollision
                    call collision
                    jmp exitDown

                downSelfCollision:
                    cmp al, '*'
                    jne foundFood4
                    call collision
                    jmp exitDown

                foundFood4:
                    cmp ax, [cs:goodFood]
                    jne foundBadFood4
                    mov word [cs:foodEaten], 1
                    call lunch
                    jmp goDown

                foundBadFood4:
                    cmp ax, [cs:badFood]
                    jne foundHealthyFood4
                    mov word [cs:badFoodEaten], 1
                    dec byte [cs:life]
                    jmp goDown

                foundHealthyFood4:
                    cmp ax, [cs:healthyFood]
                    jne goDown
                    mov word [cs:healthyFoodEaten], 1
                    inc byte [cs:life]

                goDown:
                    mov cx,[cs:snakeLength]

                    ;doing this again because length updates if food has been caught
                    mov bx, [cs:snakeLength]
                    shl bx,1
                    sub bx, 2 ;bx containing index where

                downMove:
                    mov ax, [cs:snake + bx]
                    mov [es:di], ax
                    mov ax, di
                    mov di, [cs:screenLocations + bx]
                    mov [cs:screenLocations + bx], ax
                    sub bx,2
                    loop downMove

                    mov ax,0x0720
                    stosw

                exitDown:
                    popa
                    ret








        kbisr:
            pusha

            cmp word [cs:gameEnd], 1
            je a

            xor ax,ax

            in al, 0x60
            cmp al, 0x4D
            jnz case2

            ;if snake is already moving right then right key will do nothing. If this comparison is removed then snake moves at greater speed when right key
            ;is pressed.
            cmp word [cs:movedRight], 1
            je case2
            cmp word [cs:movedLeft], 1
            jz a
            mov word [cs:movedRight], 1 ;so that when you press left key after snake has moved right it won't move at all. Snake needs to have moved either 

                                        ;up or down before being able to move left or right.

            call startMovingRight
            mov word [cs:movedUp], 0
            mov word [cs:movedDown], 0
            jmp exit

            case2: ;left
                cmp al, 0x4B
                jnz case3
                cmp word [cs:movedLeft], 1
                je case3
                cmp word [cs:movedRight], 1
                jz a
                mov word [cs:movedLeft], 1
                call startMovingLeft
                mov word [cs:movedUp], 0
                mov word [cs:movedDown], 0
                a:
                jmp exit

            case3: ;up
                cmp al, 0x48
                jnz case4
                cmp word [cs:movedUp], 1
                je case4
                cmp word [cs:movedDown], 1
                jz exit
                mov word [cs:movedUp], 1
                call startMovingUp
                mov word [cs:movedRight], 0
                mov word [cs:movedLeft], 0
                jmp exit

            case4: ;down
                cmp al, 0x50
                jnz nomatch
                cmp word [cs:movedDown], 1
                je nomatch
                cmp word [cs:movedUp], 1
                jz exit
                mov word [cs:movedDown], 1
                call startMovingDown
                mov word [cs:movedRight], 0
                mov word [cs:movedLeft], 0

            nomatch:
                popa
                jmp far [cs:oldisr]
                jmp exit

            exit:
                mov al, 0x20
                out 0x20, al 
                popa
                iret








        timerisr:
            pusha

            ;once game ends timer isr is called once again. the following two lines are to not let timer execute once all lives are lost.
            cmp word [cs:gameEnd], 1
            ;je exitTimer

            continueTimer:
                inc word [cs:tickcount4]

            ;displaying life at top left corner
            xor di, di
            push di
            mov ax, lifeMsg
            push ax
            call printString
            xor ax, ax
            mov al, [cs:life]
            mov di, 30
            push di
            push ax
            mov word [es:di + 2], 0
            call printNumber

            ;displaying time
            xor ax, ax
            xor di, di
            mov di, 128
            mov ax, timeMsg
            push di
            push ax
            call printString

            xor ax,ax
            xor di,di
            mov di, 152
            mov ax, [cs:minutes]
            push di
            push ax
            call printNumber

            xor di,di
            xor ax, ax
            mov di, 154
            mov al, ':'
            mov ah, 0x07
            mov [es:di], ax

            xor ax,ax
            xor di,di
            mov di, 156
            mov ax, [cs:seconds]
            push di
            push ax
            mov word [es:di + 2], 0
            call printNumber


            ;displaying score
            mov ax, 66
            push ax
            mov ax, scoreMsg
            push ax
            call printString
            mov ax, 82
            push ax
            mov ax, [cs:score]
            push ax
            call printNumber


            ;checking if score is enough for new stage
            cmp word [cs:alreadyOnStage1], 0
            jne checkNextStage
            cmp word [cs:score], 100
            jne checkTime
            mov word [cs:stage1], 1
            call collision
            mov word [cs:stage1], 0
            mov word [cs:alreadyOnStage1], 1

            checkNextStage:
                cmp word [cs:alreadyOnStage2], 0
                jne checkLastStage
                cmp word [cs:score], 200
                jne checkTime
                mov word [cs:stage2], 1
                call collision
                mov word [cs:stage2], 0
                mov word [cs:alreadyOnStage2], 1

            checkLastStage:
                cmp word [cs:alreadyOnStage3], 0
                jne checkTime
                cmp word [cs:score], 300 ;min score so i can visit later
                jne checkTime
                mov word [cs:stage3], 1
                call collision
                mov word [cs:stage3], 0
                mov word [cs:alreadyOnStage3], 1


            checkTime:
                cmp word [cs:seconds], 0
                jne checkLife


                mov word [cs:seconds], 60
                dec word [cs:minutes]
                cmp word [cs:minutes], -1
                jne checkLife

                mov word[cs:minutes], 4

                cmp word [cs:snakeLength], 240	
                jne decrementLife

                mov word [cs:gameWon], 1
                add word [cs:score], 100
                xor ax,ax
                mov word [cs:gameEnd], 1
                mov al, 0x20
                out 0x20, al
                popa
                iret

                decrementLife:
                dec byte[cs:life]

            checkLife:
                ;if life reduces to zero, its gameOver
                mov al, [cs:life]
                cmp al, 0
                jne continue
                xor ax,ax
                mov word[cs:gameEnd], 1
                mov al, 0x20
                out 0x20, al
                popa
                iret

            continue:
                ;handling speed
                mov ax, [cs:speedIncreaseInterval]
                mov bx, [cs:tickcount2]
                cmp ax, bx
                jne speedConstant
                mov ax, [cs:speed]
                shr ax, 1
                mov [cs:speed], ax
                mov word[cs:tickcount2], 0
                mov word [cs:tickcount], 0


            speedConstant:
                ;for decrementing total time
                inc word [cs:tickcount3]
                cmp word [cs:tickcount3], 18
                jne notDecrementingSeconds
                dec word[cs:seconds]
                mov word [cs:tickcount3], 0

            notDecrementingSeconds:
                inc word [cs:tickcount2]
                mov ax, [cs:speed]
                cmp ax, 0
                je fullSpeed
                mov bx, [cs:tickcount]
                cmp ax, bx
                jne exitTimer

            fullSpeed:
                mov ax, 1
                cmp [cs:movedRight], ax
                jne timerCase1
                call startMovingRight
                jmp timerCase4

            timerCase1:
                cmp [cs:movedLeft], ax
                jne timerCase2
                call startMovingLeft
                jmp timerCase4

            timerCase2:
                cmp [cs:movedUp], ax
                jne timerCase3
                call startMovingUp
                jmp timerCase4

            timerCase3:
                cmp [cs:movedDown], ax
                jne exitTimer
                call startMovingDown

            timerCase4:
                mov word [cs:tickcount], 0

            exitTimer:
                inc word [cs:tickcount] ;this is done here because if speed becomes 0 then if tickcount is incremented, the compare condition will never come true.
                mov al, 0x20
                out 0x20,al
                popa
                iret









    start:
    call clearScreen
    call makeBorder
    call initializeSnake
    call displaySnake


    mov ax, 0xb800
    mov es, ax
    mov di, 1660
    mov ax, [goodFood]
    stosw
    mov di, 2890
    mov ax, [badFood]
    stosw
    mov di, 378
    mov ax, [healthyFood]
    stosw


    xor ax, ax
    mov es, ax ; point es to IVT base
    mov ax, [es:9*4]
    mov [oldisr], ax ; save offset of old routine
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax ; save segment of old routine

    xor ax, ax
    mov es, ax ; point es to IVT base
    mov ax, [es:8*4]
    mov [oldisr2], ax ; save offset of old routine
    mov ax, [es:8*4+2]
    mov [oldisr2+2], ax ; save segment of old routine

    cli ; disable interrupts
    mov word [es:9*4], kbisr ; store offset at n*4
    mov [es:9*4+2], cs ; store segment at n*4+2
    sti ; enable interrupts

    cli ; disable interrupts
    mov word [es:8*4], timerisr ; store offset at n*4
    mov [es:8*4+2], cs ; store segment at n*4+2
    sti ; enable interrupts

    Game:
        cmp word [gameEnd], 1
        je gameOver
        jmp Game

    gameOver:
        call clearScreen

        cmp word [gameWon], 1
        je displayWinMsg

        mov di, 1670
        push di
        mov ax, gameOverMsg
        push ax
        call printString
        jmp displayScore

    displayWinMsg:
        mov di, 1670
        push di
        mov ax, gameWinMsg
        push ax
        call printString

    displayScore:
        mov di, 2310
        push di
        mov ax, scoreMsg
        push ax
        call printString
        mov di, 2326
        push di
        mov ax, [score]
        push ax
        call printNumber
        call makeBorder
        
        ; displaying restart/exit options
        mov di, 2470
        push di
        mov ax, restartPromptMsg
        push ax
        call printString

        ; restore original keyboard interrupt handler temporarily
        ; to ensure BIOS keyboard functions work properly
        cli
        push word [cs:oldisr+2]  ; Save segment
        push word [cs:oldisr]    ; Save offset
        
        xor ax, ax
        mov es, ax
        mov ax, [cs:oldisr]
        mov [es:9*4], ax
        mov ax, [cs:oldisr+2]
        mov [es:9*4+2], ax
        sti

    waitForChoice:
        mov ah, 0
        int 16h
        
        cmp al, 'r'
        je restartGame
        cmp al, 'R'
        je restartGame
        
        cmp al, 'e'
        je exitGame
        cmp al, 'E'
        je exitGame
        
        jmp waitForChoice

    restartGame:
        ;reset variables
        mov word [gameEnd], 0
        mov word [gameWon], 0
        mov byte [life], 3
        mov word [score], 0
        mov word [minutes], 4
        mov word [seconds], 0
        mov word [movedRight], 1
        mov word [movedLeft], 0
        mov word [movedUp], 0
        mov word [movedDown], 0
        mov word [snakeLength], 4
        mov word [alreadyOnStage1], 0
        mov word [alreadyOnStage2], 0
        mov word [alreadyOnStage3], 0
        mov word [speed], 2
        
        
        ;restore kbsir
        cli
        xor ax, ax
        mov es, ax
        pop word [es:9*4]
        pop word [es:9*4+2]
        sti
        
        ;restarting
        jmp start

exitGame:
    ; pop saved interrupt vectors from stack becoz we pushed while waiting for restart or exit
    pop ax
    pop ax
    
    ;restoring interrupts so exit doesnt break
    cli                     
    xor ax, ax
    mov es, ax              
    mov ax, [oldisr]
    mov [es:9*4], ax        
    mov ax, [oldisr+2]
    mov [es:9*4+2], ax      

    mov ax, [oldisr2]
    mov [es:8*4], ax        
    mov ax, [oldisr2+2]
    mov [es:8*4+2], ax      
    sti

mov ax, 0x4c00
int 0x21