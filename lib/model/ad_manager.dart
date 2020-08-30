import 'dart:io';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-6269523505662670~5529603286";
    } else if (Platform.isIOS) {
      return "ca-app-pub-6269523505662670~8856628297";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-6269523505662670/2054033333";
    } else if (Platform.isIOS) {
      return "ca-app-pub-6269523505662670/8459675495";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
