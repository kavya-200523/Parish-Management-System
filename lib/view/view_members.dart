import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewMembersPage extends StatefulWidget {
  const ViewMembersPage({super.key});

  @override
  State<ViewMembersPage> createState() => _ViewMembersPageState();
}

class _ViewMembersPageState extends State<ViewMembersPage> {
  Map<String, String> memberData = {};
  List<Map<String, String>> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';
    final phone = prefs.getString('phone') ?? '';
    final address = prefs.getString('address') ?? '';

    memberData = {
      'Name': name,
      'Phone': phone,
      'Address': address,
    };

    setState(() {
      filteredList = [memberData];
    });
  }

  void _filterMembers(String query) {
    final filtered = [memberData].where((member) {
      final nameMatch =
      member['Name']!.toLowerCase().contains(query.toLowerCase());
      final areaMatch =
      member['Address']!.toLowerCase().contains(query.toLowerCase());
      return nameMatch || areaMatch;
    }).toList();

    setState(() {
      filteredList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Members")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or area',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterMembers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final member = filteredList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(member['Name'] ?? ''),
                    subtitle: Text("Area: ${member['Address'] ?? ''}"),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Phone: ${member['Phone'] ?? ''}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
