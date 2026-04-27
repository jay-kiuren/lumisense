import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'MENU',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          _NavItem(
            icon: LucideIcons.layoutDashboard,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _NavItem(
            icon: LucideIcons.building2,
            label: 'Department',
            isSelected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          _NavItem(
            icon: LucideIcons.barChart3,
            label: 'Statistics Report',
            isSelected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Divider(color: AppColors.surfaceHighlight),
          ),
          _NavItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            isSelected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
          _NavItem(
            icon: LucideIcons.logOut,
            label: 'Log out',
            isSelected: false,
            onTap: () {},
            isDanger: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.waves_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Lumisense',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDanger
        ? AppColors.error
        : widget.isSelected
            ? AppColors.textPrimary
            : _isHovered
                ? AppColors.textPrimary
                : AppColors.textSecondary;

    final bgColor = widget.isSelected
        ? AppColors.surfaceHighlight
        : _isHovered
            ? AppColors.surfaceHighlight.withOpacity(0.5)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: color),
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
