import 'package:flutter/material.dart';

class PrimaryCheckbox extends StatefulWidget {
  const PrimaryCheckbox({super.key});

  @override
  State<PrimaryCheckbox> createState() => _PrimaryCheckboxState();
}

class _PrimaryCheckboxState extends State<PrimaryCheckbox> {
  bool _marcada = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _marcada,
      onChanged: (bool? nueva) {
        setState(() {
          _marcada = nueva!;
        });
      },
    );
  }
}