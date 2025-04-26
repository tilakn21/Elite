import 'package:flutter/material.dart';

class ProductionTopBar extends StatelessWidget {
  const ProductionTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.grey, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search data for this page',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Icon(Icons.bar_chart_outlined, color: Color(0xFF232B3E), size: 26),
          const SizedBox(width: 18),
          Icon(Icons.notifications_none, color: Color(0xFF232B3E), size: 26),
          const SizedBox(width: 18),
          // User info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E))),
                SizedBox(width: 4),
                Text('Admin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(width: 8),
                CircleAvatar(radius: 14, backgroundColor: Color(0xFF232B3E), child: Text('J', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
