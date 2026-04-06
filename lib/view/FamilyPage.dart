import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:church_app1/db/db_helper.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({Key? key}) : super(key: key);

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {

  final TextEditingController nameController = TextEditingController();
  String? selectedRelation;

  List<Map<String, String>> familyMembers = [];

  final List<String> relationOptions = [
    'Father', 'Mother', 'Brother', 'Sister', 'Wife', 'Husband', 'Child', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadFamily();
  }

  Future<void> _loadFamily() async {
    final dbHelper = DBHelper();
    final allFamily = await dbHelper.getAllFamily();
    setState(() {
      familyMembers = allFamily.map((e) => {
        'id': e['id'].toString(),
        'name': e['name'].toString(),
        'relationship': e['relationship'].toString(),
      }).toList();
    });
  }

  Future<void> _addOrUpdateFamily({Map<String, String>? member}) async {
    if (member != null) {
      nameController.text = member['name']!;
      selectedRelation = member['relationship'];
    } else {
      nameController.clear();
      selectedRelation = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(member == null ? 'Add Member' : 'Update Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DropdownButtonFormField<String>(
              value: selectedRelation,
              hint: const Text('Select Relationship'),
              items: relationOptions.map((relation) {
                return DropdownMenuItem(
                  value: relation,
                  child: Text(relation),
                );
              }).toList(),
              onChanged: (value) {
                 selectedRelation = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final relation = selectedRelation;

              if (name.isEmpty || relation == null) return;

              final dbHelper = DBHelper();

              if (member == null) {
                await dbHelper.insertFamily(name, relation);
              } else {
                await dbHelper.updateFamily(int.parse(member['id']!), name, relation);
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('name', name);
              await prefs.setString('relationship', relation);

              Navigator.pop(context);
              await _loadFamily();
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              selectedRelation = null;
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFamily(String id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteFamily(int.parse(id));
    await _loadFamily();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Icon(Icons.family_restroom, size: 70, color: Colors.deepPurple[100]!),
                const SizedBox(height: 10),
                Text('Family', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                Expanded(
                  child: familyMembers.isEmpty
                      ? const Center(child: Text("No members added yet."))
                      : ListView.builder(
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyMembers[index];
                      return
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient:  LinearGradient(
                              colors: [Color(0xFF8E2DE2), // Purple
                                Color(0xFF6C3D91), // Mid-tone
                                Color(0xFF000000),],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              member['name']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white54, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  member['relationship']!,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _addOrUpdateFamily(member: member),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteFamily(member['id']!),
                                ),
                              ],
                            ),
                          ),
                        );
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.logout, size: 30, color: Colors.white),
              onPressed: () {
                // Handle logout logic
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateFamily(),
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
