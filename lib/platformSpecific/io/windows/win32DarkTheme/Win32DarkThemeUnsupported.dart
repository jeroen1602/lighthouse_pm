import 'package:flutter/material.dart';

abstract class Win32DarkTheme {
  ///
  /// A stub function to make this work for other platforms.
  /// Original docs:
  ///
  /// Check if the current Windows version supports dark theme.
  /// Will return true if the current Windows version is Windows 10.0 Build
  /// 1809 or above. (Here's hoping this feature stays for future releases of
  /// Windows.)
  static bool win32IsDarkThemeSupported() {
    print(
        "Warning calling win32IsDarkThemeSupported on an unsupported platform!");
    return false;
  }

  ///
  /// A stub function to make this work for other platforms.
  /// Original docs:
  ///
  /// Read the correct registry key to find out what the user's preferred theme
  /// is.
  /// Will return [defaultValue] if the key can't be found. If the key can be
  /// found then it will return [ThemeMode.light], if the key is equal to `0x01`.
  /// Otherwise it will return [ThemeMode.dark].
  ///
  static ThemeMode win32GetSystemThemeMode(
      {ThemeMode defaultValue = ThemeMode.light}) {
    print(
        "Warning calling win32GetSystemThemeMode on an unsupported platform!");
    return defaultValue;
  }
}
