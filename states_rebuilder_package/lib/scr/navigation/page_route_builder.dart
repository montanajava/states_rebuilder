part of 'injected_navigator.dart';

class _PageRouteBuilder<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _PageRouteBuilder({
    required this.builder,
    this.isSubRouteTransition = false,
    this.customBuildTransitions,
    RouteSettings? settings,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog) {
    assert(opaque);
  }

  /// Builds the primary contents of the route.
  final Widget Function(BuildContext context, Animation<double> animation)
      builder;

  final bool isSubRouteTransition;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? customBuildTransitions;
  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;
  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  bool canTransitionTo(
    TransitionRoute<dynamic> nextRoute,
  ) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget result = builder(context, animation);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (isSubRouteTransition) {
      // _getThemeTransition = super.buildTransitions;
      return child;
    }
    if (customBuildTransitions != null) {
      return customBuildTransitions!(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }

    return super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
