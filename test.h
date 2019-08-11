#pragma once

#include "pch.h"

std::string hex(unsigned int n) {
  std::stringstream stream;
  stream << "0x" << std::hex << n;
  return stream.str();
}