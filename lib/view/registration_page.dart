import 'package:church_app1/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'login_page.dart';
import 'background_wrapper.dart';
import 'main_menu.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _passwordError;

  void _validateInputs() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Please enter your name'
          : (!RegExp(r'^[a-zA-Z ]+$').hasMatch(_nameController.text.trim())
          ? 'Only alphabets and spaces allowed'
          : null);

      _phoneError = _phoneController.text.length != 10
          ? 'Phone number must be 10 digits'
          : null;

      _addressError = _addressController.text.trim().isEmpty
          ? 'Please enter your address'
          : null;

      _passwordError = _passwordController.text.trim().length < 4
          ? 'Password must be at least 4 characters'
          : null;
    });
  }


  Future<void> _submitForm() async {
    _validateInputs();
    final dbHelper = DBHelper();
    await dbHelper.insertMember(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _addressController.text.trim(),
        _passwordController.text.trim(),
    );

    if (_nameError == null &&
        _phoneError == null &&
        _addressError == null &&
        _passwordError == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('phone', _phoneController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above.')),
      );
    }
  }


  Future<void> getAddressFromLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Location permission denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Location permission permanently denied")),
        );
        await Geolocator.openAppSettings();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Location services are disabled")),
        );
        return;
      }

      // Get current position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        throw Exception("Could not get current position");
      }

      // Ensure position is not null
      if (position == null) {
        throw Exception("Position is null");
      }

      // Get placemark
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception("Address not found");
      }

      final place = placemarks.first;

      String street = place.street ?? '';
      String locality = place.locality ?? '';
      String area = place.administrativeArea ?? '';
      String postal = place.postalCode ?? '';

      String address = "$street, $locality, $area, $postal".trim().replaceAll(RegExp(r'^,|,$'), '');

      if (address.isEmpty) {
        throw Exception("Address fields are empty");
      }

      setState(() {
        _addressController.text = address;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error getting location: ${e.toString()}")),
      );
    }
  }



  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kinship In Christ",
            style: TextStyle(
                color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainMenu()),
            );
          },
        ),
      ),

      extendBodyBehindAppBar: true,
      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/church_icon.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 30),

                // Full Name
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.white),
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    errorText: _nameError,
                  ),
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 20),

                // Phone
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: Colors.white),
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    errorText: _phoneError,
                    counterText: '',
                  ),
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 20),

                // Address
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on, color: Colors.white),
                    labelText: 'Address',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    errorText: _addressError,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: getAddressFromLocation,
                    ),
                  ),
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    errorText: _passwordError,
                  ),
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Navigate to Login
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
