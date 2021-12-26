import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'dao_delete_alert_widget.dart';

abstract class DaoTableDataConverter<T> {
  String getDataTitle(T data);

  String getDataSubtitle(T data);

  Future<void> openChangeDialog(BuildContext context, T data);

  Future<void> openAddNewItemDialog(BuildContext context);

  Future<void> deleteItem(T item);
}

class DaoTableDataWidget<T> extends StatelessWidget {
  final String tableName;
  final Stream<List<T>> entriesStream;
  final DaoTableDataConverter<T> converter;

  const DaoTableDataWidget(this.tableName, this.entriesStream, this.converter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: entriesStream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        final children = <Widget>[
          ListTile(
            title: Text(tableName),
            subtitle: Text('Entries: ${data?.length ?? 'loading'}'),
            trailing: RawMaterialButton(
                onPressed: () async {
                  try {
                    await converter.openAddNewItemDialog(context);
                  } catch (e, s) {
                    debugPrint('$e');
                    debugPrint('$s');
                    Toast.show('Error: $e', context,
                        backgroundColor: Colors.red, duration: 8);
                  }
                },
                elevation: 2.0,
                fillColor: Colors.orange,
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24.0,
                )),
          ),
          const Divider(
            thickness: 1.5,
          ),
          if (snapshot.hasError)
            Container(
              color: Colors.red,
              child: ListTile(
                title: const Text('Error!'),
                subtitle: Text(snapshot.error.toString()),
              ),
            )
          else if (data != null)
            for (int i = 0; i < data.length; i++) ...[
              ListTile(
                  title: Text(converter.getDataTitle(data[i])),
                  subtitle: Text(converter.getDataSubtitle(data[i])),
                  onTap: () async {
                    try {
                      await converter.openChangeDialog(context, data[i]);
                    } catch (e, s) {
                      debugPrint('$e');
                      debugPrint('$s');
                      Toast.show('Error: $e', context,
                          backgroundColor: Colors.red, duration: 8);
                    }
                  },
                  trailing: RawMaterialButton(
                      onPressed: () async {
                        if (await DaoDeleteAlertWidget.showCustomDialog(context,
                            title: converter.getDataTitle(data[i]),
                            subTitle: converter.getDataSubtitle(data[i]))) {
                          try {
                            await converter.deleteItem(data[i]);
                            Toast.show('Deleted!', context);
                          } catch (e, s) {
                            debugPrint('$e');
                            debugPrint('$s');
                            Toast.show('Error: $e', context,
                                backgroundColor: Colors.red, duration: 8);
                          }
                        }
                      },
                      elevation: 2.0,
                      fillColor: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.black,
                        size: 24.0,
                      ))),
              Divider(
                thickness: (i == data.length - 1) ? 2 : null,
              ),
            ]
          else
            const CircularProgressIndicator(),
        ];

        return Column(children: children);
      },
    );
  }
}
