import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../features/activity/activity_timeline_screen.dart';
import '../features/admin/domain/admin_models.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/assets/presentation/asset_library_screen.dart';
import '../features/inbox/presentation/inbox_screen.dart';
import '../features/listening/presentation/listening_screen.dart';
import '../features/planning/presentation/planning_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/settings/presentation/theme_editor_dialog.dart';
import '../features/search/presentation/global_search_screen.dart';
import '../features/strategy/presentation/strategy_screen.dart';
import '../features/workflow/presentation/workflow_screen.dart';
import '../metarix_core/release/auth/auth_gate.dart';
import '../screens/content/content_explorer_screen.dart';
import '../screens/connectors/connector_readiness_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/publishing/release_publish_pipeline_screen.dart';
import '../screens/scheduler/release_scheduler_screen.dart';
import '../screens/settings/social_account_settings_screen.dart';
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
  late final Future<bool> _backendHealthy;

  @override
  void initState() {
    super.initState();
    _backendHealthy = widget.services.backendApiService.health();
  }

  static const _demoPath = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
  static const _items = [
    _ShellItem('Publish', Icons.send_outlined),
    _ShellItem('Strategy', Icons.flag_outlined),
    _ShellItem('Planning', Icons.view_week_outlined),
    _ShellItem('Workflow', Icons.rule_folder_outlined),
    _ShellItem('Schedule', Icons.calendar_month_outlined),
    _ShellItem('Inbox', Icons.forum_outlined),
    _ShellItem('Reports', Icons.bar_chart_outlined),
    _ShellItem('Listening', Icons.hearing_outlined),
    _ShellItem('Assets', Icons.perm_media_outlined),
    _ShellItem('Content', Icons.collections_outlined),
    _ShellItem('Scheduler+', Icons.schedule_outlined),
    _ShellItem('Publish+', Icons.cloud_upload_outlined),
    _ShellItem('Activity', Icons.history_outlined),
    _ShellItem('Admin', Icons.admin_panel_settings_outlined),
    _ShellItem('Connectors', Icons.link_outlined),
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
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (routeContext) => LoginScreen(
                            controller: widget.services.appSessionController,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login_outlined),
                    tooltip: 'Login',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (routeContext) => SocialAccountSettingsScreen(
                            controller: widget.services.socialAccountController,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Accounts',
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
                        animation: Listenable.merge([
                          widget.services.adminController,
                          widget.services.appSessionController,
                        ]),
                        builder: (context, _) {
                          return FutureBuilder<bool>(
                            future: _backendHealthy,
                            builder: (context, snapshot) {
                              final backendLabel = snapshot.connectionState == ConnectionState.done
                                  ? (snapshot.data == true ? 'Backend online' : 'Backend offline')
                                  : 'Backend checking';
                              final auth = widget.services.appSessionController;
                              final authLabel = auth.isLoading
                                  ? 'Auth loading'
                                  : auth.session == null
                                      ? 'Signed out'
                                      : auth.hasExpiredSession
                                          ? 'Session expired'
                                          : 'Signed in';
                              return Text(
                                '${widget.services.gateway.workspace.name} - ${widget.services.adminController.currentRole.label} - $backendLabel - $authLabel',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              body: AuthGate(
                controller: widget.services.appSessionController,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final rail = constraints.maxWidth >= 960;
                    final content = _buildCurrentScreen();

                    return Column(
                      children: [
                        _CreatorLaunchPad(
                          onOpenPublish: () => setState(() => _selectedIndex = 0),
                          onOpenWorkflow: () => setState(() => _selectedIndex = 3),
                          onPublishEverywhere: () => setState(() => _selectedIndex = 3),
                        ),
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
      0 => const WorkflowScreen(),
      1 => const StrategyScreen(),
      2 => const PlanningScreen(),
      3 => const WorkflowScreen(),
      4 => const ScheduleScreen(),
      5 => const InboxScreen(),
      6 => const ReportsScreen(),
      7 => const ListeningScreen(),
      8 => const AssetLibraryScreen(),
      9 => const ContentExplorerScreen(),
      10 => const ReleaseSchedulerScreen(),
      11 => const ReleasePublishPipelineScreen(),
      12 => const ActivityTimelineScreen(),
      13 => const AdminScreen(),
      14 => const ConnectorReadinessScreen(),
      _ => const WorkflowScreen(),
    };
  }
}

class _CreatorLaunchPad extends StatelessWidget {
  const _CreatorLaunchPad({
    required this.onOpenPublish,
    required this.onOpenWorkflow,
    required this.onPublishEverywhere,
  });

  final VoidCallback onOpenPublish;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onPublishEverywhere;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.65),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator first',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jump straight into publishing. Compose once, then push to Instagram, Facebook, and LinkedIn.',
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: onOpenPublish,
                    child: const Text('Open Publish'),
                  ),
                  OutlinedButton(
                    onPressed: onOpenWorkflow,
                    child: const Text('Open Workflow'),
                  ),
                  FilledButton.tonal(
                    onPressed: onPublishEverywhere,
                    child: const Text('Publish Everywhere'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            'Demo path: Publish -> Strategy -> Planning -> Workflow -> Schedule -> Inbox -> Reports -> Listening -> Assets -> Content -> Scheduler+ -> Publish+ -> Activity -> Admin -> Connectors',
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
