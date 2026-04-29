import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../department/presentation/department_page.dart';
import '../../statistics/presentation/statistics_report_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'widgets/sidebar.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double effectiveWidth = constraints.maxWidth > 1280 ? constraints.maxWidth : 1280;
          final double effectiveHeight = constraints.maxHeight > 800 ? constraints.maxHeight : 800;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: effectiveWidth,
                height: effectiveHeight,
                child: Row(
                  children: [
                    AppSidebar(
                      selectedIndex: _selectedIndex,
                      isCollapsed: _isCollapsed,
                      onToggleCollapse: () {
                        setState(() {
                          _isCollapsed = !_isCollapsed;
                        });
                      },
                      onSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                    Container(
                      width: 1,
                      color: AppColors.surfaceHighlight,
                    ),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const DepartmentPage();
      case 2:
        return const StatisticsReportPage();
      case 3:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }
}
