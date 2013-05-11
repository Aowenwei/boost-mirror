
;           Copyright Oliver Kowalke 2009.
;  Distributed under the Boost Software License, Version 1.0.
;     (See accompanying file LICENSE_1_0.txt or copy at
;           http://www.boost.org/LICENSE_1_0.txt)

;  ----------------------------------------------------------------------------------
;  |    0    |    1    |    2    |    3    |    4     |    5    |    6    |    7    |
;  ----------------------------------------------------------------------------------
;  |   0x0   |   0x4   |   0x8   |   0xc   |   0x10   |   0x14  |   0x18  |   0x1c  |
;  ----------------------------------------------------------------------------------
;  |        R12        |         R13       |         R14        |        R15        |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    8    |    9    |   10    |   11    |    12    |    13   |    14   |    15   |
;  ----------------------------------------------------------------------------------
;  |   0x20  |   0x24  |   0x28  |  0x2c   |   0x30   |   0x34  |   0x38  |   0x3c  |
;  ----------------------------------------------------------------------------------
;  |        RDI        |        RSI        |         RBX        |        RBP        |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    16   |    17   |    18   |    19   |                                        |
;  ----------------------------------------------------------------------------------
;  |   0x40  |   0x44  |   0x48  |   0x4c  |                                        |
;  ----------------------------------------------------------------------------------
;  |        RSP        |        RIP        |                                        |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    20   |    21   |    22   |    23   |    24    |    25   |                   |
;  ----------------------------------------------------------------------------------
;  |   0x50  |   0x54  |   0x58  |   0x5c  |   0x60   |   0x64  |                   |
;  ----------------------------------------------------------------------------------
;  |        sp         |       size        |        limit       |                   |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    26   |   27    |                                                            |
;  ----------------------------------------------------------------------------------
;  |   0x68  |   0x6c  |                                                            |
;  ----------------------------------------------------------------------------------
;  |      fbr_strg     |                                                            |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    28   |   29    |    30   |    31   |    32    |    33   |   34    |   35    |
;  ----------------------------------------------------------------------------------
;  |   0x70  |   0x74  |   0x78  |   0x7c  |   0x80   |   0x84  |  0x88   |  0x8c   |
;  ----------------------------------------------------------------------------------
;  | fc_mxcsr|fc_x87_cw|      fc_xmm       |      SEE registers (XMM6-XMM15)        |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |   36    |    37   |    38   |    39   |    40    |    41   |   42    |   43    |
;  ----------------------------------------------------------------------------------
;  |  0x90   |   0x94  |   0x98  |   0x9c  |   0xa0   |   0xa4  |  0xa8   |  0xac   |
;  ----------------------------------------------------------------------------------
;  |                          SEE registers (XMM6-XMM15)                            |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    44    |   45    |    46   |    47  |    48    |    49   |   50    |   51    |
;  ----------------------------------------------------------------------------------
;  |   0xb0   |  0xb4   |  0xb8   |  0xbc  |   0xc0   |   0xc4  |  0xc8   |  0xcc   |
;  ----------------------------------------------------------------------------------
;  |                          SEE registers (XMM6-XMM15)                            |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    52    |   53    |    54   |   55   |    56    |    57   |   58    |   59    |
;  ----------------------------------------------------------------------------------
;  |   0xd0   |  0xd4   |   0xd8  |  0xdc  |   0xe0   |  0xe4   |  0xe8   |  0xec   |
;  ----------------------------------------------------------------------------------
;  |                          SEE registers (XMM6-XMM15)                            |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    60   |    61   |    62    |    63  |    64    |    65   |   66    |   67    |
;  ----------------------------------------------------------------------------------
;  |  0xf0   |  0xf4   |   0xf8   |  0xfc  |   0x100  |  0x104  |  0x108  |  0x10c  |
;  ----------------------------------------------------------------------------------
;  |                          SEE registers (XMM6-XMM15)                            |
;  ----------------------------------------------------------------------------------
;  ----------------------------------------------------------------------------------
;  |    68   |    69   |    70    |    71  |    72    |    73   |   74    |   75    |
;  ----------------------------------------------------------------------------------
;  |  0x110  |  0x114  |   0x118  |  0x11c |   0x120  |  0x124  |  0x128  |  0x12c  |
;  ----------------------------------------------------------------------------------
;  |                          SEE registers (XMM6-XMM15)                            |
;  ----------------------------------------------------------------------------------

EXTERN  _exit:PROC            ; standard C library function
.code

jump_fcontext PROC EXPORT FRAME
    .endprolog

    mov     [rcx],       r12        ; save R12
    mov     [rcx+08h],   r13        ; save R13
    mov     [rcx+010h],  r14        ; save R14
    mov     [rcx+018h],  r15        ; save R15
    mov     [rcx+020h],  rdi        ; save RDI
    mov     [rcx+028h],  rsi        ; save RSI
    mov     [rcx+030h],  rbx        ; save RBX
    mov     [rcx+038h],  rbp        ; save RBP

    mov     r10,         gs:[030h]  ; load NT_TIB
    mov     rax,         [r10+08h]  ; load current stack base
    mov     [rcx+050h],  rax        ; save current stack base
    mov     rax,         [r10+010h] ; load current stack limit
    mov     [rcx+060h],  rax        ; save current stack limit
    mov     rax,         [r10+018h] ; load fiber local storage
    mov     [rcx+068h],  rax        ; save fiber local storage

    test    r9,          r9
    je      nxt

    stmxcsr [rcx+070h]              ; save MMX control and status word
    fnstcw  [rcx+074h]              ; save x87 control word
    ; save XMM storage
    ; save start address of SSE register block in R10
    lea     r10,          [rcx+090h]
    ; shift address in R10 to lower 16 byte boundary
    ; == pointer to SEE register block
    and     r10,         -16

    movaps  [r10],       xmm6
    movaps  [r10+010h],  xmm7
    movaps  [r10+020h],  xmm8
    movaps  [r10+030h],  xmm9
    movaps  [r10+040h],  xmm10
    movaps  [r10+050h],  xmm11
    movaps  [r10+060h],  xmm12
    movaps  [r10+070h],  xmm13
    movaps  [r10+080h],  xmm14
    movaps  [r10+090h],  xmm15

    ldmxcsr [rdx+070h]              ; restore MMX control and status word
    fldcw   [rdx+074h]              ; restore x87 control word
    ; restore XMM storage
	; save start address of SSE register block in R10
    lea     r10,          [rdx+090h]
    ; shift address in R10 to lower 16 byte boundary
    ; == pointer to SEE register block
    and     r10,         -16

    movaps  xmm6,        [r10]
    movaps  xmm7,        [r10+010h]
    movaps  xmm8,        [r10+020h]
    movaps  xmm9,        [r10+030h]
    movaps  xmm10,       [r10+040h]
    movaps  xmm11,       [r10+050h]
    movaps  xmm12,       [r10+060h]
    movaps  xmm13,       [r10+070h]
    movaps  xmm14,       [r10+080h]
    movaps  xmm15,       [r10+090h]

nxt:
    lea     rax,         [rsp+08h]  ; exclude the return address
    mov     [rcx+040h],  rax        ; save as stack pointer
    mov     rax,         [rsp]      ; load return address
    mov     [rcx+048h],  rax        ; save return address

    mov     r12,        [rdx]       ; restore R12
    mov     r13,        [rdx+08h]   ; restore R13
    mov     r14,        [rdx+010h]  ; restore R14
    mov     r15,        [rdx+018h]  ; restore R15
    mov     rdi,        [rdx+020h]  ; restore RDI
    mov     rsi,        [rdx+028h]  ; restore RSI
    mov     rbx,        [rdx+030h]  ; restore RBX
    mov     rbp,        [rdx+038h]  ; restore RBP

    mov     r10,        gs:[030h]   ; load NT_TIB
    mov     rax,        [rdx+050h]  ; load stack base
    mov     [r10+08h],  rax         ; restore stack base
    mov     rax,        [rdx+060h]  ; load stack limit
    mov     [r10+010h], rax         ; restore stack limit
    mov     rax,        [rdx+068h]  ; load fiber local storage
    mov     [r10+018h], rax         ; restore fiber local storage

    mov     rsp,        [rdx+040h]  ; restore RSP
    mov     r10,        [rdx+048h]  ; fetch the address to returned to

    mov     rax,        r8          ; use third arg as return value after jump
    mov     rcx,        r8          ; use third arg as first arg in context function

    jmp     r10                     ; indirect jump to caller
jump_fcontext ENDP
END
