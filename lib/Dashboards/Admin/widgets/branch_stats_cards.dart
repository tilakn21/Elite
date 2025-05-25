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

    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: Container(
            width: dropdownWidth,
            margin: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: selectedBranch,
              borderRadius: BorderRadius.circular(10),
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF101C2C)),
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch.name,
                  child: Text(branch.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onBranchChanged,
              isExpanded: true,
            ),
          ),
        ),
        Expanded(
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
    );
  }
}
