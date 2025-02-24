part of 'injected_navigator.dart';

/// Extension on BuildContext
extension BuildContextX on BuildContext {
  /// Get the scoped router outlet widget. It looks up the widget tree for the
  /// closest sub route and returns its router outlet widget.
  Widget get routerOutlet {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.route != null);
    return r!.route!;
    // if (r!.animation == null || !r.shouldAnimate) {
    //   return r.route!;
    // }

    // final widget = r.transitionsBuilder?.call(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     ) ??
    //     _navigate.transitionsBuilder?.call(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     ) ??
    //     _getThemeTransition!(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     );
    // return Stack(
    //   children: [
    //     r.lastSubRoute!,
    //     Builder(builder: (_) {
    //       return widget;
    //     }),
    //   ],
    // );
  }

  /// Get the scoped [RouteData]. It looks up the widget tree for the
  /// closest sub route and returns its[RouteData].
  ///
  /// See also [InjectedNavigator.routeData]
  RouteData get routeData {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.routeData != null);
    // if (RouterObjects.injectedNavigator != null) {
    //   // OnReactiveState.addToObs?.call(RouterObjects.injectedNavigator!);
    // }
    return r!.routeData;
  }

  /// Get the page transition animation
  Animation<double>? get animation {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    return r?.animation;
  }

  /// Get the page transition secondary animation
  Animation<double>? get secondaryAnimation {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    return r?.secondaryAnimation;
  }

  // @Deprecated('User routeData instead')
  // dynamic get routeArguments {
  //   final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
  //       as SubRoute?;
  //   assert(r?.routeData.arguments != null);
  //   return r!.routeData.arguments;
  // }

  // @Deprecated('User routeData instead')
  // Map<String, String> get routeQueryParams {
  //   final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
  //       as SubRoute?;
  //   assert(r?.routeData.queryParams != null);
  //   return r!.routeData.queryParams;
  // }

  // @Deprecated('User routeData instead')
  // Map<String, String> get routePathParams {
  //   final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
  //       as SubRoute?;
  //   assert(r?.routeData.pathParams != null);
  //   return r!.routeData.pathParams;
  // }

  // @Deprecated('User routeData instead')
  // String get routeBaseUrl {
  //   final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
  //       as SubRoute?;
  //   assert(r?.routeData.baseLocation != null);
  //   return r!.routeData.baseLocation;
  // }

  // @Deprecated('User routeData instead')
  // String get routePath {
  //   final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
  //       as SubRoute?;
  //   return r!.routeData.path;
  // }
}
