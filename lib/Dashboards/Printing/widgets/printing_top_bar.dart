import 'package:flutter/material.dart';

class PrintingTopBar extends StatelessWidget {
  const PrintingTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Spacer(),
          // User/logout section
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: Color(0xFF232B3E),
                child: Text('J', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF232B3E))),
                  Text('Admin', style: TextStyle(fontSize: 12, color: Color(0xFF888FA6))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
