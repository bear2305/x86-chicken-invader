[bits 16]
[org 0x7c00]

start:
    ; 1. Fix Segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; Set stack safely below bootloader

    ; 2. Save the Boot Drive ID
    mov [boot_drive], dl 
    
    mov ah,0x41
    mov bx,0x55aa
    int 0x13
    jc chs_fallback
    
    mov ah,0x42
    mov dl,[boot_drive]
    mov si,disk_packet
    int 0x13
    jc disk_e
    jmp 0x0000:0x9000

chs_fallback:
    ; 3. Reset Disk System (Important for real hardware)
             xor ax, ax
             mov dl, [boot_drive]
             int 0x13

    ; 4. Load Sectors
             mov ah, 0x02
             mov al, 5               ; Load 5 sectors (spacegame.asm)
             mov ch, 0               ; Cylinder 0
             mov dh, 0               ; Head 0
             mov cl, 2               ; Sector 2
             mov dl, [boot_drive]    ; Use the ID the BIOS gave us
             mov bx, 0x9000          ; Destination ES:BX (0x0000:0x9000)
             int 0x13
             jc disk_error           ; Carry flag is set if it fails

             jmp 0x9000
 
disk_error:
           mov ah, 0x0e
           mov al, 'm'
           int 0x10
           mov al, '@'
           int 0x10
           mov al, 'c'
           int 0x10
           jmp $                   ; Lock up on error
           
disk_e:
        mov ah, 0x0e
        mov al, 'm'
        int 0x10
        mov al, '@'
        int 0x10
        mov al, 'l'
        int 0x10
        jmp $                 

; Data storage (Inside the code segment, but after the jump)
boot_drive: db 0
align 4
disk_packet: 
           db 0x10
           db 0x00
           dw 5
           dw 0x9000
           dw 0x0000
           dq 1


times 510-($-$$) db 0
dw 0xaa55
