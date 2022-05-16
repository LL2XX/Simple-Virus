data segment
    hello db 'Hello World!$'
data ends

code segment
    assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax
    lea dx,hello
    mov ah,09h
    int 21h
    mov ax,4c00h
    int 21h
code ends
end start
