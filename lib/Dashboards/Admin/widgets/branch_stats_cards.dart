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
  }) : super(key: key);  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = 320;
    double dropdownWidth = 220;
    int cardsPerRow = 3;
    
    if (screenWidth >= 1600) {
      cardWidth = 350;
      dropdownWidth = 240;
      cardsPerRow = 4;
    } else if (screenWidth >= 1400) {
      cardWidth = 330;
      dropdownWidth = 220;
      cardsPerRow = 3;
    } else if (screenWidth >= 1100) {
      cardWidth = 320;
      dropdownWidth = 200;
      cardsPerRow = 3;
    } else if (screenWidth >= 800) {
      cardWidth = 300;
      dropdownWidth = 180;
      cardsPerRow = 2;
    } else {
      cardWidth = 280;
      dropdownWidth = 160;
      cardsPerRow = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with dropdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                const Color(0xFF8B5CF6).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Branch Performance Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monitor branch statistics and performance metrics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${branches.length} ${branches.length == 1 ? 'Branch' : 'Branches'}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Branch selector dropdown
        if (branches.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                const Text(
                  'Select Branch:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: dropdownWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedBranch,
                      borderRadius: BorderRadius.circular(12),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                        fontSize: 14,
                      ),
                      items: branches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch.name,
                          child: Text(
                            branch.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: onBranchChanged,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Branch cards grid
        if (branches.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Branch Data Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Branch statistics will appear here once data is available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(            builder: (context, constraints) {
              // Calculate how many cards can fit per row
              final availableWidth = constraints.maxWidth;
              final cardSpacing = 24.0; // Increased spacing between cards
              final totalCardWidth = cardWidth + cardSpacing;
              final actualCardsPerRow = (availableWidth / totalCardWidth).floor().clamp(1, cardsPerRow);
              
              // Group cards into rows
              final rows = <List<Branch>>[];
              for (int i = 0; i < branches.length; i += actualCardsPerRow) {
                final end = (i + actualCardsPerRow).clamp(0, branches.length);
                rows.add(branches.sublist(i, end));
              }
              
              return Column(
                children: rows.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final rowBranches = entry.value;
                  
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: rowIndex < rows.length - 1 ? 24 : 0, // Increased row spacing
                    ),
                    child: Row(
                      children: rowBranches.asMap().entries.map((branchEntry) {
                        final cardIndex = (rowIndex * actualCardsPerRow) + branchEntry.key;
                        final branch = branchEntry.value;
                        final isLast = branchEntry.key == rowBranches.length - 1;
                        
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: isLast ? 0 : cardSpacing),
                            child: BranchStatsCard(
                              branch: branch,
                              selected: selectedBranchIndex == cardIndex,
                              onTap: () => onSelect(cardIndex),
                              width: cardWidth,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
