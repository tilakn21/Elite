import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2330),
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Container(
            width: 320,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search data for this page',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF9BA8B7), size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF9BA8B7), size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 32),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF24344D),
                radius: 20,
                child: Text('J', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
                  Text('Admin', style: TextStyle(fontSize: 11, color: Color(0xFF9BA8B7))),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_drop_down, color: Color(0xFF9BA8B7)),
            ],
          ),
        ],
      ),
    );
  }
}
