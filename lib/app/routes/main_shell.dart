import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/features/airports/presentation/pages/airport_explorer_page.dart';
import 'package:sky_tracker/features/favorites/presentation/pages/favorites_page.dart';
import 'package:sky_tracker/features/home/presentation/pages/home_page.dart';
import 'package:sky_tracker/features/live_map/presentation/pages/live_map_page.dart';
import 'package:sky_tracker/features/profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Pages are built lazily so tabs like the live map do not start timers
  /// and network work before the user visits them.
  final Set<int> _loadedTabs = {0};

  static const List<Widget> _pages = [
    HomePage(),
    AirportExplorerPage(),
    LiveMapPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  static const List<_NavSpec> _items = [
    _NavSpec(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: AppStrings.home,
    ),
    _NavSpec(
      icon: Icons.travel_explore_outlined,
      activeIcon: Icons.travel_explore_rounded,
      label: AppStrings.explore,
    ),
    _NavSpec(
      icon: Icons.public_outlined,
      activeIcon: Icons.public_rounded,
      label: AppStrings.liveMap,
    ),
    _NavSpec(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: AppStrings.favorites,
    ),
    _NavSpec(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: AppStrings.profile,
    ),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
      _loadedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _pages.length,
          (index) => _loadedTabs.contains(index)
              ? _pages[index]
              : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: _AnimatedNavBar(
        index: _currentIndex,
        items: _items,
        onTap: _onTap,
      ),
    );
  }
}

class _AnimatedNavBar extends StatelessWidget {
  const _AnimatedNavBar({
    required this.index,
    required this.items,
    required this.onTap,
  });

  final int index;
  final List<_NavSpec> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppSpacing.radiusXl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: radius,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : const Color(0xFF1B1340).withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 66,
              child: Stack(
                children: [
                  // Sliding selection pill
                  AnimatedAlign(
                    alignment: Alignment(
                      -1 + (2 * index) / (items.length - 1),
                      0,
                    ),
                    duration: AppMotion.normal,
                    curve: Curves.easeOutCubic,
                    child: FractionallySizedBox(
                      widthFactor: 1 / items.length,
                      heightFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: isDark ? 0.14 : 0.09,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg - 4,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (i) {
                      return Expanded(
                        child: _NavItem(
                          spec: items[i],
                          selected: index == i,
                          onTap: () => onTap(i),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      child: AnimatedPressable(
        onTap: onTap,
        pressedScale: 0.92,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: selected ? 1.1 : 1),
                duration: AppMotion.fast,
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  selected ? spec.activeIcon : spec.icon,
                  size: 23,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: AppMotion.normal,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.1,
                ),
                child: Text(spec.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
