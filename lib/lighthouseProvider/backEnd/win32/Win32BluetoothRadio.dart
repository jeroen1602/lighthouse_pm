class Win32BluetoothRadio {
  Win32BluetoothRadio(this.radioHandle);

  final int radioHandle;

  Future<void> close() async {}
}
