import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

class TestReadCharacteristic extends FakeReadOnlyCharacteristic {
  TestReadCharacteristic(List<int> data)
      : super(data,
            LighthouseGuid.fromString('FFFFFFFF-0000-0000-0000-000000000000'));
}

class TestReadWriteCharacteristic extends FakeReadWriteCharacteristic {
  TestReadWriteCharacteristic()
      : super(
            LighthouseGuid.fromString('FFFFFFFF-0000-0000-0000-000000000001'));

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) async {
    this.data = data;
  }
}
