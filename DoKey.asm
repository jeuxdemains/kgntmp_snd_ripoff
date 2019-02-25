.data
; Text
	txt_Window_Title			db	"MiSSiNG iN ByTES",0       ; Window-Title
	tbxNameConst				db	"XXXX-MiB",0                 ; Name shown in editbox, when entering cube first time
; Keygen
	KeygenCharMin			equ	3
	KeygenCharMax			equ	31
	txtMoreChars				db	"Gimme more chars !",0
	txtLessChars				db	"Too many chars !",0
; *** KEYGENNER'S PLAYGROUND ;P ***
	Hash1					dd	0FADEh
	Hash2					dd	0B00h
	Hash3					dd	1337h
	Hash4					dd	777h
	Hash5					dd	0DEADh
	FormatToDec				db	"%d-",0
	EndFormatToDec			db	"%d",0

.data?
; Keygen
	tbxName					db			50 dup (?)          ; This string will always hold the entered name -> INPUT
	tbxSerial					db			300 dup (?)        ; This string will always be shown in the serialbox -> OUTPUT
; *** KEYGENNER'S PLAYGROUND ;P ***
	NameLen					dd			?
	TempBuffer				db			300 dup (?)

.code
; PROC DoKeygen ===============================
; Now it's ur turn..... INPUT(tbxserial) --> OUTPUT (tbxName)
; =============================================

DoKeygen proc

; *** Init ***
	lea edi,tbxName
	invoke lstrlen,edi
	mov edx,eax
	mov NameLen, eax
	
; *** Backup regs ***
	pushad  ; Uncomment, if using one of first two calcs !
	
;; *** Uppercase entered name ***
;	CharUpper_Name:
;	mov al,byte ptr ds:[edi]
;	cmp al,061h
;	jb @f 
;	cmp al,07ah 
;	ja @f 
;	sub al,020h
;@@:
;	mov byte ptr ds:[edi],al 
;	inc edi
;	dec edx
;	test edx,edx 
;	jnz CharUpper_Name
;	; *!* or just: *!*
;	; *invoke CharUpper,addr tbxName*
	
; *** Add hardcoded serial-part ***
	szText HardCodedPart,"151aneL-"
	invoke lstrcpy,addr TempBuffer,addr HardCodedPart 
	invoke lstrcat,addr tbxSerial,addr TempBuffer
	
; *** Restore  ***
	popad  ; Uncomment, if using one of first two calcs !
	
; *** Hash routine 1 ***
	xor ecx,ecx
	xor ebx,ebx 
	Hash_Routine_1:
	mov eax,edi 
	mov al,byte ptr ds:[eax+ecx]
	cmp al,020h 
	je @f 
	and eax,0ffh
	imul eax,Hash1
	dec eax 
	add ebx,eax 
@@:
	inc ecx 
	dec edx
	jnz Hash_Routine_1
	invoke wsprintf,addr TempBuffer,addr EndFormatToDec,ebx 
	invoke lstrcat,addr tbxSerial,addr TempBuffer
	
; *** Hash routine 2 ***
	sub edx,3
@@:
	mov eax,dword ptr ds:[edi]
	xor eax,Hash1
	add esi,eax
	shr esi,7
	inc esi 
	xor esi,Hash2 
	add ebx,esi 
	dec edx 
	jnz @b
	invoke wsprintf,addr TempBuffer,addr EndFormatToDec,ebx 
	invoke lstrcat,addr tbxSerial,addr TempBuffer
	
;; *** Hash routine 3.1 ***
;	xor ecx,ecx 
;	xor ebx,ebx
;	mov esi,Hash1
;@@:						
;	movsx eax,byte ptr [ecx+edi]
;	add eax,esi
;	shl eax,1
;	add ebx,eax
;	inc ecx
;	cmp ecx,edx
;	jl @b
;	invoke wsprintf,addr TempBuffer,addr FormatToDec,ebx 
;	invoke lstrcat,addr tbxSerial,addr TempBuffer 
;	
;; *** Hash routine 3.2 ***
;	xor ecx,ecx 
;	xor ebx,ebx 
;	mov esi,Hash2	
;	mov edx, NameLen
;@@: 
;	movsx eax,byte ptr [ecx+edi]
;	add eax,esi
;	imul eax,3
;	add ebx,eax
;	inc ecx
;	cmp ecx,edx
;	jl @b
;	invoke wsprintf,addr TempBuffer,addr FormatToDec,ebx 
;	invoke lstrcat,addr tbxSerial,addr TempBuffer
;	
;; *** Hash routine 3.3 ***
;	xor ecx,ecx 
;	xor ebx,ebx 
;	mov esi,Hash3	
;	mov edx, NameLen
;@@:
;	movsx eax,byte ptr [ecx+edi] 
;	add eax,esi 
;	shr eax,3
;	add ebx,eax
;	inc ecx
;	cmp ecx,edx   
;	jl @b
;	invoke wsprintf,addr TempBuffer,addr FormatToDec,ebx 
;	invoke lstrcat,addr tbxSerial,addr TempBuffer
;	
;; *** Hash routine 3.4 ***
;	xor ecx,ecx 
;	xor ebx,ebx 
;	mov esi,Hash4	
;	mov edx, NameLen
;@@:
;	movsx eax,byte ptr [ecx+edi]
;	add eax,esi 
;	dec eax
;	add ebx,eax
;	inc ecx
;	cmp ecx,edx 
;	jl @b
;	invoke wsprintf,addr TempBuffer,addr FormatToDec,ebx 
;	invoke lstrcat,addr tbxSerial,addr TempBuffer 
;	
;; *** Hash routine 3.5 ***
;	xor ecx,ecx 
;	xor ebx,ebx 
;	mov esi,Hash5		
;	mov edx, NameLen
;@@:
;	movsx eax,byte ptr [ecx+edi]
;	add eax,esi  
;	inc eax
;	add ebx,eax
;	inc ecx
;	cmp ecx,edx 
;	jl @b
;	invoke wsprintf,addr TempBuffer,addr EndFormatToDec,ebx 
;	invoke lstrcat,addr tbxSerial,addr TempBuffer 
	
ENDITALL:
	xor eax,eax
	ret
DoKeygen EndP
