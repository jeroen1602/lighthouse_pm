import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:meta/meta.dart';

@visibleForTesting
class TestReadCharacteristic extends FakeReadOnlyCharacteristic {
  TestReadCharacteristic(final List<int> data)
      : super(data,
            LighthouseGuid.fromString('FFFFFFFF-0000-0000-0000-000000000000'));
}

@visibleForTesting
class TestReadWriteCharacteristic extends FakeReadWriteCharacteristic {
  TestReadWriteCharacteristic()
      : super(
            LighthouseGuid.fromString('FFFFFFFF-0000-0000-0000-000000000001'));

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    this.data = data;
  }
}
