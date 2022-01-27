import 'package:flutter_web_bluetooth_back_end/flutter_web_bluetooth_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

void main() {
  final instance = FlutterWebBluetoothBackEnd.instance;
  // Add this backend to the lighthouse provider to start using it.
  final provider = LighthouseProvider.instance;
  provider.addBackEnd(instance);

  // provider.addProvider(specificProviderHere);

  provider.startScan(timeout: Duration(seconds: 5));
}
