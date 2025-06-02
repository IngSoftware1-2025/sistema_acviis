import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const PrimaryButton({required this.text, required this.onPressed, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.width ?? double.infinity,
      height: size?.height ?? 48,
      child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
                    if (states.contains(WidgetState.hovered)) return AppColors.primary.withValues(alpha: 25);
                    return AppColors.primary;
                  }),
                  elevation: WidgetStateProperty.resolveWith<double>((states) {
                    if (states.contains(WidgetState.hovered)) return 6;
                    return 2;
                  }),
                  shadowColor: WidgetStateProperty.all(Colors.blueGrey),
                ),
                onPressed: onPressed,
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                  )),
              ),
    );
  }
} 


class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const SecondaryButton({required this.text, required this.onPressed, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.width ?? double.infinity,
      height: size?.height ?? 48,
      child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) return AppColors.primary;
                    return AppColors.primaryDark;
                  }),
                  elevation: WidgetStateProperty.resolveWith<double>((states) {
                    if (states.contains(WidgetState.hovered)) return 6;
                    return 2;
                  }),
                  shadowColor: WidgetStateProperty.all(Colors.blueGrey),
                ),
                onPressed: onPressed,
                child: Text(text),
              ),
    );
  }
} 


class BorderButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const BorderButton({required this.text, required this.onPressed, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.width ?? double.infinity,
      height: size?.height ?? 48,
      child: OutlinedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                  if (states.contains(WidgetState.pressed)) return BorderSide(color: AppColors.primaryDark, width: 3);
                  if (states.contains(WidgetState.hovered)) return const BorderSide(color: AppColors.primaryDark, width: 2);
                  return const BorderSide(color: AppColors.primary, width: 1.5);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) return AppColors.secondary;
                  return AppColors.background;
                }),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
                  if (states.contains(WidgetState.pressed)) return RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.5));
                  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)); // usa el borde por defecto
                }),
              ),
              child: Text(text),
            ),
    );
  }
} 


class BorderButtonBlue extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const BorderButtonBlue({required this.text, required this.onPressed, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.width ?? double.infinity,
      height: size?.height ?? 48,
      child: OutlinedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                  if (states.contains(WidgetState.pressed)) return BorderSide(color: AppColors.background, width: 3);
                  if (states.contains(WidgetState.hovered)) return BorderSide(color: AppColors.background, width: 2);
                  return const BorderSide(color: AppColors.background, width: 1.5);
                }),
                backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
                  if (states.contains(WidgetState.pressed)) return RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.5));
                  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)); // usa el borde por defecto
                }),
              ),
              child: Text(text),
            ),
    );
  }
} 

