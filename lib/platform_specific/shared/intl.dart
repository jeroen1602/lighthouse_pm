export '../unsupported/intl.dart'
    if (dart.library.html) '../web/intl.dart'
    if (dart.library.io) '../mobile/intl.dart';
