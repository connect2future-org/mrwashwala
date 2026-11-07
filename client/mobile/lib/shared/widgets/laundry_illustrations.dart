import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum LaundryIllustrationType {
  washingMachine,
  foldedTowels,
  shirtOnHanger,
  tshirt,
  jeans,
  laundryBasket,
  sneakers,
  handHoldingPhone,
  deliveryPerson,
  orderSuccess,
  calendarPlan,
  userAvatar,
  iron,
}

class LaundryIllustration extends StatelessWidget {
  final LaundryIllustrationType type;
  final double size;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;

  const LaundryIllustration({
    super.key,
    required this.type,
    this.size = 80,
    this.strokeColor = AppColors.cobaltBlue,
    this.fillColor,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LaundryIllustrationPainter(
        type: type,
        strokeColor: strokeColor,
        fillColor: fillColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _LaundryIllustrationPainter extends CustomPainter {
  final LaundryIllustrationType type;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;

  _LaundryIllustrationPainter({
    required this.type,
    required this.strokeColor,
    this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (size.width / 80.0).clamp(0.8, 2.5)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor ?? strokeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    switch (type) {
      case LaundryIllustrationType.washingMachine:
        _drawWashingMachine(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.foldedTowels:
        _drawFoldedTowels(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.shirtOnHanger:
        _drawShirtOnHanger(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.tshirt:
        _drawTShirt(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.jeans:
        _drawJeans(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.laundryBasket:
        _drawLaundryBasket(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.sneakers:
        _drawSneakers(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.handHoldingPhone:
        _drawHandHoldingPhone(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.deliveryPerson:
        _drawDeliveryPerson(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.orderSuccess:
        _drawOrderSuccess(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.calendarPlan:
        _drawCalendarPlan(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.userAvatar:
        _drawUserAvatar(canvas, size, strokePaint, fillPaint);
        break;
      case LaundryIllustrationType.iron:
        _drawIron(canvas, size, strokePaint, fillPaint);
        break;
    }
  }

  void _drawWashingMachine(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.70, h * 0.72),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(bodyRRect, fill);
    canvas.drawRRect(bodyRRect, stroke);

    // Control panel top line
    canvas.drawLine(
      Offset(w * 0.15, h * 0.38),
      Offset(w * 0.85, h * 0.38),
      stroke,
    );

    // Control dials/buttons
    canvas.drawCircle(Offset(w * 0.72, h * 0.30), w * 0.045, stroke);
    canvas.drawCircle(Offset(w * 0.58, h * 0.30), w * 0.025, stroke);
    canvas.drawCircle(Offset(w * 0.48, h * 0.30), w * 0.025, stroke);
    // Dispenser drawer
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.27, w * 0.18, h * 0.06),
        Radius.circular(w * 0.015),
      ),
      stroke,
    );

    // Drum outer door
    canvas.drawCircle(Offset(w * 0.50, h * 0.64), w * 0.22, stroke);
    // Drum inner window
    canvas.drawCircle(Offset(w * 0.50, h * 0.64), w * 0.16, stroke);
    // Water wave inside drum
    final wavePath = Path();
    wavePath.moveTo(w * 0.38, h * 0.66);
    wavePath.quadraticBezierTo(w * 0.44, h * 0.61, w * 0.50, h * 0.66);
    wavePath.quadraticBezierTo(w * 0.56, h * 0.71, w * 0.62, h * 0.66);
    canvas.drawPath(wavePath, stroke);

    // Floating soap bubbles on top
    canvas.drawCircle(Offset(w * 0.25, h * 0.15), w * 0.05, stroke);
    canvas.drawCircle(Offset(w * 0.18, h * 0.18), w * 0.03, stroke);
    canvas.drawCircle(Offset(w * 0.75, h * 0.12), w * 0.06, stroke);
    canvas.drawCircle(Offset(w * 0.84, h * 0.17), w * 0.035, stroke);

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.45), w * 0.04, stroke);
    _drawSparkle(canvas, Offset(w * 0.12, h * 0.55), w * 0.035, stroke);
  }

  void _drawFoldedTowels(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Stack of 3 folded towels
    for (int i = 0; i < 3; i++) {
      final yOffset = h * (0.32 + i * 0.20);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, yOffset, w * 0.76, h * 0.18),
        Radius.circular(w * 0.06),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);

      // Towel fold inner crease line
      canvas.drawLine(
        Offset(w * 0.22, yOffset + h * 0.09),
        Offset(w * 0.78, yOffset + h * 0.09),
        stroke,
      );
    }

    // Top subtle laundry basket/ribbon line
    canvas.drawLine(
      Offset(w * 0.40, h * 0.32),
      Offset(w * 0.60, h * 0.32),
      stroke,
    );

    // Sparkles & bubbles around clean clothes
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.20), w * 0.05, stroke);
    _drawSparkle(canvas, Offset(w * 0.16, h * 0.22), w * 0.04, stroke);
    canvas.drawCircle(Offset(w * 0.28, h * 0.18), w * 0.035, stroke);
    canvas.drawCircle(Offset(w * 0.70, h * 0.15), w * 0.045, stroke);
  }

  void _drawShirtOnHanger(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Hanger hook
    final hookPath = Path();
    hookPath.moveTo(w * 0.50, h * 0.12);
    hookPath.quadraticBezierTo(w * 0.50, h * 0.05, w * 0.55, h * 0.05);
    hookPath.quadraticBezierTo(w * 0.60, h * 0.05, w * 0.60, h * 0.10);
    hookPath.lineTo(w * 0.50, h * 0.16);
    canvas.drawPath(hookPath, stroke);

    // Hanger triangle
    final hangerPath = Path();
    hangerPath.moveTo(w * 0.50, h * 0.16);
    hangerPath.lineTo(w * 0.24, h * 0.28);
    hangerPath.lineTo(w * 0.76, h * 0.28);
    hangerPath.close();
    canvas.drawPath(hangerPath, stroke);

    // Shirt Body
    final shirtPath = Path();
    // Collar left
    shirtPath.moveTo(w * 0.42, h * 0.22);
    shirtPath.lineTo(w * 0.47, h * 0.30);
    shirtPath.lineTo(w * 0.50, h * 0.25);
    // Collar right
    shirtPath.lineTo(w * 0.53, h * 0.30);
    shirtPath.lineTo(w * 0.58, h * 0.22);
    // Shoulder right
    shirtPath.lineTo(w * 0.82, h * 0.32);
    // Sleeve right
    shirtPath.lineTo(w * 0.76, h * 0.52);
    shirtPath.lineTo(w * 0.68, h * 0.47);
    // Body right
    shirtPath.lineTo(w * 0.68, h * 0.90);
    // Bottom hem
    shirtPath.quadraticBezierTo(w * 0.50, h * 0.94, w * 0.32, h * 0.90);
    // Body left
    shirtPath.lineTo(w * 0.32, h * 0.47);
    // Sleeve left
    shirtPath.lineTo(w * 0.24, h * 0.52);
    shirtPath.lineTo(w * 0.18, h * 0.32);
    shirtPath.close();

    canvas.drawPath(shirtPath, fill);
    canvas.drawPath(shirtPath, stroke);

    // Button Placket center line
    canvas.drawLine(
      Offset(w * 0.50, h * 0.30),
      Offset(w * 0.50, h * 0.92),
      stroke,
    );

    // Buttons
    canvas.drawCircle(Offset(w * 0.50, h * 0.40), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.54), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.68), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.82), w * 0.015, stroke);

    // Pocket on left chest
    final pocket = Path();
    pocket.moveTo(w * 0.37, h * 0.42);
    pocket.lineTo(w * 0.44, h * 0.42);
    pocket.lineTo(w * 0.44, h * 0.52);
    pocket.lineTo(w * 0.405, h * 0.55);
    pocket.lineTo(w * 0.37, h * 0.52);
    pocket.close();
    canvas.drawPath(pocket, stroke);

    // Crease sketch lines
    canvas.drawLine(Offset(w * 0.62, h * 0.58), Offset(w * 0.60, h * 0.72), stroke);
    _drawSparkle(canvas, Offset(w * 0.84, h * 0.60), w * 0.035, stroke);
  }

  void _drawTShirt(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    final p = Path();
    p.moveTo(w * 0.36, h * 0.18);
    // Collar
    p.quadraticBezierTo(w * 0.50, h * 0.26, w * 0.64, h * 0.18);
    // Right shoulder
    p.lineTo(w * 0.86, h * 0.30);
    // Right sleeve
    p.lineTo(w * 0.78, h * 0.48);
    p.lineTo(w * 0.68, h * 0.42);
    // Right body
    p.lineTo(w * 0.68, h * 0.88);
    // Bottom
    p.quadraticBezierTo(w * 0.50, h * 0.90, w * 0.32, h * 0.88);
    // Left body
    p.lineTo(w * 0.32, h * 0.42);
    // Left sleeve
    p.lineTo(w * 0.22, h * 0.48);
    p.lineTo(w * 0.14, h * 0.30);
    p.close();

    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);

    // Collar inner curve
    final collarInner = Path();
    collarInner.moveTo(w * 0.38, h * 0.18);
    collarInner.quadraticBezierTo(w * 0.50, h * 0.24, w * 0.62, h * 0.18);
    canvas.drawPath(collarInner, stroke);

    // Sleeve fold lines
    canvas.drawLine(Offset(w * 0.25, h * 0.44), Offset(w * 0.21, h * 0.35), stroke);
    canvas.drawLine(Offset(w * 0.75, h * 0.44), Offset(w * 0.79, h * 0.35), stroke);

    // Fold creases
    canvas.drawLine(Offset(w * 0.45, h * 0.55), Offset(w * 0.47, h * 0.70), stroke);
  }

  void _drawJeans(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Waistband
    final waist = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.16, w * 0.50, h * 0.10),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(waist, stroke);

    // Belt loops
    canvas.drawLine(Offset(w * 0.32, h * 0.16), Offset(w * 0.32, h * 0.26), stroke);
    canvas.drawLine(Offset(w * 0.50, h * 0.16), Offset(w * 0.50, h * 0.26), stroke);
    canvas.drawLine(Offset(w * 0.68, h * 0.16), Offset(w * 0.68, h * 0.26), stroke);

    // Pants outline
    final p = Path();
    p.moveTo(w * 0.25, h * 0.26);
    // Left outer leg
    p.lineTo(w * 0.20, h * 0.88);
    // Left cuff
    p.lineTo(w * 0.38, h * 0.88);
    // Crotch
    p.lineTo(w * 0.49, h * 0.52);
    // Right cuff
    p.lineTo(w * 0.62, h * 0.88);
    // Right outer leg
    p.lineTo(w * 0.80, h * 0.88);
    p.lineTo(w * 0.75, h * 0.26);
    p.close();

    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);

    // Fly seam
    final fly = Path();
    fly.moveTo(w * 0.50, h * 0.26);
    fly.lineTo(w * 0.50, h * 0.42);
    fly.quadraticBezierTo(w * 0.50, h * 0.46, w * 0.46, h * 0.47);
    canvas.drawPath(fly, stroke);

    // Pockets
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.31, h * 0.28), radius: w * 0.08),
      0,
      math.pi / 2,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.69, h * 0.28), radius: w * 0.08),
      math.pi / 2,
      math.pi / 2,
      false,
      stroke,
    );

    // Cuffs
    canvas.drawLine(Offset(w * 0.20, h * 0.84), Offset(w * 0.38, h * 0.84), stroke);
    canvas.drawLine(Offset(w * 0.62, h * 0.84), Offset(w * 0.80, h * 0.84), stroke);
  }

  void _drawLaundryBasket(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Basket trapezoid body
    final basket = Path();
    basket.moveTo(w * 0.16, h * 0.42);
    basket.lineTo(w * 0.24, h * 0.88);
    basket.lineTo(w * 0.76, h * 0.88);
    basket.lineTo(w * 0.84, h * 0.42);
    basket.close();

    canvas.drawPath(basket, fill);
    canvas.drawPath(basket, stroke);

    // Basket rim
    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.38, w * 0.76, h * 0.08),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(rim, stroke);

    // Basket handles
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.12, h * 0.50), radius: w * 0.05),
      -math.pi / 2,
      math.pi,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.88, h * 0.50), radius: w * 0.05),
      math.pi / 2,
      math.pi,
      false,
      stroke,
    );

    // Clothes mounded on top
    final clothes = Path();
    clothes.moveTo(w * 0.18, h * 0.38);
    clothes.quadraticBezierTo(w * 0.28, h * 0.20, w * 0.44, h * 0.26);
    clothes.quadraticBezierTo(w * 0.54, h * 0.16, w * 0.68, h * 0.24);
    clothes.quadraticBezierTo(w * 0.80, h * 0.28, w * 0.82, h * 0.38);
    canvas.drawPath(clothes, stroke);

    // Basket weave / holes
    for (double y = 0.52; y <= 0.78; y += 0.12) {
      for (double x = 0.28; x <= 0.70; x += 0.14) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * x, h * y, w * 0.07, h * 0.06),
            Radius.circular(w * 0.02),
          ),
          stroke,
        );
      }
    }

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.85, h * 0.20), w * 0.045, stroke);
  }

  void _drawSneakers(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Sole
    final sole = Path();
    sole.moveTo(w * 0.12, h * 0.72);
    sole.lineTo(w * 0.88, h * 0.72);
    sole.quadraticBezierTo(w * 0.90, h * 0.80, w * 0.82, h * 0.82);
    sole.lineTo(w * 0.16, h * 0.82);
    sole.quadraticBezierTo(w * 0.10, h * 0.78, w * 0.12, h * 0.72);
    canvas.drawPath(sole, fill);
    canvas.drawPath(sole, stroke);

    // Shoe upper body
    final upper = Path();
    upper.moveTo(w * 0.12, h * 0.72);
    // Heel
    upper.quadraticBezierTo(w * 0.14, h * 0.42, w * 0.26, h * 0.40);
    // Collar
    upper.quadraticBezierTo(w * 0.36, h * 0.46, w * 0.46, h * 0.44);
    // Tongue & eyelets
    upper.lineTo(w * 0.65, h * 0.54);
    // Toe cap
    upper.quadraticBezierTo(w * 0.85, h * 0.60, w * 0.88, h * 0.72);
    upper.close();

    canvas.drawPath(upper, fill);
    canvas.drawPath(upper, stroke);

    // Toe cap line
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.80, h * 0.68), radius: w * 0.12),
      math.pi * 0.8,
      math.pi * 0.5,
      false,
      stroke,
    );

    // Laces
    canvas.drawLine(Offset(w * 0.46, h * 0.46), Offset(w * 0.54, h * 0.50), stroke);
    canvas.drawLine(Offset(w * 0.50, h * 0.50), Offset(w * 0.58, h * 0.54), stroke);
    canvas.drawLine(Offset(w * 0.54, h * 0.54), Offset(w * 0.62, h * 0.58), stroke);

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.84, h * 0.35), w * 0.045, stroke);
    _drawSparkle(canvas, Offset(w * 0.20, h * 0.25), w * 0.035, stroke);
  }

  void _drawHandHoldingPhone(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Phone body
    final phone = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.36, h * 0.10, w * 0.48, h * 0.75),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(phone, fill);
    canvas.drawRRect(phone, stroke);

    // Screen content (123456 pill)
    final otpPill = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.25, w * 0.32, h * 0.10),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(otpPill, stroke);

    // Dots/numbers representation inside pill
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(w * (0.47 + i * 0.052), h * 0.30), w * 0.012, stroke);
    }

    // Hand holding phone (sketch palm & fingers on left side)
    final hand = Path();
    hand.moveTo(w * 0.18, h * 0.85);
    hand.lineTo(w * 0.26, h * 0.65);
    // Index finger
    hand.quadraticBezierTo(w * 0.28, h * 0.42, w * 0.40, h * 0.42);
    // Finger grip on edge
    hand.lineTo(w * 0.40, h * 0.48);
    hand.lineTo(w * 0.34, h * 0.50);
    // Middle finger
    hand.lineTo(w * 0.40, h * 0.54);
    hand.lineTo(w * 0.40, h * 0.60);
    hand.lineTo(w * 0.34, h * 0.62);
    // Ring finger
    hand.lineTo(w * 0.40, h * 0.66);
    hand.lineTo(w * 0.40, h * 0.72);
    hand.lineTo(w * 0.32, h * 0.74);
    // Palm bottom
    hand.lineTo(w * 0.28, h * 0.90);
    canvas.drawPath(hand, stroke);

    // Screen home indicator
    canvas.drawLine(Offset(w * 0.52, h * 0.80), Offset(w * 0.68, h * 0.80), stroke);
  }

  void _drawDeliveryPerson(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.08, stroke);
    // Friendly hair cap
    final hair = Path();
    hair.moveTo(w * 0.42, h * 0.19);
    hair.quadraticBezierTo(w * 0.50, h * 0.11, w * 0.58, h * 0.17);
    canvas.drawPath(hair, stroke);

    // Torso / shirt
    final torso = Path();
    torso.moveTo(w * 0.46, h * 0.28);
    torso.lineTo(w * 0.40, h * 0.52);
    torso.lineTo(w * 0.56, h * 0.52);
    torso.lineTo(w * 0.54, h * 0.28);
    torso.close();
    canvas.drawPath(torso, stroke);

    // Laundry basket in hands
    final basket = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.50, h * 0.36, w * 0.36, h * 0.20),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(basket, fill);
    canvas.drawRRect(basket, stroke);
    // Clean clothes mound
    final mound = Path();
    mound.moveTo(w * 0.52, h * 0.36);
    mound.quadraticBezierTo(w * 0.68, h * 0.28, w * 0.84, h * 0.36);
    canvas.drawPath(mound, stroke);

    // Arms holding basket
    canvas.drawLine(Offset(w * 0.42, h * 0.35), Offset(w * 0.52, h * 0.45), stroke);

    // Walking legs
    canvas.drawLine(Offset(w * 0.44, h * 0.52), Offset(w * 0.36, h * 0.78), stroke);
    canvas.drawLine(Offset(w * 0.36, h * 0.78), Offset(w * 0.30, h * 0.88), stroke); // Left foot

    canvas.drawLine(Offset(w * 0.52, h * 0.52), Offset(w * 0.60, h * 0.75), stroke);
    canvas.drawLine(Offset(w * 0.60, h * 0.75), Offset(w * 0.68, h * 0.86), stroke); // Right foot

    // Sparkles & motion
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.25), w * 0.04, stroke);
    _drawSparkle(canvas, Offset(w * 0.18, h * 0.40), w * 0.035, stroke);
  }

  void _drawOrderSuccess(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Glowing clean laundry basket overflowing with pristine clothes
    _drawLaundryBasket(canvas, size, stroke, fill);

    // Big radiating stars / sparkles
    _drawSparkle(canvas, Offset(w * 0.18, h * 0.22), w * 0.07, stroke);
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.18), w * 0.08, stroke);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.65), w * 0.06, stroke);
    _drawSparkle(canvas, Offset(w * 0.12, h * 0.68), w * 0.05, stroke);

    // Bubbles
    canvas.drawCircle(Offset(w * 0.30, h * 0.12), w * 0.04, stroke);
    canvas.drawCircle(Offset(w * 0.70, h * 0.10), w * 0.035, stroke);
  }

  void _drawCalendarPlan(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Calendar page
    final cal = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.25, w * 0.60, h * 0.62),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(cal, fill);
    canvas.drawRRect(cal, stroke);

    // Calendar top binding / rings
    canvas.drawLine(Offset(w * 0.20, h * 0.38), Offset(w * 0.80, h * 0.38), stroke);
    canvas.drawLine(Offset(w * 0.35, h * 0.18), Offset(w * 0.35, h * 0.27), stroke);
    canvas.drawLine(Offset(w * 0.65, h * 0.18), Offset(w * 0.65, h * 0.27), stroke);

    // Calendar grid lines & checkmark
    for (double y = 0.50; y <= 0.75; y += 0.12) {
      canvas.drawLine(Offset(w * 0.28, h * y), Offset(w * 0.72, h * y), stroke);
    }
    // Checkmark inside calendar
    final check = Path();
    check.moveTo(w * 0.38, h * 0.60);
    check.lineTo(w * 0.46, h * 0.68);
    check.lineTo(w * 0.62, h * 0.52);
    canvas.drawPath(check, stroke);

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.85, h * 0.22), w * 0.05, stroke);
    _drawSparkle(canvas, Offset(w * 0.14, h * 0.45), w * 0.04, stroke);
  }

  void _drawUserAvatar(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Circle frame
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.44, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.44, stroke);

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.36), w * 0.16, stroke);
    // Hair
    final hair = Path();
    hair.moveTo(w * 0.36, h * 0.34);
    hair.quadraticBezierTo(w * 0.50, h * 0.18, w * 0.64, h * 0.30);
    canvas.drawPath(hair, stroke);

    // Shoulders
    final shoulders = Path();
    shoulders.moveTo(w * 0.22, h * 0.78);
    shoulders.quadraticBezierTo(w * 0.34, h * 0.58, w * 0.50, h * 0.58);
    shoulders.quadraticBezierTo(w * 0.66, h * 0.58, w * 0.78, h * 0.78);
    canvas.drawPath(shoulders, stroke);
  }

  void _drawIron(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Iron soleplate & body
    final iron = Path();
    iron.moveTo(w * 0.18, h * 0.72);
    iron.lineTo(w * 0.70, h * 0.72);
    iron.quadraticBezierTo(w * 0.85, h * 0.72, w * 0.85, h * 0.62);
    iron.lineTo(w * 0.55, h * 0.45);
    iron.lineTo(w * 0.18, h * 0.45);
    iron.close();

    canvas.drawPath(iron, fill);
    canvas.drawPath(iron, stroke);

    // Iron handle
    final handle = Path();
    handle.moveTo(w * 0.25, h * 0.45);
    handle.lineTo(w * 0.25, h * 0.28);
    handle.lineTo(w * 0.65, h * 0.28);
    handle.lineTo(w * 0.65, h * 0.45);
    canvas.drawPath(handle, stroke);

    // Dial
    canvas.drawCircle(Offset(w * 0.40, h * 0.52), w * 0.05, stroke);

    // Steam puffs below
    canvas.drawLine(Offset(w * 0.25, h * 0.80), Offset(w * 0.25, h * 0.88), stroke);
    canvas.drawLine(Offset(w * 0.45, h * 0.80), Offset(w * 0.45, h * 0.88), stroke);
    canvas.drawLine(Offset(w * 0.65, h * 0.80), Offset(w * 0.65, h * 0.88), stroke);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final p = Path();
    p.moveTo(center.dx, center.dy - radius);
    p.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    p.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    p.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    p.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant _LaundryIllustrationPainter old) {
    return old.type != type ||
        old.strokeColor != strokeColor ||
        old.fillColor != fillColor ||
        old.strokeWidth != strokeWidth;
  }
}
