import 'package:flutter/material.dart';
import 'package:maintenance_management/data/maintenance_repository.dart';
import 'package:maintenance_management/data/models.dart';
import 'package:maintenance_management/screens/data_maintenance.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaintenanceApp());
}

class MaintenanceApp extends StatelessWidget {
  const MaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '维修记录管理',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MaintenanceShell(),
    );
  }
}

class MaintenanceShell extends StatefulWidget {
  const MaintenanceShell({super.key});

  @override
  State<MaintenanceShell> createState() => _MaintenanceShellState();
}

class _MaintenanceShellState extends State<MaintenanceShell> {
  int _mainSection = 0;
  int _recordSubIndex = 0;
  int _maintenanceSubIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _SideNavigation(
              mainSection: _mainSection,
              recordSubIndex: _recordSubIndex,
              maintenanceSubIndex: _maintenanceSubIndex,
              onRecordSubSelected: (index) {
                setState(() {
                  _mainSection = 0;
                  _recordSubIndex = index;
                });
              },
              onMaintenanceSubSelected: (index) {
                setState(() {
                  _mainSection = 1;
                  _maintenanceSubIndex = index;
                });
              },
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _mainSection == 0
                  ? MaintenanceRecordManager(
                      subIndex: _recordSubIndex,
                    )
                  : DataMaintenanceManager(
                      subIndex: _maintenanceSubIndex,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaintenanceRecordManager extends StatelessWidget {
  const MaintenanceRecordManager({
    super.key,
    required this.subIndex,
  });

  final int subIndex;

  @override
  Widget build(BuildContext context) {
    final subtitle = subIndex == 0 ? '维修工作台' : '数据统计';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            '维修记录管理',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Expanded(
          child: subIndex == 0
              ? const MaintenanceWorkbench()
              : const MaintenanceAnalytics(),
        ),
      ],
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.mainSection,
    required this.recordSubIndex,
    required this.maintenanceSubIndex,
    required this.onRecordSubSelected,
    required this.onMaintenanceSubSelected,
  });

  final int mainSection;
  final int recordSubIndex;
  final int maintenanceSubIndex;
  final ValueChanged<int> onRecordSubSelected;
  final ValueChanged<int> onMaintenanceSubSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 240,
      color: colors.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '菜单',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text('维修记录管理'),
            leading: const Icon(Icons.build_outlined),
            children: [
              _SideNavItem(
                label: '维修工作台',
                selected: mainSection == 0 && recordSubIndex == 0,
                onTap: () => onRecordSubSelected(0),
              ),
              _SideNavItem(
                label: '数据统计',
                selected: mainSection == 0 && recordSubIndex == 1,
                onTap: () => onRecordSubSelected(1),
              ),
            ],
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text('基础数据维护'),
            leading: const Icon(Icons.dataset_outlined),
            children: [
              _SideNavItem(
                label: '厂区',
                selected: mainSection == 1 && maintenanceSubIndex == 0,
                onTap: () => onMaintenanceSubSelected(0),
              ),
              _SideNavItem(
                label: '车间',
                selected: mainSection == 1 && maintenanceSubIndex == 1,
                onTap: () => onMaintenanceSubSelected(1),
              ),
              _SideNavItem(
                label: '线别',
                selected: mainSection == 1 && maintenanceSubIndex == 2,
                onTap: () => onMaintenanceSubSelected(2),
              ),
              _SideNavItem(
                label: '机型',
                selected: mainSection == 1 && maintenanceSubIndex == 3,
                onTap: () => onMaintenanceSubSelected(3),
              ),
              _SideNavItem(
                label: '机台号',
                selected: mainSection == 1 && maintenanceSubIndex == 4,
                onTap: () => onMaintenanceSubSelected(4),
              ),
              _SideNavItem(
                label: '异常类别',
                selected: mainSection == 1 && maintenanceSubIndex == 5,
                onTap: () => onMaintenanceSubSelected(5),
              ),
              _SideNavItem(
                label: '异常分类',
                selected: mainSection == 1 && maintenanceSubIndex == 6,
                onTap: () => onMaintenanceSubSelected(6),
              ),
              _SideNavItem(
                label: '组别',
                selected: mainSection == 1 && maintenanceSubIndex == 7,
                onTap: () => onMaintenanceSubSelected(7),
              ),
              _SideNavItem(
                label: '人员',
                selected: mainSection == 1 && maintenanceSubIndex == 8,
                onTap: () => onMaintenanceSubSelected(8),
              ),
              _SideNavItem(
                label: '班别',
                selected: mainSection == 1 && maintenanceSubIndex == 9,
                onTap: () => onMaintenanceSubSelected(9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: colors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          label,
          style: selected
              ? TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                )
              : null,
        ),
        onTap: onTap,
      ),
    );
  }
}

class MaintenanceWorkbench extends StatefulWidget {
  const MaintenanceWorkbench({super.key});

  @override
  State<MaintenanceWorkbench> createState() => _MaintenanceWorkbenchState();
}

class _MaintenanceWorkbenchState extends State<MaintenanceWorkbench> {
  final MaintenanceRepository _repository = MaintenanceRepository();
  final Set<int> _selectedFixerIds = {};
  bool _loadingLookups = true;
  List<LookupItem> _shifts = [];
  List<LookupItem> _sites = [];
  List<LookupItem> _workshops = [];
  List<LookupItem> _lines = [];
  List<LookupItem> _machineModels = [];
  List<LookupItem> _machines = [];
  List<LookupItem> _anomalyCategories = [];
  List<LookupItem> _anomalyClasses = [];
  List<LookupItem> _groups = [];
  List<LookupItem> _people = [];

  int? _selectedShiftId;
  int? _selectedSiteId;
  int? _selectedWorkshopId;
  int? _selectedLineId;
  int? _selectedMachineModelId;
  int? _selectedMachineId;
  int? _selectedAnomalyCategoryId;
  int? _selectedAnomalyClassId;
  int? _selectedGroupId;
  int? _selectedOwnerId;

  @override
  void initState() {
    super.initState();
    _loadInitialLookups();
  }

  Future<void> _loadInitialLookups() async {
    setState(() => _loadingLookups = true);
    final results = await Future.wait([
      _repository.fetchLookup(LookupTable.shift),
      _repository.fetchLookup(LookupTable.site),
      _repository.fetchLookup(LookupTable.machineModel),
      _repository.fetchLookup(LookupTable.anomalyCategory),
      _repository.fetchLookup(LookupTable.group),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _shifts = results[0];
      _sites = results[1];
      _machineModels = results[2];
      _anomalyCategories = results[3];
      _groups = results[4];
      _selectedShiftId = _selectedShiftId ?? _firstId(_shifts);
      _selectedSiteId = _selectedSiteId ?? _firstId(_sites);
      _selectedMachineModelId =
          _selectedMachineModelId ?? _firstId(_machineModels);
      _selectedAnomalyCategoryId =
          _selectedAnomalyCategoryId ?? _firstId(_anomalyCategories);
      _selectedGroupId = _selectedGroupId ?? _firstId(_groups);
    });

    await Future.wait([
      _loadWorkshops(_selectedSiteId),
      _loadMachines(_selectedMachineModelId),
      _loadAnomalyClasses(_selectedAnomalyCategoryId),
      _loadPeople(_selectedGroupId),
    ]);
    if (!mounted) {
      return;
    }
    setState(() => _loadingLookups = false);
  }

  List<LookupItem> get _selectedFixers {
    if (_selectedFixerIds.isEmpty) {
      return const [];
    }
    return _people
        .where((person) => _selectedFixerIds.contains(person.id))
        .toList();
  }

  int? _firstId(List<LookupItem> items) =>
      items.isEmpty ? null : items.first.id;

  Future<void> _loadWorkshops(int? siteId) async {
    if (siteId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _workshops = [];
        _lines = [];
        _selectedWorkshopId = null;
        _selectedLineId = null;
      });
      return;
    }
    final workshops =
        await _repository.fetchLookup(LookupTable.workshop, parentId: siteId);
    if (!mounted) {
      return;
    }
    setState(() {
      _workshops = workshops;
      _selectedWorkshopId = _firstId(_workshops);
      _lines = [];
      _selectedLineId = null;
    });
    await _loadLines(_selectedWorkshopId);
  }

  Future<void> _loadLines(int? workshopId) async {
    if (workshopId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lines = [];
        _selectedLineId = null;
      });
      return;
    }
    final lines = await _repository.fetchLookup(
      LookupTable.productionLine,
      parentId: workshopId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lines = lines;
      _selectedLineId = _firstId(_lines);
    });
  }

  Future<void> _loadMachines(int? modelId) async {
    if (modelId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _machines = [];
        _selectedMachineId = null;
      });
      return;
    }
    final machines =
        await _repository.fetchLookup(LookupTable.machine, parentId: modelId);
    if (!mounted) {
      return;
    }
    setState(() {
      _machines = machines;
      _selectedMachineId = _firstId(_machines);
    });
  }

  Future<void> _loadAnomalyClasses(int? categoryId) async {
    if (categoryId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _anomalyClasses = [];
        _selectedAnomalyClassId = null;
      });
      return;
    }
    final classes = await _repository.fetchLookup(
      LookupTable.anomalyClass,
      parentId: categoryId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _anomalyClasses = classes;
      _selectedAnomalyClassId = _firstId(_anomalyClasses);
    });
  }

  Future<void> _loadPeople(int? groupId) async {
    if (groupId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _people = [];
        _selectedOwnerId = null;
        _selectedFixerIds.clear();
      });
      return;
    }
    final people =
        await _repository.fetchLookup(LookupTable.person, parentId: groupId);
    if (!mounted) {
      return;
    }
    setState(() {
      _people = people;
      if (_selectedOwnerId != null &&
          !_people.any((person) => person.id == _selectedOwnerId)) {
        _selectedOwnerId = null;
      }
      _selectedFixerIds.removeWhere(
        (personId) => !_people.any((person) => person.id == personId),
      );
    });
  }

  Future<void> _onSiteChanged(int? id) async {
    if (id == _selectedSiteId) {
      return;
    }
    setState(() {
      _selectedSiteId = id;
      _selectedWorkshopId = null;
      _selectedLineId = null;
      _workshops = [];
      _lines = [];
    });
    await _loadWorkshops(id);
  }

  Future<void> _onWorkshopChanged(int? id) async {
    if (id == _selectedWorkshopId) {
      return;
    }
    setState(() {
      _selectedWorkshopId = id;
      _selectedLineId = null;
      _lines = [];
    });
    await _loadLines(id);
  }

  Future<void> _onMachineModelChanged(int? id) async {
    if (id == _selectedMachineModelId) {
      return;
    }
    setState(() {
      _selectedMachineModelId = id;
      _selectedMachineId = null;
      _machines = [];
    });
    await _loadMachines(id);
  }

  Future<void> _onAnomalyCategoryChanged(int? id) async {
    if (id == _selectedAnomalyCategoryId) {
      return;
    }
    setState(() {
      _selectedAnomalyCategoryId = id;
      _selectedAnomalyClassId = null;
      _anomalyClasses = [];
    });
    await _loadAnomalyClasses(id);
  }

  Future<void> _onGroupChanged(int? id) async {
    if (id == _selectedGroupId) {
      return;
    }
    setState(() {
      _selectedGroupId = id;
      _selectedOwnerId = null;
      _selectedFixerIds.clear();
      _people = [];
    });
    await _loadPeople(id);
  }

  Future<void> _pickFixers() async {
    if (_loadingLookups) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('人员列表加载中...')),
      );
      return;
    }
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择组别')),
      );
      return;
    }
    if (_people.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('暂无维修人员'),
            content: const Text('请先在维护表中添加人员。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('知道了'),
              ),
            ],
          );
        },
      );
      return;
    }

    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (context) {
        final tempSelected = _selectedFixerIds.toSet();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('选择维修人'),
              content: SizedBox(
                width: 360,
                child: ListView(
                  shrinkWrap: true,
                  children: _people
                      .map(
                        (person) => CheckboxListTile(
                          value: tempSelected.contains(person.id),
                          title: Text(person.name),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                tempSelected.add(person.id);
                              } else {
                                tempSelected.remove(person.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedFixerIds
          ..clear()
          ..addAll(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _SectionCard(
                  title: '新增',
                  child: _NewRecordForm(
                    selectedFixers: _selectedFixers,
                    onPickFixers: _pickFixers,
                    isLoadingFixers: _loadingLookups,
                    availableFixers: _people.length,
                    isLoadingLookups: _loadingLookups,
                    shifts: _shifts,
                    sites: _sites,
                    workshops: _workshops,
                    lines: _lines,
                    machineModels: _machineModels,
                    machines: _machines,
                    anomalyCategories: _anomalyCategories,
                    anomalyClasses: _anomalyClasses,
                    groups: _groups,
                    people: _people,
                    selectedShiftId: _selectedShiftId,
                    selectedSiteId: _selectedSiteId,
                    selectedWorkshopId: _selectedWorkshopId,
                    selectedLineId: _selectedLineId,
                    selectedMachineModelId: _selectedMachineModelId,
                    selectedMachineId: _selectedMachineId,
                    selectedAnomalyCategoryId: _selectedAnomalyCategoryId,
                    selectedAnomalyClassId: _selectedAnomalyClassId,
                    selectedGroupId: _selectedGroupId,
                    selectedOwnerId: _selectedOwnerId,
                    onShiftChanged: (value) =>
                        setState(() => _selectedShiftId = value),
                    onSiteChanged: _onSiteChanged,
                    onWorkshopChanged: _onWorkshopChanged,
                    onLineChanged: (value) =>
                        setState(() => _selectedLineId = value),
                    onMachineModelChanged: _onMachineModelChanged,
                    onMachineChanged: (value) =>
                        setState(() => _selectedMachineId = value),
                    onAnomalyCategoryChanged: _onAnomalyCategoryChanged,
                    onAnomalyClassChanged: (value) =>
                        setState(() => _selectedAnomalyClassId = value),
                    onGroupChanged: _onGroupChanged,
                    onOwnerChanged: (value) =>
                        setState(() => _selectedOwnerId = value),
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionCard(
                  title: '筛选',
                  child: _FilterPanel(),
                ),
                const SizedBox(height: 16),
                const _SectionCard(
                  title: '数据展示',
                  child: _RecordTable(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NewRecordForm extends StatelessWidget {
  const _NewRecordForm({
    required this.selectedFixers,
    required this.onPickFixers,
    required this.isLoadingFixers,
    required this.availableFixers,
    required this.isLoadingLookups,
    required this.shifts,
    required this.sites,
    required this.workshops,
    required this.lines,
    required this.machineModels,
    required this.machines,
    required this.anomalyCategories,
    required this.anomalyClasses,
    required this.groups,
    required this.people,
    required this.selectedShiftId,
    required this.selectedSiteId,
    required this.selectedWorkshopId,
    required this.selectedLineId,
    required this.selectedMachineModelId,
    required this.selectedMachineId,
    required this.selectedAnomalyCategoryId,
    required this.selectedAnomalyClassId,
    required this.selectedGroupId,
    required this.selectedOwnerId,
    required this.onShiftChanged,
    required this.onSiteChanged,
    required this.onWorkshopChanged,
    required this.onLineChanged,
    required this.onMachineModelChanged,
    required this.onMachineChanged,
    required this.onAnomalyCategoryChanged,
    required this.onAnomalyClassChanged,
    required this.onGroupChanged,
    required this.onOwnerChanged,
  });

  final List<LookupItem> selectedFixers;
  final VoidCallback onPickFixers;
  final bool isLoadingFixers;
  final int availableFixers;
  final bool isLoadingLookups;
  final List<LookupItem> shifts;
  final List<LookupItem> sites;
  final List<LookupItem> workshops;
  final List<LookupItem> lines;
  final List<LookupItem> machineModels;
  final List<LookupItem> machines;
  final List<LookupItem> anomalyCategories;
  final List<LookupItem> anomalyClasses;
  final List<LookupItem> groups;
  final List<LookupItem> people;
  final int? selectedShiftId;
  final int? selectedSiteId;
  final int? selectedWorkshopId;
  final int? selectedLineId;
  final int? selectedMachineModelId;
  final int? selectedMachineId;
  final int? selectedAnomalyCategoryId;
  final int? selectedAnomalyClassId;
  final int? selectedGroupId;
  final int? selectedOwnerId;
  final ValueChanged<int?> onShiftChanged;
  final ValueChanged<int?> onSiteChanged;
  final ValueChanged<int?> onWorkshopChanged;
  final ValueChanged<int?> onLineChanged;
  final ValueChanged<int?> onMachineModelChanged;
  final ValueChanged<int?> onMachineChanged;
  final ValueChanged<int?> onAnomalyCategoryChanged;
  final ValueChanged<int?> onAnomalyClassChanged;
  final ValueChanged<int?> onGroupChanged;
  final ValueChanged<int?> onOwnerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoadingLookups) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        _FieldGrid(
          children: [
            _LabeledInput(
              label: '日期',
              hintText: '选择日期',
              icon: Icons.calendar_today,
            ),
            _LookupDropdown(
              label: '白/夜班',
              items: shifts,
              value: selectedShiftId,
              enabled: shifts.isNotEmpty,
              onChanged: onShiftChanged,
            ),
            _LookupDropdown(
              label: '厂区',
              items: sites,
              value: selectedSiteId,
              enabled: sites.isNotEmpty,
              onChanged: onSiteChanged,
            ),
            _LookupDropdown(
              label: '车间',
              items: workshops,
              value: selectedWorkshopId,
              enabled: workshops.isNotEmpty,
              onChanged: onWorkshopChanged,
              emptyHint: '先选择厂区',
            ),
            _LookupDropdown(
              label: '线别',
              items: lines,
              value: selectedLineId,
              enabled: lines.isNotEmpty,
              onChanged: onLineChanged,
              emptyHint: '先选择车间',
            ),
            _LookupDropdown(
              label: '机型',
              items: machineModels,
              value: selectedMachineModelId,
              enabled: machineModels.isNotEmpty,
              onChanged: onMachineModelChanged,
            ),
            _LookupDropdown(
              label: '机台号',
              items: machines,
              value: selectedMachineId,
              enabled: machines.isNotEmpty,
              onChanged: onMachineChanged,
              emptyHint: '先选择机型',
            ),
            _LookupDropdown(
              label: '异常类别',
              items: anomalyCategories,
              value: selectedAnomalyCategoryId,
              enabled: anomalyCategories.isNotEmpty,
              onChanged: onAnomalyCategoryChanged,
            ),
            _LookupDropdown(
              label: '异常分类',
              items: anomalyClasses,
              value: selectedAnomalyClassId,
              enabled: anomalyClasses.isNotEmpty,
              onChanged: onAnomalyClassChanged,
              emptyHint: '先选择异常类别',
            ),
            _LookupDropdown(
              label: '组别',
              items: groups,
              value: selectedGroupId,
              enabled: groups.isNotEmpty,
              onChanged: onGroupChanged,
            ),
            _LookupDropdown(
              label: '责任人',
              items: people,
              value: selectedOwnerId,
              enabled: people.isNotEmpty,
              onChanged: onOwnerChanged,
              emptyHint: '先选择组别',
            ),
            _LabeledInput(
              label: '维修耗时(分钟)',
              hintText: '例如 45',
              icon: Icons.timer_outlined,
            ),
            _LabeledDropdown(
              label: '已修复',
              items: const ['是', '否'],
            ),
            _LabeledInput(
              label: '修复日期',
              hintText: '选择日期时间',
              icon: Icons.event_available,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MultiSelectField(
          label: '维修人',
          selections: selectedFixers,
          helperText: isLoadingFixers
              ? '人员列表加载中...'
              : availableFixers == 0
                  ? '暂无人员可选'
                  : '已选择 ${selectedFixers.length} 人',
          onPressed: onPickFixers,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final fields = [
              _LabeledInput(
                label: '异常描述',
                hintText: '请输入异常描述',
                maxLines: 4,
              ),
              _LabeledInput(
                label: '解决对策',
                hintText: '请输入解决对策',
                maxLines: 4,
              ),
            ];
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 12),
                  Expanded(child: fields[1]),
                ],
              );
            }
            return Column(
              children: [
                fields[0],
                const SizedBox(height: 12),
                fields[1],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('保存维修记录'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('清空表单'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldGrid(
          children: const [
            _LabeledInput(label: '开始日期', hintText: 'YYYY-MM-DD'),
            _LabeledInput(label: '结束日期', hintText: 'YYYY-MM-DD'),
            _LabeledDropdown(
              label: '厂区',
              items: ['全部', '一厂', '二厂'],
            ),
            _LabeledDropdown(
              label: '车间',
              items: ['全部', 'A车间', 'B车间'],
            ),
            _LabeledDropdown(
              label: '线别',
              items: ['全部', '1号线', '2号线'],
            ),
            _LabeledDropdown(
              label: '机型',
              items: ['全部', 'M-100', 'M-200'],
            ),
            _LabeledDropdown(
              label: '机台号',
              items: ['全部', 'T-01', 'T-02'],
            ),
            _LabeledDropdown(
              label: '异常类别',
              items: ['全部', '电气类', '机械类'],
            ),
            _LabeledDropdown(
              label: '异常分类',
              items: ['全部', '传感器', '电机'],
            ),
            _LabeledDropdown(
              label: '责任人',
              items: ['全部', '王伟', '李敏'],
            ),
            _LabeledDropdown(
              label: '状态',
              items: ['全部', '已修复', '未修复'],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text('查询'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('重置筛选'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordTable extends StatelessWidget {
  const _RecordTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      const _RecordRow(
        date: '2024-08-21',
        shift: '白班',
        line: '1号线',
        machine: 'M-100 / T-01',
        anomaly: '电气类/传感器',
        status: '已修复',
        fixers: '赵强, 周文',
        owner: '王伟',
        duration: '45',
      ),
      const _RecordRow(
        date: '2024-08-22',
        shift: '夜班',
        line: '2号线',
        machine: 'M-200 / T-03',
        anomaly: '机械类/皮带',
        status: '未修复',
        fixers: '陈杰',
        owner: '李敏',
        duration: '30',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '共 ${rows.length} 条记录',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download),
              label: const Text('导出'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_note),
              label: const Text('批量更新'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('日期')),
              DataColumn(label: Text('班别')),
              DataColumn(label: Text('线别')),
              DataColumn(label: Text('机型/机台')),
              DataColumn(label: Text('异常分类')),
              DataColumn(label: Text('状态')),
              DataColumn(label: Text('维修人')),
              DataColumn(label: Text('责任人')),
              DataColumn(label: Text('耗时(分钟)')),
              DataColumn(label: Text('操作')),
            ],
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: [
                      DataCell(Text(row.date)),
                      DataCell(Text(row.shift)),
                      DataCell(Text(row.line)),
                      DataCell(Text(row.machine)),
                      DataCell(Text(row.anomaly)),
                      DataCell(
                        Chip(
                          label: Text(row.status),
                          backgroundColor: row.status == '已修复'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                        ),
                      ),
                      DataCell(Text(row.fixers)),
                      DataCell(Text(row.owner)),
                      DataCell(Text(row.duration)),
                      DataCell(
                        Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: '编辑',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.delete_outline),
                              tooltip: '删除',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RecordRow {
  const _RecordRow({
    required this.date,
    required this.shift,
    required this.line,
    required this.machine,
    required this.anomaly,
    required this.status,
    required this.fixers,
    required this.owner,
    required this.duration,
  });

  final String date;
  final String shift;
  final String line;
  final String machine;
  final String anomaly;
  final String status;
  final String fixers;
  final String owner;
  final String duration;
}

class MaintenanceAnalytics extends StatelessWidget {
  const MaintenanceAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 3
            : width >= 720
                ? 2
                : 1;
        final metricColumns = width >= 1000
            ? 4
            : width >= 700
                ? 2
                : 1;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _SectionCard(
                title: '统计筛选',
                child: _AnalyticsFilters(),
              ),
              const SizedBox(height: 16),
              _MetricGrid(columns: metricColumns),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: const [
                  _ChartCard(
                    title: '维修量趋势',
                    subtitle: '按日期统计',
                    icon: Icons.show_chart,
                  ),
                  _ChartCard(
                    title: '异常类别占比',
                    subtitle: 'Top 5 类别',
                    icon: Icons.pie_chart_outline,
                  ),
                  _ChartCard(
                    title: '维修耗时分布',
                    subtitle: '平均耗时(分钟)',
                    icon: Icons.timelapse,
                  ),
                  _ChartCard(
                    title: '责任人工作量',
                    subtitle: '人员对比',
                    icon: Icons.groups_outlined,
                  ),
                  _ChartCard(
                    title: '未修复占比',
                    subtitle: '按线别',
                    icon: Icons.warning_amber_outlined,
                  ),
                  _ChartCard(
                    title: '重复异常排行',
                    subtitle: 'Top 5 机台',
                    icon: Icons.repeat,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;
        final itemWidth =
            (width - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _LookupDropdown extends StatelessWidget {
  const _LookupDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.emptyHint,
  });

  final String label;
  final List<LookupItem> items;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && items.isNotEmpty;
    return DropdownButtonFormField<int>(
      value: items.any((item) => item.id == value) ? value : null,
      hint: Text(items.isEmpty ? (emptyHint ?? '暂无数据') : '请选择'),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name),
            ),
          )
          .toList(),
      onChanged: isEnabled ? onChanged : null,
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.items,
  });

  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.isNotEmpty ? items.first : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (_) {},
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    this.hintText,
    this.icon,
    this.maxLines = 1,
  });

  final String label;
  final String? hintText;
  final IconData? icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
      ),
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.selections,
    required this.onPressed,
    this.helperText,
  });

  final String label;
  final List<LookupItem> selections;
  final VoidCallback onPressed;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (selections.isEmpty)
          Text(
            '未选择维修人',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        if (selections.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selections
                .map((person) => Chip(label: Text(person.name)))
                .toList(),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('选择维修人'),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _AnalyticsFilters extends StatelessWidget {
  const _AnalyticsFilters();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldGrid(
          children: const [
            _LabeledInput(label: '开始日期', hintText: 'YYYY-MM-DD'),
            _LabeledInput(label: '结束日期', hintText: 'YYYY-MM-DD'),
            _LabeledDropdown(
              label: '厂区',
              items: ['全部', '一厂', '二厂'],
            ),
            _LabeledDropdown(
              label: '线别',
              items: ['全部', '1号线', '2号线'],
            ),
            _LabeledDropdown(
              label: '异常类别',
              items: ['全部', '电气类', '机械类'],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('生成报表'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('重置条件'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      _MetricTile(title: '本周维修数', value: '128', subtitle: '较上周 +12%'),
      _MetricTile(title: '平均耗时', value: '42分钟', subtitle: '目标 60 分钟'),
      _MetricTile(title: '未修复工单', value: '6', subtitle: '需关注 2 条'),
      _MetricTile(title: 'Top 责任人', value: '王伟', subtitle: '完成 26 单'),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: metrics,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: colors.primary),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.15),
                    colors.secondary.withOpacity(0.12),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '图表占位',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
