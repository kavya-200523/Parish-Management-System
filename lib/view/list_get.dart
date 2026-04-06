import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/listget_viewmodel.dart';

class ListGet extends StatefulWidget {
  const ListGet({super.key});

  @override
  State<ListGet> createState() => _UserListViewState();
}

class _UserListViewState extends State<ListGet> {
  @override
  void initState() {
    super.initState();

    Provider.of<ListGetViewModel>(context, listen: false).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ListGetViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.users.isNotEmpty
          ? ListView.builder(
        itemCount: vm.users.length,
        itemBuilder: (context, index) {
          final user = vm.users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text("${user.email}\n${user.company.name}"),
            isThreeLine: true,
          );
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              vm.error,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                vm.loadUsers(); // retry
              },
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}
