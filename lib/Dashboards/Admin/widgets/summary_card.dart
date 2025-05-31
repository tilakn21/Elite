import 'package:flutter/material.dart';

class SummaryCard extends StatefulWidget {
  final String label;
  final int value;
  final Color color;
  final IconData? icon;
  final bool highlight;
  const SummaryCard({Key? key, required this.label, required this.value, required this.color, this.icon, this.highlight = false}) : super(key: key);

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.highlight
        ? widget.color
        : widget.color.withOpacity(0.08);
    Color valueColor = widget.highlight ? Colors.white : widget.color;
    Color labelColor = widget.highlight ? Colors.white70 : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.11 : 0.07),
              blurRadius: _hovering ? 18 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: labelColor, size: 17),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 2,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.value.toString(),
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

