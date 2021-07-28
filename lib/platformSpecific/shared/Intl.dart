export '../unsupported/Intl.dart'
    if (dart.library.html) '../web/Intl.dart'
    if (dart.library.io) '../io/Intl.dart';
