import 'dart:io';

bool isMobile() => Platform.isAndroid || Platform.isIOS;
bool isDesktop() => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
