export '../unsupported/LocalPlatform.dart'
    if (dart.library.html) '../web/LocalPlatform.dart'
    if (dart.library.io) '../mobile/LocalPlatform.dart';
