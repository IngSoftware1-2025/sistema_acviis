import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';
import 'package:sistema_acviis/ui/utils/constants/constants.dart';
import 'package:sistema_acviis/ui/views/trabajadores/func/cascade_manager.dart';

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
                    color: AppColors.secondary
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
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.secondary,
                  )),

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
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.textPrimary,
                )),
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
class CascadeButton extends StatefulWidget {
  final double offset;
  final Icon icon;
  final List<Widget> children;
  final List<Widget>? children2;
  final bool? startRight;
  final String title;
  final String? title2; // Nuevo parámetro opcional para el segundo título

  const CascadeButton({
    super.key,
    this.startRight = false,
    required this.title,
    this.title2, // Permite ingresar el segundo título
    required this.offset,
    required this.icon,
    required this.children,
    this.children2,
  });

  @override
  State<CascadeButton> createState() => _CascadeButtonState();
}

class _CascadeButtonState extends State<CascadeButton> with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _abierto = false;
  bool _showChildren2 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cerrarCascada();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (_overlayEntry != null) {
      cerrarCascada();
    }
    super.didChangeMetrics();
  }

  @override
  void deactivate() {
    cerrarCascada();
    super.deactivate();
  }

  void _mostrarCascada() {
    if (!mounted) return;
    if (_overlayEntry != null) {
      cerrarCascada();
      return;
    }

    CascadeManager.instance.register(this);

    final renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;
    final RenderBox renderBox = renderObject;
    final Size screenSize = MediaQuery.of(context).size;

    final double menuWidth = screenSize.width
        - normalPadding * 2
        - renderBox.size.width;

    setState(() {
      _abierto = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: menuWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
            (widget.startRight ?? false)
                ? widget.offset
                : widget.offset - menuWidth + renderBox.size.width,
            renderBox.size.height,
          ),
          child: Material(
            elevation: 4,
            child: Container(
              width: menuWidth,
              color: Colors.white,
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.8,
              ),
              child: StatefulBuilder(
                builder: (context, setStateOverlay) {
                  List<Widget> currentChildren = widget.children2 != null && _showChildren2
                      ? widget.children2!
                      : widget.children;
                  String currentTitle = widget.children2 != null && _showChildren2
                      ? (widget.title2 ?? widget.title)
                      : widget.title;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(normalPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: Text(currentTitle)),
                              if (widget.children2 != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: IconButton(
                                    icon: Icon(_showChildren2 ? Icons.swap_horiz : Icons.swap_horiz_outlined),
                                    tooltip: 'Cambiar vista',
                                    onPressed: () {
                                      setStateOverlay(() {
                                        _showChildren2 = !_showChildren2;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                          Divider(thickness: 1, color: Colors.grey.shade300, height: 24),
                          ...currentChildren,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void cerrarCascada() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _abierto = false;
              _showChildren2 = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: 40,
        height: 40,
        child: ElevatedButton(
          style: _abierto
              ? ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: Size(40, 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    side: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  elevation: 2,
                  backgroundColor: Colors.white,
                ).copyWith(
                  side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
                    return const BorderSide(color: Colors.black, width: 1.5);
                  }),
                  shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
                    return const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    );
                  }),
                )
              : ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: Size(40, 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  elevation: 2,
                  backgroundColor: Colors.white,
                ),
          onPressed: _mostrarCascada,
          child: widget.icon,
        ),
      ),
    );
  }
}