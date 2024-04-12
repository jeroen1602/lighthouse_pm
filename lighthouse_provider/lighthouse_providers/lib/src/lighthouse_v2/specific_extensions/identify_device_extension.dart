part of '../../../lighthouse_v2_device_provider.dart';

/// A device extension that allow the device to be identified.
class IdentifyDeviceExtension extends DeviceExtension {
  IdentifyDeviceExtension({required super.onTap}) : super(toolTip: 'Identify') {
    super.streamEnabledFunction = _enabledStream;
  }

  BehaviorSubject<bool>? _enabledSubject = BehaviorSubject.seeded(true);

  Stream<bool> _enabledStream() {
    return _nonNullEnabledSubject().stream;
  }

  BehaviorSubject<bool> _nonNullEnabledSubject() {
    return _enabledSubject ??= BehaviorSubject.seeded(true);
  }

  void setEnabled(final bool enabled) {
    _nonNullEnabledSubject().add(enabled);
  }

  Future<void> close() async {
    final enabledSubject = _enabledSubject;
    if (enabledSubject != null) {
      await enabledSubject.close();
      _enabledSubject = null;
    }
  }

  @override
  String get extensionName => "IdentifyExtension";
}
