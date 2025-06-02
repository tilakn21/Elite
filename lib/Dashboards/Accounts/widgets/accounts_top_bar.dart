import 'package:flutter/material.dart';

class AccountsTopBar extends StatelessWidget {
  const AccountsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF232B3E),
                child: const Text('J', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E), fontSize: 14)),
                  Text('Admin', style: TextStyle(color: Color(0xFF888FA6), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
