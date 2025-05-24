import 'package:flutter/material.dart';

class BranchStatsCard extends StatelessWidget {
  final Map<String, dynamic> branch;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  const BranchStatsCard({Key? key, required this.branch, required this.selected, required this.onTap, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1673FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: selected ? Border.all(color: const Color(0xFF1673FF), width: 2) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: width ?? 240,
        height: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    branch['name'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF101C2C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Jobs Completed',
                  style: TextStyle(
                    color: selected ? Colors.white70 : const Color(0xFFB0B3C7),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      Text(
                        'Revenue: ',
                        style: TextStyle(
                          color: selected ? Colors.white70 : const Color(0xFFB0B3C7),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          branch['revenue'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: selected ? Colors.greenAccent : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        branch['completed'].toString(),
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF101C2C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Delays: ${branch['delays']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: selected ? Colors.yellowAccent : const Color(0xFFB0B3C7),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
