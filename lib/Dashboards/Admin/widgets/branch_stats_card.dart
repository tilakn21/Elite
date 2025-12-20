import 'package:flutter/material.dart';
import '../models/branch.dart';

class BranchStatsCard extends StatelessWidget {
  final Branch branch;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  const BranchStatsCard({Key? key, required this.branch, required this.selected, required this.onTap, this.width}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: selected 
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: selected 
                  ? const Color(0xFF4F46E5).withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: selected ? 16 : 12,
              offset: Offset(0, selected ? 6 : 4),
            ),
          ],
          border: selected 
              ? null 
              : Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        padding: const EdgeInsets.all(20),
        width: width ?? 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with branch name and icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected 
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_city,
                    size: 16,
                    color: selected ? Colors.white : const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    branch.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Revenue section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected 
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.currency_pound,
                    size: 16,
                    color: selected ? Colors.white70 : const Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue',
                          style: TextStyle(
                            color: selected ? Colors.white70 : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch.revenue.startsWith('£') ? branch.revenue : '£${branch.revenue}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: selected ? Colors.white : const Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Stats row
            Row(
              children: [
                // Jobs Completed
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected 
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: selected ? Colors.white70 : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: selected ? Colors.white70 : const Color(0xFFD97706),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          branch.completed.toString(),
                          style: TextStyle(
                            color: selected ? Colors.white : const Color(0xFFD97706),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Delays
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected 
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: selected ? Colors.white70 : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Delays',
                              style: TextStyle(
                                color: selected ? Colors.white70 : const Color(0xFFDC2626),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          branch.delays.toString(),
                          style: TextStyle(
                            color: selected ? Colors.white : const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
