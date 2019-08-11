#include "pch.h"
#include "test.h"

struct TestEntry {
  std::string text;
  unsigned int expectedResult;
};

TEST(ColourConversion, All) {
  TestEntry entries[] = {
      {"\\cc0000", 0x00000000},

      // Test alpha channel
      {"\\cc0001", 0x11000000},
      {"\\cc0002", 0x22000000},
      {"\\cc0003", 0x33000000},
      {"\\cc0009", 0x99000000},
      {"\\cc000a", 0xAA000000},
      {"\\cc000b", 0xBB000000},
      {"\\cc000c", 0xCC000000},
      {"\\cc000d", 0xDD000000},
      {"\\cc000e", 0xEE000000},
      {"\\cc000f", 0xFF000000},
      {"\\cc000A", 0xAA000000},
      {"\\cc000B", 0xBB000000},
      {"\\cc000C", 0xCC000000},
      {"\\cc000D", 0xDD000000},
      {"\\cc000E", 0xEE000000},
      {"\\cc000F", 0xFF000000},

      // Test blue channel
      {"\\cc0010", 0x00000011},
      {"\\cc0020", 0x00000022},
      {"\\cc00E0", 0x000000EE},
      {"\\cc00f0", 0x000000FF},

      // Test green channel
      {"\\cc0100", 0x00001100},
      {"\\cc0900", 0x00009900},
      {"\\cc0e00", 0x0000EE00},
      {"\\cc0F00", 0x0000FF00},

      // Test red channel
      {"\\cc1000", 0x00110000},
      {"\\cc9000", 0x00990000},
      {"\\ccE000", 0x00EE0000},
      {"\\ccf000", 0x00FF0000},

      // Test all channels at once
      {"\\ccffff", 0xFFFFFFFF},
      {"\\cc1234", 0x44112233},
  };

  for (TestEntry entry : entries) {
    const char *textAsCharacters = entry.text.c_str();
    int actualResult = x86_colourTextToInt(textAsCharacters);

    std::cerr << "\"" << entry.text << "\" == " << hex(entry.expectedResult) << "\n";
    std::cerr << "                        " << hex(actualResult) << "\n\n";

    EXPECT_EQ(actualResult, entry.expectedResult);
  }
}