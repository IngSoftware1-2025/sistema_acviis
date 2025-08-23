import 'package:flutter/material.dart';

class VerticalSideBar extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double width;

  const VerticalSideBar({
    super.key,
    required this.items,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          children: items.map((item) {
            return IconButton(
              tooltip: item['title'],
              icon: item['icon'] ?? const Icon(Icons.circle),
              onPressed: item['screen'] != null
                  ? () => Navigator.pushNamed(context, item['screen'])
                  : null,
              iconSize: 32,
              color: Colors.blueGrey,
            );
          }).toList(),
        ),
      ),
    );
  }
}