import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart'; // If needed for colors

class JobDetailsCardWidget extends ConsumerWidget {
  const JobDetailsCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch actual data or manage state for these details
    final detailsData = [
      {
        'clientName': 'Jim Gorge',
        'address': 'House no. 12, chicago',
      },
      {
        'clientName': 'Jim Gorge',
        'address': 'House no. 12, chicago',
      },
      // Add more items if needed based on actual data
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16.0),

            // Details List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detailsData.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0), // Space between items
              itemBuilder: (context, index) {
                final detail = detailsData[index];
                return _buildDetailItem(
                  context,
                  clientName: detail['clientName']!,
                  address: detail['address']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String clientName,
    required String address,
  }) {
    // Define button color and text color based on your theme or screenshot
    final submitButtonColor =
        const Color(0xFF21C4A7); // Teal color from screenshot
    final submitButtonTextColor = Colors.white;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Text info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align labels and values
                children: [
                  SizedBox(
                    width: 80, // Fixed width for label
                    child: Text(
                      'Client Name',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                  Text(' - ',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  Expanded(
                    child: Text(
                      clientName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align labels and values
                children: [
                  SizedBox(
                    width: 80, // Fixed width for label
                    child: Text(
                      'Address',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                  Text(' - ',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                      // overflow: TextOverflow.ellipsis, // Might not be needed if card expands
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Right side: Buttons
        Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Align buttons vertically
          children: [
            SizedBox(
              height: 30, // Constrain button height
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.cloud_upload_outlined,
                    size: 16, color: Colors.grey[700]),
                label: Text(
                  'Upload Draft',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30, // Constrain button height
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.check_circle_outline,
                    size: 16, color: submitButtonTextColor),
                label: Text(
                  'Submit',
                  style: TextStyle(fontSize: 11, color: submitButtonTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: submitButtonColor,
                  foregroundColor: submitButtonTextColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Adjusted padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  elevation: 0, // Match design
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
