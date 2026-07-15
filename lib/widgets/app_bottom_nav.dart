import 'package:flutter/material.dart';

import 'glass_container.dart';

class AppNavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavDestination({required this.icon, required this.activeIcon, required this.label});
}

const appNavDestinations = [
  AppNavDestination(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
  AppNavDestination(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Favorites'),
  AppNavDestination(icon: Icons.playlist_play_outlined, activeIcon: Icons.playlist_play, label: 'Playlists'),
  AppNavDestination(icon: Icons.audiotrack_outlined, activeIcon: Icons.audiotrack, label: 'Tracks'),
];

/// Bottom navigation bar matching the Lumina Audio design system: a
/// glassmorphic bar with a filled pill highlighting the active destination.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < appNavDestinations.length; i++)
                  _NavItem(
                    destination: appNavDestinations[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                    scheme: scheme,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 22,
                color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
