import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'DaoDeleteAlertWidget.dart';

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

  DaoTableDataWidget(this.tableName, this.entriesStream, this.converter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: this.entriesStream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        final children = <Widget>[
          ListTile(
            title: Text(tableName),
            subtitle: Text('Entries: ${data?.length ?? 'loading'}'),
            trailing: RawMaterialButton(
                onPressed: () async {
                  await converter.openAddNewItemDialog(context);
                },
                elevation: 2.0,
                fillColor: Colors.orange,
                padding: const EdgeInsets.all(8.0),
                shape: CircleBorder(),
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24.0,
                )),
          ),
          Divider(
            thickness: 1.5,
          ),
        ];

        if (snapshot.hasError) {
          final error = snapshot.error!;
          children.add(ListTile(
            title: Text('Error!'),
            subtitle: Text(error.toString()),
          ));
        } else if (data != null) {
          for (int i = 0; i < data.length; i++) {
            final item = data[i];
            children.addAll([
              ListTile(
                  title: Text(converter.getDataTitle(item)),
                  subtitle: Text(converter.getDataSubtitle(item)),
                  onTap: () async {
                    await converter.openChangeDialog(context, item);
                  },
                  trailing: RawMaterialButton(
                      onPressed: () async {
                        if (await DaoDeleteAlertWidget.showCustomDialog(context,
                            title: converter.getDataTitle(item),
                            subTitle: converter.getDataSubtitle(item))) {
                          await converter.deleteItem(item);
                          Toast.show('Deleted!', context);
                        }
                      },
                      elevation: 2.0,
                      fillColor: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.black,
                        size: 24.0,
                      ))
              ),
              Divider(
                thickness: (i == data.length - 1) ? 2 : null,
              ),
            ]);
          }
        } else {
          children.add(CircularProgressIndicator());
        }

        return Column(children: children);
      },
    );
  }
}
