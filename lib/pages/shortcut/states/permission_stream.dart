import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/permissions_helper/ble_permissions_helper.dart';
import 'package:lighthouse_pm/widgets/close_current_route_mixin.dart';
import 'package:lighthouse_pm/widgets/scanning_mixin.dart';
import 'package:lighthouse_pm/widgets/waterfall_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsStream extends WaterfallStreamWidget<PermissionStatus>
    with ScanningMixin, CloseCurrentRouteMixin {
  PermissionsStream({
    super.key,
    required super.upStream,
    super.downStreamBuilders,
  });

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: BLEPermissionsHelper.hasBLEPermissions(),
      builder: (
        final context,
        final AsyncSnapshot<PermissionStatus> permissionSnapshot,
      ) {
        final permissions = permissionSnapshot.data;
        if (permissions == null) {
          return const Text('Loading...');
        }
        if (permissionSnapshot.data != PermissionStatus.granted) {
          WidgetsBinding.instance.addPostFrameCallback((final _) async {
            await closeCurrentRouteWithWait(context);
          });
          return const Text('Permission has not been given!');
        }
        return buildScanPopScope(
          child: getNextStreamDown(context, permissions),
        );
      },
    );
  }

  static DownStreamBuilder createBuilder() {
    return (final context, final upStream, final downStream) {
      return PermissionsStream(
        upStream: upStream,
        downStreamBuilders: downStream.cast<DownStreamBuilder>(),
      );
    };
  }
}
