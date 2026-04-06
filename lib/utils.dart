import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:io';

class Utils {
  /// Checks if any network (Wi-Fi or Mobile) is connected
  static Future<bool> isNetworkConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Checks if the device is connected to Wi-Fi
  static Future<bool> isWifiConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }

  /// Checks if actual internet is available by pinging a domain
  static Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// Combines network + actual internet check
  static Future<bool> hasInternet() async {
    if (await isNetworkConnected()) {
      return await isInternetAvailable();
    }
    return false;
  }
}