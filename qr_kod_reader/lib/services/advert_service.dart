import 'dart:io';

class AdvertService {
  static String get bannerAdUnitIdMain {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4365766653931652/7011798854';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4365766653931652/7011798854';
    } else {
      throw new UnsupportedError("Unsuppported platform");
    }
  }

  static String get bannerAdUnitIdGenerate {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4365766653931652/2141248576';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4365766653931652/2141248576';
    } else {
      throw new UnsupportedError("Unsuppported platform");
    }
  }
}

// banner test reklam kodu

// ca-app-pub-3940256099942544/6300978111