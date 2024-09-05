import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onClearChat;

  const CustomDrawer({super.key, required this.onClearChat});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.network(
                    "https://www.smatbot.com/blog/wp-content/uploads/2018/02/Hi-Animation-without-background-.gif"),
              )),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear All Chat'),
            onTap: () {
              Navigator.pop(context);
              onClearChat();
            },
          ),
        ],
      ),
    );
  }
}
