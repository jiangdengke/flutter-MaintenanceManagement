import 'package:flutter/material.dart';
import 'package:maintenance_management/data/maintenance_repository.dart';
import 'package:maintenance_management/data/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DataMaintenanceManager extends StatelessWidget {
  const DataMaintenanceManager({super.key, required this.subIndex});

  final int subIndex;

  static const List<String> _labels = [
    '厂区',
    '车间',
    '线别',
    '机型',
    '机台号',
    '异常类别',
    '异常分类',
    '组别',
    '人员',
    '班别',
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex =
        subIndex.clamp(0, _labels.length - 1) as int;
    final label = _labels[safeIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            '基础数据维护',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Expanded(child: _buildSection(safeIndex)),
      ],
    );
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return const LookupManagementPage(
          title: '厂区',
          table: LookupTable.site,
        );
      case 1:
        return const LookupManagementPage(
          title: '车间',
          table: LookupTable.workshop,
          parentTable: LookupTable.site,
          parentLabel: '厂区',
        );
      case 2:
        return const LineManagementPage();
      case 3:
        return const LookupManagementPage(
          title: '机型',
          table: LookupTable.machineModel,
        );
      case 4:
        return const LookupManagementPage(
          title: '机台号',
          table: LookupTable.machine,
          parentTable: LookupTable.machineModel,
          parentLabel: '机型',
        );
      case 5:
        return const LookupManagementPage(
          title: '异常类别',
          table: LookupTable.anomalyCategory,
        );
      case 6:
        return const LookupManagementPage(
          title: '异常分类',
          table: LookupTable.anomalyClass,
          parentTable: LookupTable.anomalyCategory,
          parentLabel: '异常类别',
        );
      case 7:
        return const LookupManagementPage(
          title: '组别',
          table: LookupTable.group,
        );
      case 8:
        return const LookupManagementPage(
          title: '人员',
          table: LookupTable.person,
          parentTable: LookupTable.group,
          parentLabel: '组别',
        );
      case 9:
        return const LookupManagementPage(
          title: '班别',
          table: LookupTable.shift,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class LookupManagementPage extends StatefulWidget {
  const LookupManagementPage({
    super.key,
    required this.title,
    required this.table,
    this.parentTable,
    this.parentLabel,
  });

  final String title;
  final LookupTable table;
  final LookupTable? parentTable;
  final String? parentLabel;

  @override
  State<LookupManagementPage> createState() => _LookupManagementPageState();
}

class _LookupManagementPageState extends State<LookupManagementPage> {
  final MaintenanceRepository _repository = MaintenanceRepository();
  bool _loading = true;
  List<LookupItem> _parents = [];
  int? _selectedParentId;
  List<LookupEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    if (widget.parentTable != null) {
      _parents = await _repository.fetchLookup(
        widget.parentTable!,
        onlyActive: false,
      );
      if (_parents.isEmpty) {
        _selectedParentId = null;
      } else if (_selectedParentId == null ||
          !_parents.any((item) => item.id == _selectedParentId)) {
        _selectedParentId = _parents.first.id;
      }
    }
    if (widget.parentTable != null && _selectedParentId == null) {
      _entries = [];
    } else {
      _entries = await _repository.fetchLookupEntries(
        widget.table,
        parentId: widget.parentTable == null ? null : _selectedParentId,
      );
    }
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _addEntry() async {
    if (widget.parentTable != null && _selectedParentId == null) {
      _showMessage('请先选择${widget.parentLabel ?? '父级'}');
      return;
    }
    final result = await showLookupEntryDialog(
      context,
      title: '新增${widget.title}',
      hasActive: widget.table.hasActive,
    );
    if (result == null) {
      return;
    }
    try {
      await _repository.insertLookup(
        widget.table,
        name: result.name,
        parentId: _selectedParentId,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('新增失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _editEntry(LookupEntry entry) async {
    final result = await showLookupEntryDialog(
      context,
      title: '编辑${widget.title}',
      initial: entry,
      hasActive: widget.table.hasActive,
    );
    if (result == null) {
      return;
    }
    try {
      await _repository.updateLookup(
        widget.table,
        id: entry.id,
        name: result.name,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('更新失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _toggleActive(LookupEntry entry) async {
    try {
      await _repository.setLookupActive(
        widget.table,
        entry.id,
        !entry.isActive,
      );
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('更新失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _deleteEntry(LookupEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定删除 "${entry.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await _repository.deleteLookup(widget.table, entry.id);
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('删除失败: ${_errorMessage(error)}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasParent = widget.parentTable != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (hasParent)
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<int>(
                        value: _selectedParentId,
                        decoration: InputDecoration(
                          labelText: widget.parentLabel ?? '父级',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _parents
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedParentId = value);
                          _loadData();
                        },
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _addEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('新增'),
                  ),
                  if (_loading) const LinearProgressIndicator(),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _entries.isEmpty
                        ? const Center(child: Text('暂无数据'))
                        : _EntryTable(
                            entries: _entries,
                            hasActive: widget.table.hasActive,
                            onEdit: _editEntry,
                            onToggleActive: _toggleActive,
                            onDelete: _deleteEntry,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineManagementPage extends StatefulWidget {
  const LineManagementPage({super.key});

  @override
  State<LineManagementPage> createState() => _LineManagementPageState();
}

class _LineManagementPageState extends State<LineManagementPage> {
  final MaintenanceRepository _repository = MaintenanceRepository();
  bool _loading = true;
  List<LookupItem> _sites = [];
  List<LookupItem> _workshops = [];
  int? _selectedSiteId;
  int? _selectedWorkshopId;
  List<LookupEntry> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _loading = true);
    _sites = await _repository.fetchLookup(
      LookupTable.site,
      onlyActive: false,
    );
    if (_sites.isEmpty) {
      _selectedSiteId = null;
    } else if (_selectedSiteId == null ||
        !_sites.any((site) => site.id == _selectedSiteId)) {
      _selectedSiteId = _sites.first.id;
    }
    await _loadWorkshops();
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _loadWorkshops() async {
    if (_selectedSiteId == null) {
      _workshops = [];
      _selectedWorkshopId = null;
      _lines = [];
      return;
    }
    _workshops = await _repository.fetchLookup(
      LookupTable.workshop,
      parentId: _selectedSiteId,
      onlyActive: false,
    );
    if (_workshops.isEmpty) {
      _selectedWorkshopId = null;
    } else if (_selectedWorkshopId == null ||
        !_workshops.any((item) => item.id == _selectedWorkshopId)) {
      _selectedWorkshopId = _workshops.first.id;
    }
    await _loadLines();
  }

  Future<void> _loadLines() async {
    if (_selectedWorkshopId == null) {
      _lines = [];
      return;
    }
    _lines = await _repository.fetchLookupEntries(
      LookupTable.productionLine,
      parentId: _selectedWorkshopId,
    );
  }

  Future<void> _addLine() async {
    if (_selectedWorkshopId == null) {
      _showMessage('请先选择车间');
      return;
    }
    final result = await showLookupEntryDialog(
      context,
      title: '新增线别',
      hasActive: true,
    );
    if (result == null) {
      return;
    }
    try {
      await _repository.insertLookup(
        LookupTable.productionLine,
        name: result.name,
        parentId: _selectedWorkshopId,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('新增失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _editLine(LookupEntry entry) async {
    final result = await showLookupEntryDialog(
      context,
      title: '编辑线别',
      initial: entry,
      hasActive: true,
    );
    if (result == null) {
      return;
    }
    try {
      await _repository.updateLookup(
        LookupTable.productionLine,
        id: entry.id,
        name: result.name,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('更新失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _toggleLine(LookupEntry entry) async {
    try {
      await _repository.setLookupActive(
        LookupTable.productionLine,
        entry.id,
        !entry.isActive,
      );
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('更新失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _deleteLine(LookupEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定删除 "${entry.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await _repository.deleteLookup(
        LookupTable.productionLine,
        entry.id,
      );
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('删除失败: ${_errorMessage(error)}');
    }
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    await _loadLines();
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<int>(
                      value: _selectedSiteId,
                      decoration: const InputDecoration(
                        labelText: '厂区',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _sites
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedSiteId = value;
                          _selectedWorkshopId = null;
                          _workshops = [];
                          _lines = [];
                          _loading = true;
                        });
                        await _loadWorkshops();
                        if (!mounted) {
                          return;
                        }
                        setState(() => _loading = false);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<int>(
                      value: _selectedWorkshopId,
                      decoration: const InputDecoration(
                        labelText: '车间',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _workshops
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedWorkshopId = value;
                          _lines = [];
                          _loading = true;
                        });
                        await _loadLines();
                        if (!mounted) {
                          return;
                        }
                        setState(() => _loading = false);
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('新增'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _lines.isEmpty
                        ? const Center(child: Text('暂无线别数据'))
                        : _EntryTable(
                            entries: _lines,
                            hasActive: true,
                            onEdit: _editLine,
                            onToggleActive: _toggleLine,
                            onDelete: _deleteLine,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTable extends StatelessWidget {
  const _EntryTable({
    required this.entries,
    required this.hasActive,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final List<LookupEntry> entries;
  final bool hasActive;
  final ValueChanged<LookupEntry> onEdit;
  final ValueChanged<LookupEntry> onToggleActive;
  final ValueChanged<LookupEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final columns = <DataColumn>[
      const DataColumn(label: Text('名称')),
      const DataColumn(label: Text('排序')),
      if (hasActive) const DataColumn(label: Text('状态')),
      const DataColumn(label: Text('操作')),
    ];
    return SingleChildScrollView(
      child: DataTable(
        columns: columns,
        rows: entries.map((entry) {
          final cells = <DataCell>[
            DataCell(Text(entry.name)),
            DataCell(Text(entry.sortOrder.toString())),
            if (hasActive)
              DataCell(
                Chip(
                  label: Text(entry.isActive ? '启用' : '停用'),
                  backgroundColor: entry.isActive
                      ? Colors.green.shade100
                      : Colors.grey.shade300,
                ),
              ),
            DataCell(
              Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    onPressed: () => onEdit(entry),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: '编辑',
                  ),
                  if (hasActive)
                    IconButton(
                      onPressed: () => onToggleActive(entry),
                      icon: Icon(
                        entry.isActive
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      tooltip: entry.isActive ? '停用' : '启用',
                    ),
                  IconButton(
                    onPressed: () => onDelete(entry),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除',
                  ),
                ],
              ),
            ),
          ];
          return DataRow(cells: cells);
        }).toList(),
      ),
    );
  }
}

class LookupEntryFormResult {
  const LookupEntryFormResult({
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final String name;
  final int sortOrder;
  final bool isActive;
}

Future<LookupEntryFormResult?> showLookupEntryDialog(
  BuildContext context, {
  required String title,
  LookupEntry? initial,
  required bool hasActive,
}) {
  final nameController =
      TextEditingController(text: initial?.name ?? '');
  final sortController =
      TextEditingController(text: (initial?.sortOrder ?? 0).toString());
  bool isActive = initial?.isActive ?? true;
  String? errorText;

  return showDialog<LookupEntryFormResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '名称',
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sortController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '排序',
                    ),
                  ),
                  if (hasActive) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) {
                        setState(() => isActive = value);
                      },
                      title: const Text('启用'),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    setState(() => errorText = '请输入名称');
                    return;
                  }
                  final sortOrder =
                      int.tryParse(sortController.text.trim()) ?? 0;
                  Navigator.pop(
                    context,
                    LookupEntryFormResult(
                      name: name,
                      sortOrder: sortOrder,
                      isActive: isActive,
                    ),
                  );
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _errorMessage(Object error) {
  if (error is DatabaseException) {
    return error.toString();
  }
  return error.toString();
}
