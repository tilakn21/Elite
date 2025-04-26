import 'package:flutter/material.dart';
import 'assign_labour_item.dart';

class AssignLabourCard extends StatelessWidget {
  const AssignLabourCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Assign labour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Icon(Icons.more_horiz, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            AssignLabourItem(
              name: 'Jhon Due',
              role: 'Carpenter',
              image: 'assets/images/avatar1.png',
              assigned: false,
            ),
            const SizedBox(height: 12),
            AssignLabourItem(
              name: 'Jana Smith',
              role: 'Welder',
              image: 'assets/images/avatar2.png',
              assigned: true,
            ),
          ],
        ),
      ),
    );
  }
}
