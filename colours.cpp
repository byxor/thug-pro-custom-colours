#include "pch.h"

// C++ Implementation

unsigned int colourTextToInt(const char *text) {
  int red = colourDigitToByte(text[3]);
  int green = colourDigitToByte(text[4]);
  int blue = colourDigitToByte(text[5]);
  int alpha = colourDigitToByte(text[6]);

  int argb = alpha;
  argb = (argb << 8) + red;
  argb = (argb << 8) + green;
  argb = (argb << 8) + blue;

  return argb;
}

int colourDigitToByte(char typedValue) {
  float maxTypedValue = 0xF;
  float maxEncodedValue = 0xFF;

  int typedValueAsInt;
  if (typedValue >= 'a') {
    typedValueAsInt = 10 + (typedValue - 'a');
  } else if (typedValue >= 'A') {
    typedValueAsInt = 10 + (typedValue - 'A');
  } else {
    typedValueAsInt = typedValue - '0';
  }

  float typedValueAsFloat = (float) typedValueAsInt;

  return (typedValueAsFloat / maxTypedValue) * maxEncodedValue;
}





















// x86 Assembly Implementation

unsigned int x86_colourTextToInt(const char *text) {
  unsigned int result;
  __asm {
    #include "colours.asm"
    mov result, eax
  }
  return result;
}
