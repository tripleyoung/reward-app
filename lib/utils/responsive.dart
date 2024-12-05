import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
}

bool isMobile(BuildContext context) => 
    MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;
bool isTablet(BuildContext context) => 
    MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet &&
    MediaQuery.of(context).size.width < ResponsiveBreakpoints.desktop;
bool isDesktop(BuildContext context) => 
    MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop; 