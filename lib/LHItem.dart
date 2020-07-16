import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LHItem extends StatelessWidget {
  LHItem({Key key}) : super(key: key);

  final String name = null;
  final String modelName = 'LH-34q62';
  final int powerState = 0x00;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: AssetImage('assets/images/android.png'),
                fit: BoxFit.fitHeight,
              )),
          Expanded(
              child: Column(children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    Text('${this.name != null ? this.name : this.modelName}',
                        style: Theme.of(context).textTheme.headline4)
                  ],
                )),
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    LHItemPowerStateWidget(powerState: this.powerState),
                    VerticalDivider(),
                    Text('${this.modelName}')
                  ],
                ))
          ])),
          GestureDetector(
            child: LHItemButtonWidget(
              powerState: this.powerState,
            ),
          )
        ]));
  }
}

class LHItemPowerStateWidget extends StatelessWidget {
  LHItemPowerStateWidget({Key key, this.powerState}) : super(key: key);

  final int powerState;

  @override
  Widget build(BuildContext context) {
    var state = LHPowerState.fromByte(this.powerState);
    return Text('${state.text} (0x${powerState.toRadixString(16)})');
  }
}

class LHItemButtonWidget extends StatelessWidget {
  LHItemButtonWidget({Key key, this.powerState}) : super(key: key);
  final int powerState;

  @override
  Widget build(BuildContext context) {
    var state = LHPowerState.fromByte(this.powerState);
    var color = Colors.grey;
    switch (state) {
      case LHPowerState.ON:
        color = Colors.green;
        break;
      case LHPowerState.STAND_BY:
        color = Colors.blue;
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: RawMaterialButton(
          onPressed: () {},
          elevation: 2.0,
          fillColor: Colors.white,
          padding: const EdgeInsets.all(2.0),
          shape: CircleBorder(),
          child: Icon(
            Icons.power_settings_new,
            color: color,
            size: 24.0,
          )),
    );
  }
}

class LHPowerState {
  final String text;

  const LHPowerState._internal(this.text);

  static const STAND_BY = const LHPowerState._internal('Standby');
  static const ON = const LHPowerState._internal('On');
  static const UNKNOWN = const LHPowerState._internal('Unknown');

  static LHPowerState fromByte(int byte) {
    if (byte < 0x0 || byte > 0xff) {
      debugPrint(
          'Byte was lower than 0x00 or higher than 0xff. actual value: 0x${byte.toRadixString(16)}');
    }
    switch (byte) {
      case 0x00:
        return LHPowerState.STAND_BY;
      case 0x01:
        return LHPowerState.ON;
      default:
        return LHPowerState.UNKNOWN;
    }
  }
}
