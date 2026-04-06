import 'package:church_app1/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChurchBulletinPage extends StatefulWidget {
  const ChurchBulletinPage({Key? key}) : super(key: key);

  @override
  State<ChurchBulletinPage> createState() => _ChurchBulletinPageState();
}

class _ChurchBulletinPageState extends State<ChurchBulletinPage> {
  final List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadBulletins();
  }

  Future<void> _loadBulletins() async {
    final dbHelper = DBHelper();
    final allNotice = await dbHelper.getBulletins();
    setState(() {
      _events.clear();
      _events.addAll(allNotice.map((e) => {
        'id': e['id'].toString(),
        'title': e['title'].toString(),
        'date': e['date'].toString(),
        'desc': e['description'].toString(),
        'time': e['time'].toString(),
      }));
    });
  }

  Future<void> UpdateBulletinsDialog(Map<String, dynamic> bulletin) async {
    final titleController = TextEditingController(text: bulletin['title']);
    final descriptionController = TextEditingController(text: bulletin['desc']);
    final dateController = TextEditingController(text: bulletin['date']);
    final timeController = TextEditingController(text: bulletin['time']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Church Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Event Title')),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time'),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    timeController.text = picked.format(context);
                  }
                },
              ),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty ||
                  dateController.text.trim().isEmpty ||
                  timeController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              final dbHelper = DBHelper();
              if (bulletin['id'] == null) {
                await dbHelper.insertBulletins(
                  titleController.text.trim(),
                  dateController.text.trim(),
                  descriptionController.text.trim(),
                  timeController.text.trim(),
                );
              } else {
                await dbHelper.updateBulletins(
                  int.parse(bulletin['id'].toString()),
                  titleController.text.trim(),
                  dateController.text.trim(),
                  descriptionController.text.trim(),
                  timeController.text.trim(),
                );
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('title', titleController.text.trim());
              await prefs.setString('date', dateController.text.trim());
              await prefs.setString('description', descriptionController.text.trim());
              await prefs.setString('time', timeController.text.trim());

              Navigator.pop(context);
              await _loadBulletins();
            },
            child: const Text("Add"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> DeteleBulletins(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbHelper = DBHelper();
      await dbHelper.deleteBulletins(id);
      await _loadBulletins();
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
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
          leading: const Icon(Icons.church, color: Colors.white, size: 40),
          title: Text(
            event['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event['date']} @ ${event['time']}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                event['desc'],
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => UpdateBulletinsDialog(event),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => DeteleBulletins(int.parse(event['id'])),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          UpdateBulletinsDialog({
            'id': null,
            'title': '',
            'desc': '',
            'date': '',
            'time': '', // ✅ make sure time is passed
          });
        },
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Column(
              children: [
                Image.asset('assets/bird_icon.png', height: 150),
                const SizedBox(height: 8),
                const Text(
                  'CHURCH BULLETIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                child: Text(
                  "No events added yet.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(_events[index]['title']),
                        content: Text(_events[index]['desc']),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          )
                        ],
                      ),
                    );
                  },
                  child: _buildEventCard(_events[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
