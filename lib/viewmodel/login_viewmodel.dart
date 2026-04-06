import 'package:flutter/material.dart';
import '../model/login_response.dart';
import '../services/api_service.dart';
import 'package:church_app1/utils.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? error;
  LoginResponse? loginResponse;

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    loginResponse = null;
    notifyListeners();

    if (await Utils.isInternetAvailable()) {
      try {
        final response = await _apiService.login(email, password);
        loginResponse = response;
      } catch (e) {
        error = e.toString().replaceAll("Exception: ", "");
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
    else{ error = 'No internet connection';}
  }
}
