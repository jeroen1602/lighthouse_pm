import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MultipleCallbackPopScope extends StatefulWidget {
  const MultipleCallbackPopScope({
    super.key,
    required this.child,
    this.canPop = const [],
  });

  final Widget child;
  final List<CanPop> canPop;

  @override
  State<StatefulWidget> createState() {
    return _MultipleCallbackPopScopeState();
  }
}

class _MultipleCallbackPopScopeState extends State<MultipleCallbackPopScope> {
  @override
  Widget build(final BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (final bool didPop) {
        if (didPop) {
          return;
        }
        for (final canPop in widget.canPop) {
          if (!canPop()) {
            return;
          }
        }
        Navigator.pop(context);
        if (!Navigator.canPop(context)) {
          SystemNavigator.pop(animated: true);
        }
      },
      child: widget.child,
    );
  }
}

typedef CanPop = bool Function();
