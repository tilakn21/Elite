import 'package:flutter/foundation.dart';
// Only import dart:io if not on web
// ignore: avoid_web_libraries_in_flutter
// Use conditional import for Platform
// ignore: uri_does_not_exist
import 'dart:io' show Platform;

bool isWeb() => kIsWeb;
bool isMobile() => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
bool isDesktop() => kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS));
