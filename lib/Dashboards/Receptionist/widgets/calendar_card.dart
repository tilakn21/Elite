import 'package:flutter/material.dart';
import '../screens/receptionist_calendar_screen.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReceptionistCalendarScreen(),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.white,
        child: Container(
          // constraints: const BoxConstraints.expand(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1B2330))),
                  const SizedBox(height: 18),
                  _CalendarWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // January 2025
    final days = [
      ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'],
      ['01', '02', '03', '04', '05', '06', '07'],
      ['08', '09', '10', '11', '12', '13', '14'],
      ['15', '16', '17', '18', '19', '20', '21'],
      ['22', '23', '24', '25', '26', '27', '28'],
      ['29', '30', '31', '', '', '', ''],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text('January', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A8D9F), fontSize: 15)),
        ),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: days.map((week) {
            return TableRow(
              children: week.map((day) {
                final isToday = day == DateTime.now().day.toString().padLeft(2, '0') && DateTime.now().month == 1 && DateTime.now().year == 2025;
                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Center(
                    child: day.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            decoration: isToday
                                ? BoxDecoration(
                                    color: const Color(0xFF4A6CF7),
                                    borderRadius: BorderRadius.circular(7),
                                  )
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isToday ? Colors.white : const Color(0xFF1B2330),
                                fontSize: 15,
                              ),
                            ),
                          ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
