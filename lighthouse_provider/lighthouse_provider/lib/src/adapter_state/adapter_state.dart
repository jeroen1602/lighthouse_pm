part of '../../lighthouse_provider.dart';

enum BluetoothAdapterState {
  unknown("unknown"),
  unavailable("unavailable"),
  unauthorized("unauthorized"),
  turningOn("turning on"),
  on("on"),
  turningOff("turning off"),
  off("off"),
  error("error");

  final String name;

  const BluetoothAdapterState(this.name);
}
