import 'package:flutter/material.dart';

class IrregularRoundedRectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();

    // // 左上角
    // path.moveTo(0, size.height * 0.2);
    // path.quadraticBezierTo(0, 0, size.width * 0.2, 0);
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    //
    // // 右上角
    // path.lineTo(size.width, 0);
    // path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);

    //
    // // 右下角
    // path.lineTo(size.width, size.height);
    // path.quadraticBezierTo(
    //     size.width, size.height, size.width * 0.8, size.height);
    path.lineTo(size.width, size.height - 50);
    path.quadraticBezierTo(
        size.width - 20, size.height - 50, size.width - 20, size.height - 50);

    //
    // // 左下角
    // path.lineTo(0, size.height);
    // path.quadraticBezierTo(0, size.height, 0, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class IrregularRoundedRectangle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IrregularRoundedRectanglePainter(),
      size: Size(200, 200),
    );
  }
}
