import 'package:church_app1/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MemberPage extends StatefulWidget {
  final List<Map<String, dynamic>> members;

  const MemberPage({Key? key, required this.members}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}
class _MemberPageState extends State<MemberPage> {
  late List<Map<String, dynamic>> _members;
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members); // make a copy so we can modify
  }

  void _deleteMember(int index) async {
    final member = _members[index];
    await _dbHelper.deleteMember(member['id']); // make sure 'id' exists
    setState(() {
      _members.removeAt(index);
    });
  }

  Future<void> _loadMembers() async {
    final dbHelper = DBHelper();
    final allMembers = await dbHelper.getAllMember();
    setState(() {
      members = allMembers;
    });
  }

  Future<void> _updateMember(Map<String, dynamic> member) async {
    final nameController = TextEditingController(text: member['name']);
    final phoneController = TextEditingController(text: member['phone']);
    final addressController = TextEditingController(text: member['address']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            backgroundColor: const Color(0xFFF5EDF8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)),
            title: const Text('Update Member'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value
                          .trim()
                          .isEmpty) {
                        return 'Name is required';
                      } else
                      if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
                        return 'Only alphabets and spaces allowed';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value
                          .trim()
                          .isEmpty) {
                        return 'Phone is required';
                      } else if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                        return 'Enter valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) =>
                    value == null || value
                        .trim()
                        .isEmpty ? 'Address is required' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updated = {
                      'id': member['id'],
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                    };

                    await _dbHelper.updateMember(
                      updated['id'],
                      updated['name'],
                      updated['phone'],
                      updated['address'],
                    );

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('name', updated['name']);
                    await prefs.setString('phone', updated['phone']);
                    await prefs.setString('address', updated['address']);

                    setState(() {
                      _members[_members.indexWhere((m) =>
                      m['id'] == updated['id'])] = updated;
                    });

                    if (context.mounted) {
                      Navigator.pop(context); // close dialog
                    }
                  }
                },
                child: const Text(
                    'Update', style: TextStyle(color: Colors.purple)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                    'Cancel', style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C003E), // Deep purple background
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔼 Custom top bar (Back + Logout)
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    // Add your logout logic here
                    Navigator.pushReplacementNamed(context, '/login'); // adjust route as needed
                  },
                ),
              ],
            ),
          ),

          // 🧾 Main UI below buttons
          Padding(
            padding: const EdgeInsets.only(top: 80), // Push content below buttons
            child: Column(
              children: [
                const Icon(Icons.groups, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Members",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _members.isEmpty
                      ? const Center(
                    child: Text(
                      'No members found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF8E2DE2), // Purple
                                Color(0xFF6C3D91), // Mid-tone
                                Color(0xFF000000),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.white, size: 40),
                            title: Text(
                              "Name: ${member['name']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text("Contact: ${member['phone']}", style: const TextStyle(color: Colors.white)),
                                Text("Address: ${member['address']}", style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _updateMember(member),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteMember(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}