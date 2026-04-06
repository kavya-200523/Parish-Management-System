import 'package:church_app1/db/db_helper.dart';
import 'DonationPage.dart';
import 'member_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_wrapper.dart';
import 'ChurchBulletinPage.dart';
import 'FamilyPage.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '', area = '', contact = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('username') ?? ''; // match login key
      area = prefs.getString('address') ?? '';
      contact = prefs.getString('phone') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Kinship In Christ", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/mainmenu');
            },
          ),
        ],

      ),



     // extendBodyBehindAppBar: true,
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          child: Column(
            children: [
          Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 28,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(area ?? '',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ],
          ),
      ),

              const SizedBox(height: 40),

              // Grid of Cards
              // Vertical Cards (Updated Design)
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _customGradientCard(
                    icon: Icons.group,
                    title: "Members",
                    subtitle: "View all members",
                    color1: Colors.deepPurple,
                    color2: Colors.purple,
                    onPressed: () async {
                      final dbHelper = DBHelper();
                      final members = await dbHelper.getAllMember();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MemberPage(members: members)),
                      );
                      _loadUserDetails();
                    },
                  ),
                  _customGradientCard(
                    icon: Icons.menu_book,
                    title: "Church Bulletin",
                    subtitle: "View events & notices",
                    color1: Colors.pinkAccent,
                    color2: Colors.orangeAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChurchBulletinPage()),
                      );
                    },
                  ),
                  _customGradientCard(
                    icon: Icons.volunteer_activism,
                    title: "Donation",
                    subtitle: "Support the mission",
                    color1: Colors.teal,
                    color2: Colors.green,
                    onPressed: () {
                      Navigator.pushNamed(context, '/donation');
                    },
                  ),
                  _customGradientCard(
                    icon: Icons.family_restroom,
                    title: "Your Family",
                    subtitle: "View or edit details",
                    color1: Colors.indigo,
                    color2: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FamilyPage()),
                      );
                    },
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _customGradientCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCard(IconData icon, String title, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: () async {
        if (title == "Members") {
          final dbHelper = DBHelper();
          final members = await dbHelper.getAllMember();

          if (!mounted) return; // ⛑️ Prevents navigation if widget is disposed

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberPage(members: members),
            ),
          );

          _loadUserDetails(); // 🔄 This can be moved above too, if needed
        }

        if (title == 'Church Bulletin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChurchBulletinPage(),
            ),
          );
        }

        if (title == 'Donation') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonationPage(),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


}
