import 'package:flutter/material.dart';
import 'app_header.dart';

class ReusableSliverHeader extends StatelessWidget {
  final bool isDrawerOpen;
  final VoidCallback onToggleDrawer;
  final VoidCallback onOpenSideDrawer;

  const ReusableSliverHeader({
    super.key,
    required this.isDrawerOpen,
    required this.onToggleDrawer,
    required this.onOpenSideDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _ReusableHeaderDelegate(
        statusBarHeight: statusBarHeight,
        child: Container(
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: AppHeader(
            isDrawerOpen: isDrawerOpen,
            onToggleDrawer: onToggleDrawer,
            onOpenSideDrawer: onOpenSideDrawer,
          ),
        ),
      ),
    );
  }
}

class _ReusableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;
  final Widget child;

  _ReusableHeaderDelegate({
    required this.statusBarHeight,
    required this.child,
  });

  @override
  double get minExtent => statusBarHeight + 70.0;

  @override
  double get maxExtent => statusBarHeight + 70.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Container(
          height: statusBarHeight,
          color: Colors.grey.shade300,
        ),
        child,
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _ReusableHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.statusBarHeight != statusBarHeight;
  }
}
