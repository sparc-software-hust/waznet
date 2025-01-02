import 'package:flutter/material.dart';

class ConfirmCard extends StatelessWidget {
  const ConfirmCard({
    super.key,
    this.user,
    this.bigIcon,
    required this.title,
    required this.subtitle,
    required this.dangerousTextInButton,
    this.onClick,
  });

  final Map? user;
  final Widget? bigIcon;
  final String title;
  final String subtitle;
  final String dangerousTextInButton;
  final VoidCallback? onClick;

  // use with showDialog, showCupertinoDialog

  @override
  Widget build(BuildContext context) {
    const Color backgroundColorHeader = Colors.white;
    const Color colorBackButton =  Color(0xFF1D2939);

    return Material(
      color : Colors.transparent,
      child: Dialog(
        child: Wrap(
          children: [
            Container(
              // height: 270,
              width: 327,
              decoration: BoxDecoration(
                color: backgroundColorHeader,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
              child: Column(children: [
                // else if (bigIcon != null) bigIcon!
                // else Container(),

                const SizedBox(height: 14),

                Text(title,
                  style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 12),
                Text(subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF667085)
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 44,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onClick != null) {
                        onClick!.call();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(Color(0xFFFF3048)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10))
                    ),
                    child: Text(dangerousTextInButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )
                    )
                  )
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 44,
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10))
                    ),
                    child: const Text("Hủy",
                      style: TextStyle(
                          color: colorBackButton,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                      )
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
