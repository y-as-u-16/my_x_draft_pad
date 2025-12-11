import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdUnitIds {
  AdUnitIds._();

  // Test Ad Unit IDs (for development - used as fallback)
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId {
    final envAdUnitId = dotenv.env['ADMOB_BANNER_AD_UNIT_ID'];

    // If environment variable is set and not empty, use it
    if (envAdUnitId != null && envAdUnitId.isNotEmpty) {
      return envAdUnitId;
    }

    // Fallback to test ads
    return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
  }
}