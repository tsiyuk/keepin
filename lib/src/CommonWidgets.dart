import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header(this.heading);
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content);
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail);
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 8),
            Text(
              detail,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style:
            ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
        onPressed: onPressed,
        child: child,
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
        onPressed: onPressed,
        child: child,
      );
}

class TextH1 extends StatelessWidget {
  const TextH1(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
}

class TextH2 extends StatelessWidget {
  const TextH2(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          str,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          softWrap: true,
        ),
      );
}

class TextH3 extends StatelessWidget {
  const TextH3(this.str, {this.size = 18.0});
  final String str;
  final double size;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w400,
            color: Colors.blueGrey.shade700),
      );
}

class TextH4 extends StatelessWidget {
  const TextH4(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          color: Colors.black54,
        ),
      );
}

Image defaultAvatar(double size) {
  return Image.asset(
    'assets/images/placeholder.png',
    width: size,
    height: size,
    fit: BoxFit.cover,
  );
}

void showError(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.red.shade300,
    content: Text(str),
  ));
}

void showSuccess(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green.shade300,
    content: Text(str),
  ));
}

void showWarning(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.orange.shade300,
    content: Text(str),
  ));
}
