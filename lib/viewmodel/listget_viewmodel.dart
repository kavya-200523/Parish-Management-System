import 'package:church_app1/services/api_service.dart';
import 'package:church_app1/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:church_app1/utils.dart';

class ListGetViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<UserModel> users = [];
  bool isLoading = false;
  bool hasInternet = true;
  String error ="";


  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();


if (await Utils.hasInternet()) {
  print ("Internet Is Available");
  try {
    users = await _apiService.fetchPosts();
  } catch (e) {

    print("❌ Error fetching users: $e");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
else{
  error = "no internet connection" ;
  print("Internet is Not Available");
  isLoading = false;
  notifyListeners();
}
  }
}