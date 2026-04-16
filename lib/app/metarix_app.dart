import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../features/activity/activity_timeline_screen.dart';
import '../features/admin/domain/admin_models.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/assets/presentation/asset_library_screen.dart';
import '../features/listening/presentation/listening_screen.dart';
import '../features/planning/presentation/planning_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/settings/presentation/theme_editor_dialog.dart';
import '../features/search/presentation/global_search_screen.dart';
import '../features/strategy/presentation/strategy_screen.dart';
import '../features/workflow/presentation/workflow_screen.dart';
import '../theme/metarix_theme_controller.dart';
import 'metarix_scope.dart';

class MetarixApp extends StatefulWidget {
  const MetarixApp({required this.services, super.key});

  final AppServices services;

  @override
  State<MetarixApp> createState() => _MetarixAppState();
}

class _MetarixAppState extends State<MetarixApp> {
  int _selectedIndex = 0;
  final MetarixThemeController _themeController = MetarixThemeController();

  static const _demoPath = [0, 1, 2, 4, 5, 6, 7];
  static const _items = [
    _ShellItem('Strategy', Icons.flag_outlined),
    _ShellItem('Planning', Icons.view_week_outlined),
    _ShellItem('Workflow', Icons.rule_folder_outlined),
    _ShellItem('Schedule', Icons.calendar_month_outlined),
    _ShellItem('Reports', Icons.bar_chart_outlined),
    _ShellItem('Listening', Icons.hearing_outlined),
    _ShellItem('Assets', Icons.perm_media_outlined),
    _ShellItem('Activity', Icons.history_outlined),
    _ShellItem('Admin', Icons.admin_panel_settings_outlined),
  ];

  @override
  void dispose() {
    _themeController.dispose();
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MetarixScope(
      services: widget.services,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MetaRix',
            themeMode: _themeController.themeMode,
            theme: _themeController.lightTheme,
            darkTheme: _themeController.darkTheme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('MetaRix'),
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) =>
                            ThemeEditorDialog(controller: _themeController),
                      );
                    },
                    icon: const Icon(Icons.tune_outlined),
                    tooltip: 'Theme',
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => GlobalSearchScreen(
                          searchService: widget.services.globalSearchService,
                          onSelect: (result) {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _selectedIndex = result.targetSurface,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: widget.services.adminController,
                        builder: (context, _) {
                          return Text(
                            '${widget.services.gateway.workspace.name} - ${widget.services.adminController.currentRole.label}',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final rail = constraints.maxWidth >= 960;
                  final content = _buildCurrentScreen();

                  return Column(
                    children: [
                      _DemoBanner(
                        currentIndex: _selectedIndex,
                        onNext: () {
                          final currentPathIndex = _demoPath.indexOf(
                            _selectedIndex,
                          );
                          final nextPathIndex =
                              (currentPathIndex + 1) % _demoPath.length;
                          setState(
                            () => _selectedIndex = _demoPath[nextPathIndex],
                          );
                        },
                        onReset: () async {
                          await widget.services.adminController.resetDemo();
                        },
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            if (rail)
                              NavigationRail(
                                selectedIndex: _selectedIndex,
                                onDestinationSelected: (value) {
                                  setState(() => _selectedIndex = value);
                                },
                                labelType: NavigationRailLabelType.all,
                                destinations: _items
                                    .map(
                                      (item) => NavigationRailDestination(
                                        icon: Icon(item.icon),
                                        label: Text(item.label),
                                      ),
                                    )
                                    .toList(),
                              ),
                            Expanded(child: content),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              bottomNavigationBar: MediaQuery.of(context).size.width < 960
                  ? NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() => _selectedIndex = value);
                      },
                      destinations: _items
                          .map(
                            (item) => NavigationDestination(
                              icon: Icon(item.icon),
                              label: item.label,
                            ),
                          )
                          .toList(),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen() {
    return switch (_selectedIndex) {
      0 => const StrategyScreen(),
      1 => const PlanningScreen(),
      2 => const WorkflowScreen(),
      3 => const ScheduleScreen(),
      4 => const ReportsScreen(),
      5 => const ListeningScreen(),
      6 => const AssetLibraryScreen(),
      7 => const ActivityTimelineScreen(),
      _ => const AdminScreen(),
    };
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({
    required this.currentIndex,
    required this.onNext,
    required this.onReset,
  });

  final int currentIndex;
  final VoidCallback onNext;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Demo path: Strategy -> Planning -> Workflow -> Reports -> Listening -> Assets -> Activity',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          FilledButton(onPressed: onNext, child: const Text('Go To Next Step')),
          OutlinedButton(
            onPressed: () => onReset(),
            child: const Text('Reset Demo'),
          ),
          Text('Current area: ${_MetarixAppState._items[currentIndex].label}'),
        ],
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
