import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.color,
    this.boxShadow,
    this.padding,
    this.boxConstraints,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.child,
    this.margin,
    this.image,
  });
  final EdgeInsets? margin;
  final BoxConstraints? boxConstraints;
  final EdgeInsets? padding;
  final Color? color;
  final Widget? child;
  final double? borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double? borderWidth;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final DecorationImage? image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        constraints: boxConstraints,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
            image: image,
            boxShadow: boxShadow,
            border: Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth ?? 0),
            color: color,
            borderRadius: BorderRadius.circular(borderRadius ?? 0)),
        child: child,
      ),
    );
  }
}
