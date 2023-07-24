import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class InternetProvider extends GetxController {
  bool _hasInternet = false;
  bool get hasInternet => _hasInternet;

  InternetProvider() {
    checkInternetConnection();
  }

  Future checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _hasInternet = false;
    } else {
      _hasInternet = true;
    }
    update();
  }
}
