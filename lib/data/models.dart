class LookupItem {
  const LookupItem({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class LookupEntry {
  const LookupEntry({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.parentId,
  });

  final int id;
  final String name;
  final int sortOrder;
  final bool isActive;
  final int? parentId;
}

class MaintenanceRecord {
  const MaintenanceRecord({
    this.id,
    required this.recordDate,
    required this.shiftId,
    required this.lineId,
    required this.machineId,
    required this.anomalyClassId,
    required this.description,
    required this.solution,
    required this.isFixed,
    required this.fixedAt,
    required this.durationMinutes,
    required this.ownerId,
    required this.fixerIds,
  });

  final int? id;
  final DateTime recordDate;
  final int shiftId;
  final int lineId;
  final int machineId;
  final int anomalyClassId;
  final String description;
  final String solution;
  final bool isFixed;
  final DateTime? fixedAt;
  final int durationMinutes;
  final int ownerId;
  final List<int> fixerIds;

  Map<String, Object?> toDbMap() {
    return {
      'record_date': _formatDate(recordDate),
      'shift_id': shiftId,
      'line_id': lineId,
      'machine_id': machineId,
      'anomaly_class_id': anomalyClassId,
      'description': description,
      'solution': solution,
      'is_fixed': isFixed ? 1 : 0,
      'fixed_at': fixedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'owner_id': ownerId,
    };
  }

  static MaintenanceRecord fromDbMap(
    Map<String, Object?> map, {
    required List<int> fixerIds,
  }) {
    return MaintenanceRecord(
      id: map['id'] as int?,
      recordDate: DateTime.parse(map['record_date'] as String),
      shiftId: map['shift_id'] as int,
      lineId: map['line_id'] as int,
      machineId: map['machine_id'] as int,
      anomalyClassId: map['anomaly_class_id'] as int,
      description: map['description'] as String,
      solution: map['solution'] as String,
      isFixed: (map['is_fixed'] as int) == 1,
      fixedAt: map['fixed_at'] == null
          ? null
          : DateTime.parse(map['fixed_at'] as String),
      durationMinutes: map['duration_minutes'] as int,
      ownerId: map['owner_id'] as int,
      fixerIds: fixerIds,
    );
  }
}

class RecordQuery {
  const RecordQuery({
    this.startDate,
    this.endDate,
    this.shiftId,
    this.lineId,
    this.machineId,
    this.anomalyClassId,
    this.ownerId,
    this.isFixed,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? shiftId;
  final int? lineId;
  final int? machineId;
  final int? anomalyClassId;
  final int? ownerId;
  final bool? isFixed;
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
