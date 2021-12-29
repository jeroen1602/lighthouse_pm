import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';

void main() {
  test('Should be able to create identify device extension', () async {
    final extension = IdentifyDeviceExtension(onTap: () async {});

    expect(extension.icon, isA<SvgPicture>());
    expect(extension.toolTip, 'Identify');
    expect(extension.updateListAfter, false);

    // cleanup
    await extension.close();
  });

  test('Should be able to identify', () async {
    var clicked = false;

    final extension = IdentifyDeviceExtension(onTap: () async {
      clicked = true;
    });

    await extension.onTap();
    expect(clicked, true, reason: "Identify should have been clicked");

    // cleanup
    await extension.close();
  });

  test('Should be able to change enabled', () async {
    final extension = IdentifyDeviceExtension(onTap: () async {});

    extension.setEnabled(false);
    expect(await extension.enabledStream.first, false);
    await extension.close();
    extension.setEnabled(true);
    expect(await extension.enabledStream.first, true);

    // cleanup
    await extension.close();
  });
}
