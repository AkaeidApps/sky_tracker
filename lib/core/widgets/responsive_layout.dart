import 'package:flutter/material.dart';

/// Responsive breakpoints for the app.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobileMax = 600;
  static const double tabletMax = 1004;
  static const double desktopMin = 1005;
}

/// Extension on BuildContext to easily check the current device type.
extension ResponsiveContext on BuildContext {
  /// Returns true if the current screen width is considered mobile.
  bool get isMobile => MediaQuery.sizeOf(this).width < ResponsiveBreakpoints.mobileMax;

  /// Returns true if the current screen width is considered tablet.
  bool get isTablet {
    final width = MediaQuery.sizeOf(this).width;
    return width >= ResponsiveBreakpoints.mobileMax &&
        width < ResponsiveBreakpoints.tabletMax;
  }

  /// Returns true if the current screen width is considered desktop.
  bool get isDesktop => MediaQuery.sizeOf(this).width >= ResponsiveBreakpoints.desktopMin;

  /// Returns the current screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Returns the current screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Returns a responsive padding based on screen size.
  EdgeInsetsGeometry get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Returns a responsive gutter (horizontal padding) based on screen size.
  double get responsiveGutter {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  /// Returns a responsive font size factor based on screen size.
  double get responsiveFontSizeFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.2;
  }

  /// Returns the maximum content width for centered layouts.
  double get maxContentWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 800;
    return 1200;
  }
}

/// A widget that builds different layouts based on screen size.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    }
    if (context.isTablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// A widget that shows content in a centered, max-width container on larger screens.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = padding ?? context.responsivePadding;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: Padding(
          padding: p,
          child: child,
        ),
      ),
    );
  }
}

/// Returns a responsive grid delegate based on screen size.
SliverGridDelegate responsiveGridDelegate({int mobileCrossAxisCount = 2}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: mobileCrossAxisCount,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.75,
  );
}
