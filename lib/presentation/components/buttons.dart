import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';


class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.p(context, 20), 
          vertical: Responsive.p(context, 12)
        ),
        minimumSize: Size(0, Responsive.h(context, 40)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Responsive.sp(context, 18)),
            SizedBox(width: Responsive.w(context, 8)),
          ],
          Text(
            label, 
            style: TextStyle(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Responsive.sp(context, 16)),
            SizedBox(width: Responsive.w(context, 8)),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: Responsive.sp(context, 14)),
            ),
          ),
        ],
      ),
    );
  }
}
