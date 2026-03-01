import 'package:flutter/material.dart';
import 'custom_route_transitions.dart';

/// Enum để chọn loại animation khi chuyển màn hình
enum TransitionType {
  fade,
  slideRight,
  scaleFade,
  sharedAxisVertical,
  rotateFade,
}

/// Lớp hỗ trợ navigation với animation và truyền dữ liệu
class NavigationHelper {
  /// Chuyển tới màn hình với animation và có thể truyền dữ liệu
  static Future<T?> navigateTo<T>(
    BuildContext context,
    WidgetBuilder builder, {
    TransitionType transitionType = TransitionType.scaleFade,
    Duration duration = const Duration(milliseconds: 500),
    bool replace = false,
  }) {
    final route = _getCustomRoute<T>(
      builder: builder,
      transitionType: transitionType,
      duration: duration,
    );

    if (replace) {
      return Navigator.of(context).pushReplacement(route);
    } else {
      return Navigator.of(context).push(route);
    }
  }

  /// Pop màn hình hiện tại với dữ liệu trả về
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  /// Kiểm tra xem có thể pop hay không
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Pop cho đến khi điều kiện thỏa mãn
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Lấy custom route route dựa trên loại transition
  static Route<T> _getCustomRoute<T>({
    required WidgetBuilder builder,
    required TransitionType transitionType,
    required Duration duration,
  }) {
    switch (transitionType) {
      case TransitionType.fade:
        return FadePageRoute<T>(
          builder: builder,
          duration: duration,
        );
      case TransitionType.slideRight:
        return SlideRightPageRoute<T>(
          builder: builder,
          duration: duration,
        );
      case TransitionType.scaleFade:
        return ScaleFadePageRoute<T>(
          builder: builder,
          duration: duration,
        );
      case TransitionType.sharedAxisVertical:
        return SharedAxisVerticalPageRoute<T>(
          builder: builder,
          duration: duration,
        );
      case TransitionType.rotateFade:
        return RotateFadePageRoute<T>(
          builder: builder,
          duration: duration,
        );
    }
  }
}

/// Mixin để tạo animated button widget
mixin AnimatedNavigationButton on StatelessWidget {
  void onNavigate(
    BuildContext context,
    WidgetBuilder builder, {
    TransitionType transitionType = TransitionType.scaleFade,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    NavigationHelper.navigateTo(
      context,
      builder,
      transitionType: transitionType,
      duration: duration,
    );
  }
}
