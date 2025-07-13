import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/models/custom_checkbox.dart';

class PrimaryCheckbox extends StatelessWidget {
  final CustomCheckbox customCheckbox;
  const PrimaryCheckbox({super.key, required this.customCheckbox});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckboxProvider>(
      builder: (context, provider, _) {
        return Checkbox(
          value: customCheckbox.isSelected,
          onChanged: (_) {
            provider.toggleCheckbox(customCheckbox.index);
          },
        );
      },
    );
  }
}