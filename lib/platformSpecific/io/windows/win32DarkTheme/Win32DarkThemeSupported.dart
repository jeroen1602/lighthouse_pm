import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

/// TODO: watch for changes with the key to update the app as soon as the user
/// changes theme, this probably won't happen very often so it's not a high
/// priority.
abstract class Win32DarkTheme {
  static const THEME_MODE_KEY =
      r'SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize';
  static const THEME_MODE_SUB_KEY = r'AppsUseLightTheme';
  static const THEME_MODE_KEY_HIVE = HKEY_CURRENT_USER;

  ///
  /// Check if the current Windows version supports dark theme.
  /// Will return true if the current Windows version is Windows 10.0 Build
  /// 1809 or above. (Here's hoping this feature stays for future releases of
  /// Windows.)
  static bool win32IsDarkThemeSupported() {
    final versionInfo = calloc<OSVERSIONINFO>();
    versionInfo.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

    try {
      final result = GetVersionEx(versionInfo);

      if (result != FALSE) {
        // check if at least windows 10.
        // If the minor is 0 then the build number should be higher than
        // 17763 meaning windows 10.0 version 1809. The first version with
        // dark theme support (as far as I known).
        // If the minor is higher then assume dark theme is supported, no
        // Windows OS currently exists with this, but just in case.
        if (versionInfo.ref.dwMajorVersion >= 10 &&
                versionInfo.ref.dwMinorVersion > 0 ||
            versionInfo.ref.dwBuildNumber > 17763) {
          return true;
        }
        return false;
      } else {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
    } finally {
      free(versionInfo);
    }
  }

  ///
  /// Read the correct registry key to find out what the user's preferred theme
  /// is.
  /// Will return [defaultValue] if the key can't be found. If the key can be
  /// found then it will return [ThemeMode.light], if the key is equal to `0x01`.
  /// Otherwise it will return [ThemeMode.dark].
  ///
  static ThemeMode win32GetSystemThemeMode(
      {ThemeMode defaultValue = ThemeMode.light}) {
    // Read the HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme registry key to see what the system theme should be.
    final phKey = calloc<HANDLE>();
    final lpKeyPath = THEME_MODE_KEY.toNativeUtf16();
    final lpSubKey = THEME_MODE_SUB_KEY.toNativeUtf16();
    final lpDataType = calloc<DWORD>();
    final lpData = calloc<DWORD>();
    final lpcbData = calloc<DWORD>()..value = sizeOf<DWORD>();

    try {
      final result = RegGetValue(THEME_MODE_KEY_HIVE, lpKeyPath, lpSubKey,
          RRF_RT_DWORD, lpDataType, lpData, lpcbData);
      if (result == ERROR_SUCCESS) {
        if (lpData.value == 0x01) {
          return ThemeMode.light;
        } else {
          return ThemeMode.dark;
        }
      } else if (result == ERROR_FILE_NOT_FOUND) {
        // Key doesn't exist so assume light mode.
        return defaultValue;
      } else {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
    } finally {
      free(phKey);
      free(lpKeyPath);
      free(lpSubKey);
      free(lpDataType);
      free(lpData);
      free(lpcbData);
    }
  }
}
