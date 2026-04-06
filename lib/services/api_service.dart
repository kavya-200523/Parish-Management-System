import 'dart:convert';
import 'package:church_app1/model/user_model.dart';
import 'package:church_app1/view/list_get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../model/login_response.dart';

class ApiService {
  Future<LoginResponse?> login(String email, String password) async {

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('❌ No internet connection');
    }

    final url = Uri.parse('https://dc530a02-7738-4dfb-b4b5-5250d79c5763.mock.pstmn.io/Api/Login');
    final response = await http.post(
      url,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }


  Future<List<UserModel>> fetchPosts() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
    final response = await http.get(url,headers: {
      'Accept':'application/json',
    },);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }
}
