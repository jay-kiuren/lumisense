import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../dashboard/presentation/widgets/department_detail_view.dart';
import '../../settings/presentation/settings_page.dart';
import 'widgets/sidebar.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
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
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const DepartmentDetailView(
          departmentName: 'IT Department',
          departmentId: 'it',
          icon: LucideIcons.monitorSpeaker,
        );
      case 2:
        return const DepartmentDetailView(
          departmentName: 'CS Department',
          departmentId: 'cs',
          icon: LucideIcons.server,
        );
      case 3:
        return const DepartmentDetailView(
          departmentName: 'Engineering Department',
          departmentId: 'eng',
          icon: LucideIcons.cpu,
        );
      case 4:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }
}
