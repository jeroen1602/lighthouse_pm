import 'package:lighthouse_provider/lighthouse_provider.dart';

void main() {
  final instance = LighthouseProvider.instance;

  // Add a back end
  // instance.addBackEnd();

  // Add a provider
  // instance.addProvider();

  instance.startScan(timeout: Duration(seconds: 5));
}
