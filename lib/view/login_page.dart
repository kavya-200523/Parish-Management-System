import 'dart:core';
import 'package:church_app1/db/db_helper.dart';
import 'package:church_app1/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'background_wrapper.dart';
import 'main_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorText;

  Future<void> _login(LoginViewModel viewmodel) async {
    final dbHelper = DBHelper();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

   /* final user = await dbHelper.getUserByNameAndPassword(name, password);

    if (user != null) {

      print("db get $user['name']  edittext enter $name");

      if (user['name'] == name){

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', name);
        await prefs.setString('password', password);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );

      }



    } else {
      setState(() {
        _errorText = 'Invalid name or password';
      });
    }*/

    await viewmodel.login(name, password);

    if(!context.mounted) return;

    final response = viewmodel.loginResponse;
    if (response!= null && response.status){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success: ${response.token}")),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', name);
      await prefs.setString('password', password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _errorText = 'Login failed. Try again.';
      });
    }

  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
        builder: (context, viewModel, child)
    {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Kinship In Christ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,

              ),

            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainMenu()),
                );
              },
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
              children: [
                BackgroundWrapper(
                  child: Center(
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[800]!, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/church_icon.png',
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Username",
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.person, color: Colors
                                  .white),
                              filled: true,
                              fillColor: Colors.white10,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock, color: Colors
                                  .white),
                              filled: true,
                              fillColor: Colors.white10,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                final viewModel =
                                Provider.of<LoginViewModel>(context,
                                    listen: false);

                                _login(viewModel);
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),


                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                          ),
                        if (_errorText != null)
                        Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),




                ]),

                      ),
                    ),
                  ),


                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ]
          )
      );
    }
    );
  }
}
