export '../unsupported/local_platform.dart'
    if (dart.library.html) '../web/local_platform.dart'
    if (dart.library.io) '../mobile/local_platform.dart';
