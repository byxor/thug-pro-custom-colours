alloc(newmem0,2048)
label(returnhere0)
label(originalcode0)
label(exit0)

alloc(newmem1,2048)
label(returnhere1)
label(originalcode1)
label(exit1)


// --------------------------------------------------------------
// Code to choose between custom colours and legacy colours
// --------------------------------------------------------------

newmem0:
  pushad
  mov cl, byte ptr [ebx]
  cmp cl, 'c'
  je enableCustomColours
  jmp disableCustomColours

enableCustomColours:
  mov dword ptr [shouldUseCustomColours], 1
  jmp doneSettingCustomColours

disableCustomColours:
  mov dword ptr [shouldUseCustomColours], 0

doneSettingCustomColours:
  popad

originalcode0:
push ebx
call "THUGPro.exe"+20E0

exit0:
jmp returnhere0


// --------------------------------------------------------------
// Code to set the colour
// --------------------------------------------------------------

newmem1:
  pushad

  sub ebx, 2

  mov eax, [shouldUseCustomColours]
  cmp eax, 0
  je dontUseCustomColours

  xor eax, eax

  mov al, byte ptr [ebx+1]     // Use legacy colours if end of string is reached
  cmp al, 0
  je dontUseCustomColours

  mov al, byte ptr [ebx+2]
  push eax
  call _isValidDigit
  test eax, eax
  jz dontUseCustomColours

  mov al, byte ptr [ebx+3]
  push eax
  call _isValidDigit
  test eax, eax
  jz dontUseCustomColours

  mov al, byte ptr [ebx+4]
  push eax
  call _isValidDigit
  test eax, eax
  jz dontUseCustomColours

  mov al, byte ptr [ebx+5]
  push eax
  call _isValidDigit
  test eax, eax
  jz dontUseCustomColours

  jmp useCustomColours

dontUseCustomColours:
  popad
  jmp originalcode1

useCustomColours:
  sub ebx, 1
  push ebx
  call _customColourTextToInt
  mov dword ptr [customColour], eax
  popad

  // Original block of code from exe with slight modifications
  mov edx, dword ptr [edi+14]
  mov eax, dword ptr [edx+eax*4+134]
  mov ecx, eax
  shr ecx, 10
  mov edx, eax
  movzx ecx, cl
  and edx, ff
  shl edx, 10
  mov [esp+6c], eax
  or ecx, edx
  and eax, FF00FF00
  or ecx, eax
  mov ecx, dword ptr [customColour]      // <-- injected this line to load the custom colour
  mov dword ptr [esp+58], ecx
  add ebx, 4                             // <-- injected this line to skip past the colour digits (so they don't render)
  jmp 004CFFFA

shouldUseCustomColours:
  dd 0

customColour:
  dd 12345678

originalcode1:
  mov edx,[edi+14]
  mov eax,[edx+eax*4+134]

exit1:
  jmp returnhere1

// --------------------------------------------------------------
// Untested functions
// --------------------------------------------------------------
 
_isValidDigit:
    push ebp
    mov ebp, esp
    
    mov ecx, [ebp+8]             // ecx = character
    
    cmp ecx, 30                  // ecx <  '0': invalid
    jl digitIsInvalid
    
    cmp ecx, 39                  // ecx <= '9': valid (decimal)
    jle digitIsValid
    
    cmp ecx, 41                  // ecx <  'A': invalid
    jl digitIsInvalid
    
    cmp ecx, 46                  // ecx <= 'F': valid (uppercase hex)
    jle digitIsValid
    
    cmp ecx, 61                  // ecx <  'a': invalid
    jl digitIsInvalid
    
    cmp ecx, 66                  // ecx <= 'f': valid (lowercase hex)
    jle digitIsValid
    
    jmp digitIsInvalid          // else      : invalid
    
    digitIsValid:
    mov eax, 1
    jmp doneCheckingValidity
    
    digitIsInvalid:
    mov eax, 0
    jmp doneCheckingValidity
    
    doneCheckingValidity:

    pop ebp
    ret 4
  
// --------------------------------------------------------------
// Unit tested functions
// --------------------------------------------------------------

_customColourTextToInt:
	push ebp
	mov ebp, esp
	sub esp, 10

	mov dword ptr [ebp-4], 0     // int red
	mov dword ptr [ebp-8], 0     // int green
	mov dword ptr [ebp-C], 0     // int blue
	mov dword ptr [ebp-10], 0    // int alpha

	mov ecx, [ebp+8]             // ecx = text

	xor ebx, ebx                 // get red byte...
	mov bl, byte ptr [ecx+3]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-4], eax

	xor ebx, ebx                 // get green byte...
	mov bl, byte ptr [ecx+4]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-8], eax

	xor ebx, ebx                 // get blue byte...
	mov bl, byte ptr [ecx+5]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-C], eax

	xor ebx, ebx                 // get alpha byte...
	mov bl, byte ptr [ecx+6]
	push ebx
	call _colourDigitToByte
	mov dword ptr [ebp-10], eax

	mov eax, dword ptr [ebp-10]  // argb = alpha

	mov ebx, eax                 // t = argb
	shl ebx, 8                   // t <<= 8
	add ebx, dword ptr [ebp-4]   // t += red
	mov eax, ebx                 // argb = t

	mov ebx, eax                 // t = argb
	shl ebx, 8                   // t <<= 8
	add ebx, dword ptr [ebp-8]   // t += green
	mov eax, ebx                 // argb = t

	mov ebx, eax                 // t = argb
	shl ebx, 8                   // t <<= 8
	add ebx, dword ptr [ebp-C]   // t += blue
	mov eax, ebx                 // argb = t

	add esp, 10
	pop ebp
	ret 4


_colourDigitToByte:
	push ebp
	mov ebp, esp
	sub esp, C

	mov dword ptr [ebp-4], 0xF     // int maxTypedValue = 0xF
	mov dword ptr [ebp-8], 0xFF    // int maxEncodedValue = 0xFF
	mov dword ptr [ebp-C], 0       // DWORD temp

	mov ebx, dword ptr [ebp+8]     // char ebx = typedValue

	cmp ebx, 61                    // if (ebx >= 'a') {
	jge isLowerCaseHex             //   treat as lowercase hex
	cmp ebx, 41                    // } else if (ebx >= 'A') {
	jge isUpperCaseHex             //   treat as uppercase hex
                                   // } else {
	jmp isDecimal                  //   treat as decimal
                                   // }

    isLowerCaseHex:
	sub ebx, 61                    // ebx = 10 + (ebx - 'a')
	add ebx, A
	jmp doneConvertingFromAscii

    isUpperCaseHex:
	sub ebx, 41                    // ebx = 10 + (ebx - 'A')
	add ebx, A
	jmp doneConvertingFromAscii

    isDecimal:
	sub ebx, 30                    // ebx = ebx - '0'
	jmp doneConvertingFromAscii

    doneConvertingFromAscii:
	mov dword ptr [ebp+8], ebx

	finit
	fild dword ptr [ebp+8]         // fpu <- typedValue
	fidiv dword ptr [ebp-4]        // st(0) /= maxTypedValue
	fimul dword ptr [ebp-8]        // st(0) *= maxEncodedValue
	fisttp dword ptr [ebp-C]       // fpu -> temp

	mov eax, dword ptr [ebp-C]     // return temp

	add esp, C
	pop ebp
	ret 4


// --------------------------------------------------------------
// Code Injection Points
// --------------------------------------------------------------

"THUGPro.exe"+CFE68:
jmp newmem0
nop
returnhere0:


"THUGPro.exe"+CFE7D:
jmp newmem1
nop
nop
nop
nop
nop
returnhere1:
