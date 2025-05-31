export 'branch_stats_card.dart';

import 'package:flutter/material.dart';
import 'branch_stats_card.dart';
import '../models/branch.dart';

class BranchStatsCards extends StatelessWidget {
  final List<Branch> branches;
  final String selectedBranch;
  final int selectedBranchIndex;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<int> onSelect;

  const BranchStatsCards({
    Key? key,
    required this.branches,
    required this.selectedBranch,
    required this.selectedBranchIndex,
    required this.onBranchChanged,
    required this.onSelect,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = 180;
    double dropdownWidth = 110;
    if (screenWidth >= 1200) {
      cardWidth = 260;
      dropdownWidth = 160;
    } else if (screenWidth >= 900) {
      cardWidth = 220;
      dropdownWidth = 140;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Branch Performance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF101C2C),
                      ),
                    ),
                    Text(
                      'Select and compare branch statistics',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline_rounded, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${branches.length} Branches',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: Container(
                  width: dropdownWidth,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1673FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1673FF).withOpacity(0.2)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBranch,
                    borderRadius: BorderRadius.circular(10),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1673FF)),
                    items: branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch.name,
                        child: Text(branch.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: onBranchChanged,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1673FF)),
                  ),
                ),
              ),              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(branches.length, (index) {
                      final branch = branches[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == branches.length - 1 ? 0 : 18),
                        child: BranchStatsCard(
                          branch: branch,
                          selected: selectedBranchIndex == index,
                          onTap: () => onSelect(index),
                          width: cardWidth,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
