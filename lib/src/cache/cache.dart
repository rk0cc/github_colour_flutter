export 'cache_generic.dart'
    if (dart.library.io) "cache_vm.dart"
    if (dart.library.js_interop) "cache_web.dart";
