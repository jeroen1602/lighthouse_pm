import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/win32/Win32BluetoothRadio.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:win32/win32.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import 'BLELighthouseBackEnd.dart';

/// A back end that provides devices using [Win32].
class Win32BackEnd extends BLELighthouseBackEnd {
  Win32BackEnd._();

  // Make sure there is always only one instance.
  static Win32BackEnd? _instance;

  static Win32BackEnd get instance => _instance ??= Win32BackEnd._();

  BehaviorSubject<List<Win32BluetoothRadio>> _foundRadiosSubject =
      BehaviorSubject.seeded([]);
  StreamSubscription? _radiosScanSubscription;

  @override
  // TODO: implement lighthouseStream
  Stream<LighthouseDevice?> get lighthouseStream => throw UnimplementedError();

  @override
  Stream<BluetoothAdapterState> get state async* {
    await _startListeningForChangedDevices();
    yield* _foundRadiosSubject.map((devices) {
      if (devices.isEmpty) {
        return BluetoothAdapterState.unavailable;
      }
      // TODO: find a way to get the radio/ adapter power state.
      return BluetoothAdapterState.on;
    });
  }

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
  }

  @override
  Future<void> stopScan() async {}

  Future<void> _startListeningForChangedDevices() async {
    var radioScanSubscription = _radiosScanSubscription;
    if (radioScanSubscription != null) {
      return;
    }

    radioScanSubscription =
        MergeStream([Stream.value(null), Stream.periodic(Duration(seconds: 1))])
            .listen((_) async {
      final radios = _findBluetoothRadios();
      final knownRadios = _foundRadiosSubject.requireValue;
      var changed = false;
      // find extra
      for (int i = 0; i < knownRadios.length; i++) {
        final index = radios
            .indexWhere((element) => element == knownRadios[i].radioHandle);
        if (index < 0) {
          // Remove the extra no longer available radio.
          await knownRadios.removeAt(index).close();
          changed = true;
        }
      }
      // find missing
      for (int i = 0; i < radios.length; i++) {
        final index = knownRadios
            .indexWhere((element) => element.radioHandle == radios[i]);
        if (index < 0) {
          // Add the new radio.
          knownRadios.add(Win32BluetoothRadio(radios[i]));
          changed = true;
        }
      }
      if (changed) {
        knownRadios.sort((a, b) => a.radioHandle - b.radioHandle);
        _foundRadiosSubject.add(knownRadios);
      }
    });

    radioScanSubscription.onDone(() {
      this._radiosScanSubscription = null;
    });

    this._radiosScanSubscription = radioScanSubscription;
  }

  List<int> _findBluetoothRadios() {
    List<int> radioHandles = [];
    final findRadioParams = calloc<BLUETOOTH_FIND_RADIO_PARAMS>()
      ..ref.dwSize = sizeOf<BLUETOOTH_FIND_RADIO_PARAMS>();

    final hRadio = calloc<HANDLE>();

    try {
      final hEnum = BluetoothFindFirstRadio(findRadioParams, hRadio);
      if (hEnum == NULL) {
        print('No radios found.');
      } else {
        radioHandles.add(hRadio.value);
        print('Found a radio handle: ${hRadio.value.toHexString(32)}');

        while (BluetoothFindNextRadio(hEnum, hRadio) == TRUE) {
          print('Found a radio handle: ${hRadio.value.toHexString(32)}');
          radioHandles.add(hRadio.value);
        }
      }
      return radioHandles;
    } finally {
      free(findRadioParams);
      free(hRadio);
    }
  }
}
