import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget {
  final bool showHamburger;
  final VoidCallback? onHamburgerTap;

  const AdminTopBar({
    Key? key,
    this.showHamburger = false,
    this.onHamburgerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          if (showHamburger)
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF232B3E), size: 28),
              onPressed: onHamburgerTap,
            )
          else
            const SizedBox(width: 32),
          const Spacer(),
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
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF232B3E))),
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
