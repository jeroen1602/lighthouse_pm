enum BluetoothAdapterState {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off,
  error
}

abstract class BluetoothAdapterStateFunctions {
  static String stateToString(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return "unknown";
      case BluetoothAdapterState.unavailable:
        return "unavailable";
      case BluetoothAdapterState.unauthorized:
        return "unauthorized";
      case BluetoothAdapterState.turningOn:
        return "turning on";
      case BluetoothAdapterState.on:
        return "on";
      case BluetoothAdapterState.turningOff:
        return "turning off";
      case BluetoothAdapterState.off:
        return "off";
      case BluetoothAdapterState.error:
        return "error";
    }
  }
}
