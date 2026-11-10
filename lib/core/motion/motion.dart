import 'package:flutter/widgets.dart';

abstract final class Motion {
  static const quick = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 360);
  static const entrance = Duration(milliseconds: 720);
  static const carousel = Duration(seconds: 5);
  static const curve = Curves.easeOutCubic;
  static Duration duration(BuildContext context, Duration value) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;
}
