import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/login_page.dart';

class AppSidebar extends StatelessWidget {
  static const double _expandedWidth = 236;
  static const double _collapsedWidth = 80;
  static const double _iconLeftInset = 24;
  static const double _iconSlotSize = 32;

  final int selectedIndex;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final ValueChanged<int> onSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? _collapsedWidth : _expandedWidth,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: _expandedWidth,
          maxWidth: _expandedWidth,
          child: SizedBox(
            width: _expandedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _iconLeftInset),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        if (!isCollapsed) ...[
                          Expanded(
                            child: Text(
                              'MENU',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: _iconSlotSize,
                            height: _iconSlotSize,
                            child: IconButton(
                              onPressed: onToggleCollapse,
                              icon: const Icon(
                                LucideIcons.panelLeftClose,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                              tooltip: 'Collapse Sidebar',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: _iconSlotSize,
                            height: _iconSlotSize,
                            child: IconButton(
                              onPressed: onToggleCollapse,
                              icon: const Icon(
                                LucideIcons.panelLeftOpen,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                              tooltip: 'Expand Sidebar',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _NavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  isCollapsed: isCollapsed,
                  onTap: () => onSelected(0),
                ),
                _NavItem(
                  icon: LucideIcons.building2,
                  label: 'Department',
                  isSelected: selectedIndex == 1,
                  isCollapsed: isCollapsed,
                  onTap: () => onSelected(1),
                ),
                _NavItem(
                  icon: LucideIcons.barChart3,
                  label: 'Statistics',
                  isSelected: selectedIndex == 2,
                  isCollapsed: isCollapsed,
                  onTap: () => onSelected(2),
                ),
                _NavItem(
                  icon: LucideIcons.scrollText,
                  label: 'Logs',
                  isSelected: selectedIndex == 3,
                  isCollapsed: isCollapsed,
                  onTap: () => onSelected(3),
                ),
                const Spacer(),
                const SizedBox(height: 24),
                _NavItem(
                  icon: LucideIcons.settings,
                  label: 'Settings',
                  isSelected: selectedIndex == 4,
                  isCollapsed: isCollapsed,
                  onTap: () => onSelected(4),
                ),
                _NavItem(
                  icon: LucideIcons.logOut,
                  label: 'Log out',
                  isSelected: false,
                  isCollapsed: isCollapsed,
                  onTap: () => _confirmLogout(context),
                  isDanger: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.logOut, size: 20, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'Log out',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of LumiSense?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Sign-out network errors are non-fatal — proceed to login anyway
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false, // clears entire navigation stack
      );
    }
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_iconLeftInset, 40, _iconLeftInset, 0),
      child: Row(
        children: [
          Container(
            width: _iconSlotSize,
            height: _iconSlotSize,
            decoration: BoxDecoration(
              color: AppColors.textPrimary, // White background
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.hexagon, color: AppColors.sidebar, size: 20), // Dark icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isCollapsed ? 0 : 1,
              child: const Text(
                'Lumisense',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
  final bool isCollapsed;
  final VoidCallback onTap;
  final bool isDanger;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;
  static const double _itemHeight = 44;
  static const double _iconLeftInset = 24;
  static const double _iconSlotSize = 32;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDanger
        ? AppColors.error
        : widget.isSelected
            ? AppColors.textPrimary
            : _isHovered
                ? AppColors.textPrimary
                : AppColors.textSecondary;

    if (widget.isCollapsed) {
      final collapsedBg = widget.isSelected
          ? AppColors.surfaceHighlight
          : _isHovered
              ? AppColors.surfaceHighlight.withValues(alpha: 0.5)
              : Colors.transparent;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: _iconLeftInset, vertical: 2),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: _iconSlotSize,
              height: _itemHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: collapsedBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 20, color: color),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _iconLeftInset, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            height: _itemHeight,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _iconSlotSize,
                  height: _iconSlotSize,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppColors.surfaceHighlight
                        : _isHovered
                            ? AppColors.surfaceHighlight.withValues(alpha: 0.45)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Icon(widget.icon, size: 20, color: color)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
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