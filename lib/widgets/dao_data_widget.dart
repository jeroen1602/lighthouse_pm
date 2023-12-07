import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:toast/toast.dart';

import 'dao_delete_alert_widget.dart';

abstract class DaoTableDataConverter<T> {
  String getDataTitle(final T data);

  String getDataSubtitle(final T data);

  Future<void> openChangeDialog(final BuildContext context, final T data);

  Future<void> openAddNewItemDialog(final BuildContext context);

  Future<void> deleteItem(final T item);
}

class DaoTableDataWidget<T> extends StatelessWidget {
  final String tableName;
  final Stream<List<T>> entriesStream;
  final DaoTableDataConverter<T> converter;

  const DaoTableDataWidget(this.tableName, this.entriesStream, this.converter,
      {super.key});

  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: entriesStream,
      builder: (final context, final snapshot) {
        final theme = Theme.of(context);
        final theming = Theming.fromTheme(theme);
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
                    Toast.show('Error: $e',
                        textStyle: theming.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onError),
                        backgroundColor: theme.colorScheme.error,
                        duration: 8);
                  }
                },
                elevation: 2.0,
                fillColor: theming.customColors.booting,
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: Icon(
                  Icons.add,
                  color: theming.customColors.onBooting,
                  size: 24.0,
                )),
          ),
          const Divider(
            thickness: 1.5,
          ),
          if (snapshot.hasError)
            Container(
              color: theme.colorScheme.error,
              child: ListTile(
                title: Text(
                  'Error!',
                  style: theming.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onError),
                ),
                subtitle: Text(snapshot.error.toString(),
                    style: theming.bodyMedium?.copyWith(
                        color: theme.colorScheme.onError.withOpacity(0.75))),
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
                      Toast.show('Error: $e',
                          textStyle: theming.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onError),
                          backgroundColor: theme.colorScheme.error,
                          duration: 8);
                    }
                  },
                  trailing: RawMaterialButton(
                      onPressed: () async {
                        final daoDeleteAlert =
                            DaoDeleteAlertWidget.showCustomDialog(context,
                                title: converter.getDataTitle(data[i]),
                                subTitle: converter.getDataSubtitle(data[i]));
                        if (await daoDeleteAlert) {
                          try {
                            await converter.deleteItem(data[i]);
                            Toast.show('Deleted!');
                          } catch (e, s) {
                            debugPrint('$e');
                            debugPrint('$s');
                            Toast.show('Error: $e',
                                textStyle: theming.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onError),
                                backgroundColor: theme.colorScheme.error,
                                duration: 8);
                          }
                        }
                      },
                      elevation: 2.0,
                      fillColor: theme.colorScheme.error,
                      padding: const EdgeInsets.all(8.0),
                      shape: const CircleBorder(),
                      child: Icon(
                        Icons.delete_forever,
                        color: theme.colorScheme.onError,
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
