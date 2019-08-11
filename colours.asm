jmp start

; x86 Assembly Implementation

_customColourTextToInt:
	push ebp
	mov ebp, esp
	sub esp, 16

	mov dword ptr [ebp-4], 0     ; int red
	mov dword ptr [ebp-8], 0     ; int green
	mov dword ptr [ebp-12], 0    ; int blue
	mov dword ptr [ebp-16], 0    ; int alpha

	mov ecx, [ebp+8]             ; ecx = text

	xor ebx, ebx                 ; get red byte...
	mov bl, byte ptr [ecx+3]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-4], eax

	xor ebx, ebx                 ; get green byte...
	mov bl, byte ptr [ecx+4]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-8], eax

	xor ebx, ebx                 ; get blue byte...
	mov bl, byte ptr [ecx+5]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-12], eax

	xor ebx, ebx                 ; get alpha byte...
	mov bl, byte ptr [ecx+6]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-16], eax

	mov eax, dword ptr [ebp-16]  ; argb = alpha

	mov ebx, eax                 ; t = argb
	shl ebx, 8                   ; t <<= 8
	add ebx, dword ptr [ebp-4]   ; t += red
	mov eax, ebx                 ; argb = t

	mov ebx, eax                 ; t = argb
	shl ebx, 8                   ; t <<= 8
	add ebx, dword ptr [ebp-8]   ; t += green
	mov eax, ebx                 ; argb = t

	mov ebx, eax                 ; t = argb
	shl ebx, 8                   ; t <<= 8
	add ebx, dword ptr [ebp-12]  ; t += blue
	mov eax, ebx                 ; argb = t

	add esp, 16
	pop ebp
	ret 4


_colourDigitToByte:
	push ebp
	mov ebp, esp
	sub esp, 12

	mov dword ptr [ebp-4],  0xF    ; int maxTypedValue = 0xF
	mov dword ptr [ebp-8],  0xFF   ; int maxEncodedValue = 0xFF
	mov dword ptr [ebp-12], 0      ; DWORD temp

	mov ebx, dword ptr [ebp+8]     ; char ebx = typedValue

	cmp ebx, 'a'                   ; if (ebx >= 'a') {
	jge isLowerCaseHex             ;   treat as lowercase hex
	cmp ebx, 'A'                   ; } else if (ebx >= 'A') {
	jge isUpperCaseHex             ;   treat as uppercase hex
                                   ; } else {
	jmp isDecimal                  ;   treat as decimal
                                   ; }

    isLowerCaseHex:
	sub ebx, 'a'                   ; ebx = 10 + (ebx - 'a')
	add ebx, 10
	jmp done

    isUpperCaseHex:
	sub ebx, 'A'                   ; ebx = 10 + (ebx - 'A')
	add ebx, 10
	jmp done

    isDecimal:
	sub ebx, '0'                   ; ebx = ebx - '0'
	jmp done

    done:
	mov dword ptr [ebp+8], ebx

	finit
	fild dword ptr [ebp+8]         ; fpu <- typedValue
	fidiv dword ptr [ebp-4]        ; st(0) /= maxTypedValue
	fimul dword ptr [ebp-8]        ; st(0) *= maxEncodedValue;
	fisttp dword ptr [ebp-12]      ; fpu -> temp

	mov eax, dword ptr [ebp-12]    ; return temp

	add esp, 12
	pop ebp 
	ret 4


start:
	push text
	call _customColourTextToInt
