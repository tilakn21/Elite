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
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFFB0B3C7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search data for this page',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.bar_chart, color: Color(0xFF232B3E)),
          const SizedBox(width: 24),
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
        ],
      ),
    );
  }
}
