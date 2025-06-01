import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF232B3E), size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF232B3E),
                child: Text('J', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
