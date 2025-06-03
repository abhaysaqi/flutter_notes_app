import 'package:flutter/material.dart';
import 'package:notes_app/ui/styles/text_styles.dart';

class MyIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;
  final String txt;

  const MyIconButton({
    super.key,
    this.icon,
    required this.onTap,
    this.txt = "",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: icon != null ? 44 : 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, color: Colors.white)
                  : Text(txt, style: titleTextStyle.copyWith(fontSize: 18)),
        ),
      ),
    );
  }
}
