import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxShadow? shadow;

  const RoundedCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
