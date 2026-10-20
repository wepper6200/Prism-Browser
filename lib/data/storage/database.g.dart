// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TabRowsTable extends TabRows with TableInfo<$TabRowsTable, TabRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    pinned,
    groupId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TabRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TabRowsTable createAlias(String alias) {
    return $TabRowsTable(attachedDatabase, alias);
  }
}

class TabRow extends DataClass implements Insertable<TabRow> {
  final String id;
  final String title;
  final String url;
  final bool pinned;
  final String? groupId;
  final int position;
  const TabRow({
    required this.id,
    required this.title,
    required this.url,
    required this.pinned,
    this.groupId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['pinned'] = Variable<bool>(pinned);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  TabRowsCompanion toCompanion(bool nullToAbsent) {
    return TabRowsCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      pinned: Value(pinned),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      position: Value(position),
    );
  }

  factory TabRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'pinned': serializer.toJson<bool>(pinned),
      'groupId': serializer.toJson<String?>(groupId),
      'position': serializer.toJson<int>(position),
    };
  }

  TabRow copyWith({
    String? id,
    String? title,
    String? url,
    bool? pinned,
    Value<String?> groupId = const Value.absent(),
    int? position,
  }) => TabRow(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    pinned: pinned ?? this.pinned,
    groupId: groupId.present ? groupId.value : this.groupId,
    position: position ?? this.position,
  );
  TabRow copyWithCompanion(TabRowsCompanion data) {
    return TabRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('pinned: $pinned, ')
          ..write('groupId: $groupId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url, pinned, groupId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.pinned == this.pinned &&
          other.groupId == this.groupId &&
          other.position == this.position);
}

class TabRowsCompanion extends UpdateCompanion<TabRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> url;
  final Value<bool> pinned;
  final Value<String?> groupId;
  final Value<int> position;
  final Value<int> rowid;
  const TabRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.pinned = const Value.absent(),
    this.groupId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabRowsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.pinned = const Value.absent(),
    this.groupId = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       position = Value(position);
  static Insertable<TabRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<bool>? pinned,
    Expression<String>? groupId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (pinned != null) 'pinned': pinned,
      if (groupId != null) 'group_id': groupId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? url,
    Value<bool>? pinned,
    Value<String?>? groupId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TabRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      pinned: pinned ?? this.pinned,
      groupId: groupId ?? this.groupId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('pinned: $pinned, ')
          ..write('groupId: $groupId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabGroupRowsTable extends TabGroupRows
    with TableInfo<$TabGroupRowsTable, TabGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabGroupRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<TabGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TabGroupRowsTable createAlias(String alias) {
    return $TabGroupRowsTable(attachedDatabase, alias);
  }
}

class TabGroupRow extends DataClass implements Insertable<TabGroupRow> {
  final String id;
  final String name;
  final int color;
  final int position;
  const TabGroupRow({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['position'] = Variable<int>(position);
    return map;
  }

  TabGroupRowsCompanion toCompanion(bool nullToAbsent) {
    return TabGroupRowsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      position: Value(position),
    );
  }

  factory TabGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabGroupRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'position': serializer.toJson<int>(position),
    };
  }

  TabGroupRow copyWith({String? id, String? name, int? color, int? position}) =>
      TabGroupRow(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        position: position ?? this.position,
      );
  TabGroupRow copyWithCompanion(TabGroupRowsCompanion data) {
    return TabGroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabGroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabGroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.position == this.position);
}

class TabGroupRowsCompanion extends UpdateCompanion<TabGroupRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> position;
  final Value<int> rowid;
  const TabGroupRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabGroupRowsCompanion.insert({
    required String id,
    required String name,
    required int color,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       position = Value(position);
  static Insertable<TabGroupRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabGroupRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TabGroupRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabGroupRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionMetaTable extends SessionMeta
    with TableInfo<$SessionMetaTable, SessionMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SessionMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SessionMetaTable createAlias(String alias) {
    return $SessionMetaTable(attachedDatabase, alias);
  }
}

class SessionMetaData extends DataClass implements Insertable<SessionMetaData> {
  final String key;
  final String value;
  const SessionMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SessionMetaCompanion toCompanion(bool nullToAbsent) {
    return SessionMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SessionMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SessionMetaData copyWith({String? key, String? value}) =>
      SessionMetaData(key: key ?? this.key, value: value ?? this.value);
  SessionMetaData copyWithCompanion(SessionMetaCompanion data) {
    return SessionMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SessionMetaCompanion extends UpdateCompanion<SessionMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SessionMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SessionMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SessionMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryVisitsTable extends HistoryVisits
    with TableInfo<$HistoryVisitsTable, HistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchMeta = const VerificationMeta('search');
  @override
  late final GeneratedColumn<String> search = GeneratedColumn<String>(
    'search',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, title, visitedAt, search];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    if (data.containsKey('search')) {
      context.handle(
        _searchMeta,
        search.isAcceptableOrUnknown(data['search']!, _searchMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
      search: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search'],
      )!,
    );
  }

  @override
  $HistoryVisitsTable createAlias(String alias) {
    return $HistoryVisitsTable(attachedDatabase, alias);
  }
}

class HistoryRow extends DataClass implements Insertable<HistoryRow> {
  final int id;
  final String url;
  final String title;
  final DateTime visitedAt;

  /// Lower-cased "title url", computed in Dart: SQLite's lower()/LIKE only
  /// fold ASCII, so Cyrillic searches must not rely on them.
  final String search;
  const HistoryRow({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
    required this.search,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['visited_at'] = Variable<DateTime>(visitedAt);
    map['search'] = Variable<String>(search);
    return map;
  }

  HistoryVisitsCompanion toCompanion(bool nullToAbsent) {
    return HistoryVisitsCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      visitedAt: Value(visitedAt),
      search: Value(search),
    );
  }

  factory HistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryRow(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
      search: serializer.fromJson<String>(json['search']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
      'search': serializer.toJson<String>(search),
    };
  }

  HistoryRow copyWith({
    int? id,
    String? url,
    String? title,
    DateTime? visitedAt,
    String? search,
  }) => HistoryRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    visitedAt: visitedAt ?? this.visitedAt,
    search: search ?? this.search,
  );
  HistoryRow copyWithCompanion(HistoryVisitsCompanion data) {
    return HistoryRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
      search: data.search.present ? data.search.value : this.search,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('search: $search')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, visitedAt, search);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.visitedAt == this.visitedAt &&
          other.search == this.search);
}

class HistoryVisitsCompanion extends UpdateCompanion<HistoryRow> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> title;
  final Value<DateTime> visitedAt;
  final Value<String> search;
  const HistoryVisitsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.search = const Value.absent(),
  });
  HistoryVisitsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.title = const Value.absent(),
    required DateTime visitedAt,
    this.search = const Value.absent(),
  }) : url = Value(url),
       visitedAt = Value(visitedAt);
  static Insertable<HistoryRow> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<DateTime>? visitedAt,
    Expression<String>? search,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (search != null) 'search': search,
    });
  }

  HistoryVisitsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? title,
    Value<DateTime>? visitedAt,
    Value<String>? search,
  }) {
    return HistoryVisitsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      visitedAt: visitedAt ?? this.visitedAt,
      search: search ?? this.search,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (search.present) {
      map['search'] = Variable<String>(search.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryVisitsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('search: $search')
          ..write(')'))
        .toString();
  }
}

class $BookmarkFolderRowsTable extends BookmarkFolderRows
    with TableInfo<$BookmarkFolderRowsTable, BookmarkFolderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkFolderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkFolderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkFolderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkFolderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarkFolderRowsTable createAlias(String alias) {
    return $BookmarkFolderRowsTable(attachedDatabase, alias);
  }
}

class BookmarkFolderRow extends DataClass
    implements Insertable<BookmarkFolderRow> {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  const BookmarkFolderRow({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarkFolderRowsCompanion toCompanion(bool nullToAbsent) {
    return BookmarkFolderRowsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkFolderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkFolderRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkFolderRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    DateTime? createdAt,
  }) => BookmarkFolderRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkFolderRow copyWithCompanion(BookmarkFolderRowsCompanion data) {
    return BookmarkFolderRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkFolderRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkFolderRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt);
}

class BookmarkFolderRowsCompanion extends UpdateCompanion<BookmarkFolderRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarkFolderRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkFolderRowsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<BookmarkFolderRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkFolderRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarkFolderRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkFolderRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarkRowsTable extends BookmarkRows
    with TableInfo<$BookmarkRowsTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bookmark_folders (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, url, folderId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarkRowsTable createAlias(String alias) {
    return $BookmarkRowsTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String id;
  final String title;
  final String url;
  final String? folderId;
  final DateTime createdAt;
  const BookmarkRow({
    required this.id,
    required this.title,
    required this.url,
    this.folderId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarkRowsCompanion toCompanion(bool nullToAbsent) {
    return BookmarkRowsCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'folderId': serializer.toJson<String?>(folderId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkRow copyWith({
    String? id,
    String? title,
    String? url,
    Value<String?> folderId = const Value.absent(),
    DateTime? createdAt,
  }) => BookmarkRow(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    folderId: folderId.present ? folderId.value : this.folderId,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkRow copyWithCompanion(BookmarkRowsCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url, folderId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.folderId == this.folderId &&
          other.createdAt == this.createdAt);
}

class BookmarkRowsCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> folderId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarkRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.folderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkRowsCompanion.insert({
    required String id,
    required String title,
    required String url,
    this.folderId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? folderId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (folderId != null) 'folder_id': folderId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? folderId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarkRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadRowsTable extends DownloadRows
    with TableInfo<$DownloadRowsTable, DownloadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentUriMeta = const VerificationMeta(
    'contentUri',
  );
  @override
  late final GeneratedColumn<String> contentUri = GeneratedColumn<String>(
    'content_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _receivedBytesMeta = const VerificationMeta(
    'receivedBytes',
  );
  @override
  late final GeneratedColumn<int> receivedBytes = GeneratedColumn<int>(
    'received_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    fileName,
    filePath,
    contentUri,
    mimeType,
    totalBytes,
    receivedBytes,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('content_uri')) {
      context.handle(
        _contentUriMeta,
        contentUri.isAcceptableOrUnknown(data['content_uri']!, _contentUriMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('received_bytes')) {
      context.handle(
        _receivedBytesMeta,
        receivedBytes.isAcceptableOrUnknown(
          data['received_bytes']!,
          _receivedBytesMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      contentUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_uri'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      receivedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_bytes'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DownloadRowsTable createAlias(String alias) {
    return $DownloadRowsTable(attachedDatabase, alias);
  }
}

class DownloadRow extends DataClass implements Insertable<DownloadRow> {
  final String id;
  final String url;
  final String fileName;

  /// Where the file is (or is being) written.
  final String filePath;

  /// Android: content:// URI of the copy in the public Downloads folder.
  final String? contentUri;
  final String? mimeType;
  final int totalBytes;
  final int receivedBytes;

  /// [DownloadState.name].
  final String state;
  final DateTime createdAt;
  const DownloadRow({
    required this.id,
    required this.url,
    required this.fileName,
    required this.filePath,
    this.contentUri,
    this.mimeType,
    required this.totalBytes,
    required this.receivedBytes,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || contentUri != null) {
      map['content_uri'] = Variable<String>(contentUri);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['total_bytes'] = Variable<int>(totalBytes);
    map['received_bytes'] = Variable<int>(receivedBytes);
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DownloadRowsCompanion toCompanion(bool nullToAbsent) {
    return DownloadRowsCompanion(
      id: Value(id),
      url: Value(url),
      fileName: Value(fileName),
      filePath: Value(filePath),
      contentUri: contentUri == null && nullToAbsent
          ? const Value.absent()
          : Value(contentUri),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      totalBytes: Value(totalBytes),
      receivedBytes: Value(receivedBytes),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory DownloadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      contentUri: serializer.fromJson<String?>(json['contentUri']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      receivedBytes: serializer.fromJson<int>(json['receivedBytes']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'contentUri': serializer.toJson<String?>(contentUri),
      'mimeType': serializer.toJson<String?>(mimeType),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'receivedBytes': serializer.toJson<int>(receivedBytes),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DownloadRow copyWith({
    String? id,
    String? url,
    String? fileName,
    String? filePath,
    Value<String?> contentUri = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    int? totalBytes,
    int? receivedBytes,
    String? state,
    DateTime? createdAt,
  }) => DownloadRow(
    id: id ?? this.id,
    url: url ?? this.url,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    contentUri: contentUri.present ? contentUri.value : this.contentUri,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    totalBytes: totalBytes ?? this.totalBytes,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  DownloadRow copyWithCompanion(DownloadRowsCompanion data) {
    return DownloadRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      contentUri: data.contentUri.present
          ? data.contentUri.value
          : this.contentUri,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      receivedBytes: data.receivedBytes.present
          ? data.receivedBytes.value
          : this.receivedBytes,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('contentUri: $contentUri, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    fileName,
    filePath,
    contentUri,
    mimeType,
    totalBytes,
    receivedBytes,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.contentUri == this.contentUri &&
          other.mimeType == this.mimeType &&
          other.totalBytes == this.totalBytes &&
          other.receivedBytes == this.receivedBytes &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class DownloadRowsCompanion extends UpdateCompanion<DownloadRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String?> contentUri;
  final Value<String?> mimeType;
  final Value<int> totalBytes;
  final Value<int> receivedBytes;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DownloadRowsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.contentUri = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadRowsCompanion.insert({
    required String id,
    required String url,
    required String fileName,
    required String filePath,
    this.contentUri = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    required String state,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       fileName = Value(fileName),
       filePath = Value(filePath),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<DownloadRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? contentUri,
    Expression<String>? mimeType,
    Expression<int>? totalBytes,
    Expression<int>? receivedBytes,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (contentUri != null) 'content_uri': contentUri,
      if (mimeType != null) 'mime_type': mimeType,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (receivedBytes != null) 'received_bytes': receivedBytes,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String?>? contentUri,
    Value<String?>? mimeType,
    Value<int>? totalBytes,
    Value<int>? receivedBytes,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DownloadRowsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      contentUri: contentUri ?? this.contentUri,
      mimeType: mimeType ?? this.mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (contentUri.present) {
      map['content_uri'] = Variable<String>(contentUri.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (receivedBytes.present) {
      map['received_bytes'] = Variable<int>(receivedBytes.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRowsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('contentUri: $contentUri, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PrismDatabase extends GeneratedDatabase {
  _$PrismDatabase(QueryExecutor e) : super(e);
  $PrismDatabaseManager get managers => $PrismDatabaseManager(this);
  late final $TabRowsTable tabRows = $TabRowsTable(this);
  late final $TabGroupRowsTable tabGroupRows = $TabGroupRowsTable(this);
  late final $SessionMetaTable sessionMeta = $SessionMetaTable(this);
  late final $HistoryVisitsTable historyVisits = $HistoryVisitsTable(this);
  late final $BookmarkFolderRowsTable bookmarkFolderRows =
      $BookmarkFolderRowsTable(this);
  late final $BookmarkRowsTable bookmarkRows = $BookmarkRowsTable(this);
  late final $DownloadRowsTable downloadRows = $DownloadRowsTable(this);
  late final Index historyVisitedAt = Index(
    'history_visited_at',
    'CREATE INDEX history_visited_at ON history (visited_at)',
  );
  late final Index historyUrl = Index(
    'history_url',
    'CREATE INDEX history_url ON history (url)',
  );
  late final Index bookmarksUrl = Index(
    'bookmarks_url',
    'CREATE INDEX bookmarks_url ON bookmarks (url)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tabRows,
    tabGroupRows,
    sessionMeta,
    historyVisits,
    bookmarkFolderRows,
    bookmarkRows,
    downloadRows,
    historyVisitedAt,
    historyUrl,
    bookmarksUrl,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bookmark_folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$TabRowsTableCreateCompanionBuilder = TabRowsCompanion Function({
  required String id,
  Value<String> title,
  Value<String> url,
  Value<bool> pinned,
  Value<String?> groupId,
  required int position,
  Value<int> rowid,
});
typedef $$TabRowsTableUpdateCompanionBuilder = TabRowsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> url,
  Value<bool> pinned,
  Value<String?> groupId,
  Value<int> position,
  Value<int> rowid,
});

class $$TabRowsTableFilterComposer
    extends Composer<_$PrismDatabase, $TabRowsTable> {
  $$TabRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabRowsTableOrderingComposer
    extends Composer<_$PrismDatabase, $TabRowsTable> {
  $$TabRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabRowsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $TabRowsTable> {
  $$TabRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$TabRowsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $TabRowsTable,
          TabRow,
          $$TabRowsTableFilterComposer,
          $$TabRowsTableOrderingComposer,
          $$TabRowsTableAnnotationComposer,
          $$TabRowsTableCreateCompanionBuilder,
          $$TabRowsTableUpdateCompanionBuilder,
          (TabRow, BaseReferences<_$PrismDatabase, $TabRowsTable, TabRow>),
          TabRow,
          PrefetchHooks Function()
        > {
  $$TabRowsTableTableManager(_$PrismDatabase db, $TabRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabRowsCompanion(
                id: id,
                title: title,
                url: url,
                pinned: pinned,
                groupId: groupId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TabRowsCompanion.insert(
                id: id,
                title: title,
                url: url,
                pinned: pinned,
                groupId: groupId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TabRowsTable, TabRow>(table),
                  BaseReferences<_$PrismDatabase, $TabRowsTable, TabRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $TabRowsTable,
      TabRow,
      $$TabRowsTableFilterComposer,
      $$TabRowsTableOrderingComposer,
      $$TabRowsTableAnnotationComposer,
      $$TabRowsTableCreateCompanionBuilder,
      $$TabRowsTableUpdateCompanionBuilder,
      (TabRow, BaseReferences<_$PrismDatabase, $TabRowsTable, TabRow>),
      TabRow,
      PrefetchHooks Function()
    >;
typedef $$TabGroupRowsTableCreateCompanionBuilder =
    TabGroupRowsCompanion Function({
      required String id,
      required String name,
      required int color,
      required int position,
      Value<int> rowid,
    });
typedef $$TabGroupRowsTableUpdateCompanionBuilder =
    TabGroupRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> color,
      Value<int> position,
      Value<int> rowid,
    });

class $$TabGroupRowsTableFilterComposer
    extends Composer<_$PrismDatabase, $TabGroupRowsTable> {
  $$TabGroupRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabGroupRowsTableOrderingComposer
    extends Composer<_$PrismDatabase, $TabGroupRowsTable> {
  $$TabGroupRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabGroupRowsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $TabGroupRowsTable> {
  $$TabGroupRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$TabGroupRowsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $TabGroupRowsTable,
          TabGroupRow,
          $$TabGroupRowsTableFilterComposer,
          $$TabGroupRowsTableOrderingComposer,
          $$TabGroupRowsTableAnnotationComposer,
          $$TabGroupRowsTableCreateCompanionBuilder,
          $$TabGroupRowsTableUpdateCompanionBuilder,
          (
            TabGroupRow,
            BaseReferences<_$PrismDatabase, $TabGroupRowsTable, TabGroupRow>,
          ),
          TabGroupRow,
          PrefetchHooks Function()
        > {
  $$TabGroupRowsTableTableManager(_$PrismDatabase db, $TabGroupRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabGroupRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabGroupRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabGroupRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabGroupRowsCompanion(
                id: id,
                name: name,
                color: color,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TabGroupRowsCompanion.insert(
                id: id,
                name: name,
                color: color,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TabGroupRowsTable, TabGroupRow>(table),
                  BaseReferences<
                    _$PrismDatabase,
                    $TabGroupRowsTable,
                    TabGroupRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabGroupRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $TabGroupRowsTable,
      TabGroupRow,
      $$TabGroupRowsTableFilterComposer,
      $$TabGroupRowsTableOrderingComposer,
      $$TabGroupRowsTableAnnotationComposer,
      $$TabGroupRowsTableCreateCompanionBuilder,
      $$TabGroupRowsTableUpdateCompanionBuilder,
      (
        TabGroupRow,
        BaseReferences<_$PrismDatabase, $TabGroupRowsTable, TabGroupRow>,
      ),
      TabGroupRow,
      PrefetchHooks Function()
    >;
typedef $$SessionMetaTableCreateCompanionBuilder =
    SessionMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SessionMetaTableUpdateCompanionBuilder =
    SessionMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SessionMetaTableFilterComposer
    extends Composer<_$PrismDatabase, $SessionMetaTable> {
  $$SessionMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionMetaTableOrderingComposer
    extends Composer<_$PrismDatabase, $SessionMetaTable> {
  $$SessionMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionMetaTableAnnotationComposer
    extends Composer<_$PrismDatabase, $SessionMetaTable> {
  $$SessionMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SessionMetaTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $SessionMetaTable,
          SessionMetaData,
          $$SessionMetaTableFilterComposer,
          $$SessionMetaTableOrderingComposer,
          $$SessionMetaTableAnnotationComposer,
          $$SessionMetaTableCreateCompanionBuilder,
          $$SessionMetaTableUpdateCompanionBuilder,
          (
            SessionMetaData,
            BaseReferences<_$PrismDatabase, $SessionMetaTable, SessionMetaData>,
          ),
          SessionMetaData,
          PrefetchHooks Function()
        > {
  $$SessionMetaTableTableManager(_$PrismDatabase db, $SessionMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SessionMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SessionMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionMetaTable, SessionMetaData>(table),
                  BaseReferences<
                    _$PrismDatabase,
                    $SessionMetaTable,
                    SessionMetaData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $SessionMetaTable,
      SessionMetaData,
      $$SessionMetaTableFilterComposer,
      $$SessionMetaTableOrderingComposer,
      $$SessionMetaTableAnnotationComposer,
      $$SessionMetaTableCreateCompanionBuilder,
      $$SessionMetaTableUpdateCompanionBuilder,
      (
        SessionMetaData,
        BaseReferences<_$PrismDatabase, $SessionMetaTable, SessionMetaData>,
      ),
      SessionMetaData,
      PrefetchHooks Function()
    >;
typedef $$HistoryVisitsTableCreateCompanionBuilder =
    HistoryVisitsCompanion Function({
      Value<int> id,
      required String url,
      Value<String> title,
      required DateTime visitedAt,
      Value<String> search,
    });
typedef $$HistoryVisitsTableUpdateCompanionBuilder =
    HistoryVisitsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> title,
      Value<DateTime> visitedAt,
      Value<String> search,
    });

class $$HistoryVisitsTableFilterComposer
    extends Composer<_$PrismDatabase, $HistoryVisitsTable> {
  $$HistoryVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get search => $composableBuilder(
    column: $table.search,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryVisitsTableOrderingComposer
    extends Composer<_$PrismDatabase, $HistoryVisitsTable> {
  $$HistoryVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get search => $composableBuilder(
    column: $table.search,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryVisitsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $HistoryVisitsTable> {
  $$HistoryVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  GeneratedColumn<String> get search =>
      $composableBuilder(column: $table.search, builder: (column) => column);
}

class $$HistoryVisitsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $HistoryVisitsTable,
          HistoryRow,
          $$HistoryVisitsTableFilterComposer,
          $$HistoryVisitsTableOrderingComposer,
          $$HistoryVisitsTableAnnotationComposer,
          $$HistoryVisitsTableCreateCompanionBuilder,
          $$HistoryVisitsTableUpdateCompanionBuilder,
          (
            HistoryRow,
            BaseReferences<_$PrismDatabase, $HistoryVisitsTable, HistoryRow>,
          ),
          HistoryRow,
          PrefetchHooks Function()
        > {
  $$HistoryVisitsTableTableManager(
    _$PrismDatabase db,
    $HistoryVisitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<String> search = const Value.absent(),
              }) => HistoryVisitsCompanion(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
                search: search,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<String> title = const Value.absent(),
                required DateTime visitedAt,
                Value<String> search = const Value.absent(),
              }) => HistoryVisitsCompanion.insert(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
                search: search,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryVisitsTable, HistoryRow>(table),
                  BaseReferences<
                    _$PrismDatabase,
                    $HistoryVisitsTable,
                    HistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $HistoryVisitsTable,
      HistoryRow,
      $$HistoryVisitsTableFilterComposer,
      $$HistoryVisitsTableOrderingComposer,
      $$HistoryVisitsTableAnnotationComposer,
      $$HistoryVisitsTableCreateCompanionBuilder,
      $$HistoryVisitsTableUpdateCompanionBuilder,
      (
        HistoryRow,
        BaseReferences<_$PrismDatabase, $HistoryVisitsTable, HistoryRow>,
      ),
      HistoryRow,
      PrefetchHooks Function()
    >;
typedef $$BookmarkFolderRowsTableCreateCompanionBuilder =
    BookmarkFolderRowsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarkFolderRowsTableUpdateCompanionBuilder =
    BookmarkFolderRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BookmarkFolderRowsTableReferences
    extends
        BaseReferences<
          _$PrismDatabase,
          $BookmarkFolderRowsTable,
          BookmarkFolderRow
        > {
  $$BookmarkFolderRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BookmarkRowsTable, List<BookmarkRow>>
  _bookmarkRowsRefsTable(_$PrismDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarkRows,
    aliasName: 'bookmark_folders__id__bookmarks__folder_id',
  );

  $$BookmarkRowsTableProcessedTableManager get bookmarkRowsRefs {
    final manager = $$BookmarkRowsTableTableManager(
      $_db,
      $_db.bookmarkRows,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarkRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookmarkFolderRowsTableFilterComposer
    extends Composer<_$PrismDatabase, $BookmarkFolderRowsTable> {
  $$BookmarkFolderRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookmarkRowsRefs(
    Expression<bool> Function($$BookmarkRowsTableFilterComposer f) f,
  ) {
    final $$BookmarkRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkRows,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkRowsTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFolderRowsTableOrderingComposer
    extends Composer<_$PrismDatabase, $BookmarkFolderRowsTable> {
  $$BookmarkFolderRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkFolderRowsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $BookmarkFolderRowsTable> {
  $$BookmarkFolderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> bookmarkRowsRefs<T extends Object>(
    Expression<T> Function($$BookmarkRowsTableAnnotationComposer a) f,
  ) {
    final $$BookmarkRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkRows,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarkRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFolderRowsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $BookmarkFolderRowsTable,
          BookmarkFolderRow,
          $$BookmarkFolderRowsTableFilterComposer,
          $$BookmarkFolderRowsTableOrderingComposer,
          $$BookmarkFolderRowsTableAnnotationComposer,
          $$BookmarkFolderRowsTableCreateCompanionBuilder,
          $$BookmarkFolderRowsTableUpdateCompanionBuilder,
          (BookmarkFolderRow, $$BookmarkFolderRowsTableReferences),
          BookmarkFolderRow,
          PrefetchHooks Function({bool bookmarkRowsRefs})
        > {
  $$BookmarkFolderRowsTableTableManager(
    _$PrismDatabase db,
    $BookmarkFolderRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkFolderRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkFolderRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkFolderRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkFolderRowsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarkFolderRowsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarkFolderRowsTable, BookmarkFolderRow>(
                    table,
                  ),
                  $$BookmarkFolderRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarkRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarkRowsRefs) db.bookmarkRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarkRowsRefs)
                    await $_getPrefetchedData<
                      BookmarkFolderRow,
                      $BookmarkFolderRowsTable,
                      BookmarkRow
                    >(
                      currentTable: table,
                      referencedTable: $$BookmarkFolderRowsTableReferences
                          ._bookmarkRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookmarkFolderRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).bookmarkRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkFolderRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $BookmarkFolderRowsTable,
      BookmarkFolderRow,
      $$BookmarkFolderRowsTableFilterComposer,
      $$BookmarkFolderRowsTableOrderingComposer,
      $$BookmarkFolderRowsTableAnnotationComposer,
      $$BookmarkFolderRowsTableCreateCompanionBuilder,
      $$BookmarkFolderRowsTableUpdateCompanionBuilder,
      (BookmarkFolderRow, $$BookmarkFolderRowsTableReferences),
      BookmarkFolderRow,
      PrefetchHooks Function({bool bookmarkRowsRefs})
    >;
typedef $$BookmarkRowsTableCreateCompanionBuilder =
    BookmarkRowsCompanion Function({
      required String id,
      required String title,
      required String url,
      Value<String?> folderId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarkRowsTableUpdateCompanionBuilder =
    BookmarkRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> url,
      Value<String?> folderId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BookmarkRowsTableReferences
    extends BaseReferences<_$PrismDatabase, $BookmarkRowsTable, BookmarkRow> {
  $$BookmarkRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookmarkFolderRowsTable _folderIdTable(_$PrismDatabase db) => db
      .bookmarkFolderRows
      .createAlias('bookmarks__folder_id__bookmark_folders__id');

  $$BookmarkFolderRowsTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$BookmarkFolderRowsTableTableManager(
      $_db,
      $_db.bookmarkFolderRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarkRowsTableFilterComposer
    extends Composer<_$PrismDatabase, $BookmarkRowsTable> {
  $$BookmarkRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BookmarkFolderRowsTableFilterComposer get folderId {
    final $$BookmarkFolderRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolderRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkFolderRowsTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkFolderRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarkRowsTableOrderingComposer
    extends Composer<_$PrismDatabase, $BookmarkRowsTable> {
  $$BookmarkRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BookmarkFolderRowsTableOrderingComposer get folderId {
    final $$BookmarkFolderRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolderRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkFolderRowsTableOrderingComposer(
            $db: $db,
            $table: $db.bookmarkFolderRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarkRowsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $BookmarkRowsTable> {
  $$BookmarkRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BookmarkFolderRowsTableAnnotationComposer get folderId {
    final $$BookmarkFolderRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.folderId,
          referencedTable: $db.bookmarkFolderRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookmarkFolderRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookmarkFolderRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BookmarkRowsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $BookmarkRowsTable,
          BookmarkRow,
          $$BookmarkRowsTableFilterComposer,
          $$BookmarkRowsTableOrderingComposer,
          $$BookmarkRowsTableAnnotationComposer,
          $$BookmarkRowsTableCreateCompanionBuilder,
          $$BookmarkRowsTableUpdateCompanionBuilder,
          (BookmarkRow, $$BookmarkRowsTableReferences),
          BookmarkRow,
          PrefetchHooks Function({bool folderId})
        > {
  $$BookmarkRowsTableTableManager(_$PrismDatabase db, $BookmarkRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkRowsCompanion(
                id: id,
                title: title,
                url: url,
                folderId: folderId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String url,
                Value<String?> folderId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarkRowsCompanion.insert(
                id: id,
                title: title,
                url: url,
                folderId: folderId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarkRowsTable, BookmarkRow>(table),
                  $$BookmarkRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$BookmarkRowsTableReferences
                            ._folderIdTable(db),
                        referencedColumn: $$BookmarkRowsTableReferences
                            ._folderIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $BookmarkRowsTable,
      BookmarkRow,
      $$BookmarkRowsTableFilterComposer,
      $$BookmarkRowsTableOrderingComposer,
      $$BookmarkRowsTableAnnotationComposer,
      $$BookmarkRowsTableCreateCompanionBuilder,
      $$BookmarkRowsTableUpdateCompanionBuilder,
      (BookmarkRow, $$BookmarkRowsTableReferences),
      BookmarkRow,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$DownloadRowsTableCreateCompanionBuilder =
    DownloadRowsCompanion Function({
      required String id,
      required String url,
      required String fileName,
      required String filePath,
      Value<String?> contentUri,
      Value<String?> mimeType,
      Value<int> totalBytes,
      Value<int> receivedBytes,
      required String state,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DownloadRowsTableUpdateCompanionBuilder =
    DownloadRowsCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> fileName,
      Value<String> filePath,
      Value<String?> contentUri,
      Value<String?> mimeType,
      Value<int> totalBytes,
      Value<int> receivedBytes,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DownloadRowsTableFilterComposer
    extends Composer<_$PrismDatabase, $DownloadRowsTable> {
  $$DownloadRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadRowsTableOrderingComposer
    extends Composer<_$PrismDatabase, $DownloadRowsTable> {
  $$DownloadRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadRowsTableAnnotationComposer
    extends Composer<_$PrismDatabase, $DownloadRowsTable> {
  $$DownloadRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DownloadRowsTableTableManager
    extends
        RootTableManager<
          _$PrismDatabase,
          $DownloadRowsTable,
          DownloadRow,
          $$DownloadRowsTableFilterComposer,
          $$DownloadRowsTableOrderingComposer,
          $$DownloadRowsTableAnnotationComposer,
          $$DownloadRowsTableCreateCompanionBuilder,
          $$DownloadRowsTableUpdateCompanionBuilder,
          (
            DownloadRow,
            BaseReferences<_$PrismDatabase, $DownloadRowsTable, DownloadRow>,
          ),
          DownloadRow,
          PrefetchHooks Function()
        > {
  $$DownloadRowsTableTableManager(_$PrismDatabase db, $DownloadRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> contentUri = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadRowsCompanion(
                id: id,
                url: url,
                fileName: fileName,
                filePath: filePath,
                contentUri: contentUri,
                mimeType: mimeType,
                totalBytes: totalBytes,
                receivedBytes: receivedBytes,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                required String fileName,
                required String filePath,
                Value<String?> contentUri = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                required String state,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadRowsCompanion.insert(
                id: id,
                url: url,
                fileName: fileName,
                filePath: filePath,
                contentUri: contentUri,
                mimeType: mimeType,
                totalBytes: totalBytes,
                receivedBytes: receivedBytes,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadRowsTable, DownloadRow>(table),
                  BaseReferences<
                    _$PrismDatabase,
                    $DownloadRowsTable,
                    DownloadRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PrismDatabase,
      $DownloadRowsTable,
      DownloadRow,
      $$DownloadRowsTableFilterComposer,
      $$DownloadRowsTableOrderingComposer,
      $$DownloadRowsTableAnnotationComposer,
      $$DownloadRowsTableCreateCompanionBuilder,
      $$DownloadRowsTableUpdateCompanionBuilder,
      (
        DownloadRow,
        BaseReferences<_$PrismDatabase, $DownloadRowsTable, DownloadRow>,
      ),
      DownloadRow,
      PrefetchHooks Function()
    >;

class $PrismDatabaseManager {
  final _$PrismDatabase _db;
  $PrismDatabaseManager(this._db);
  $$TabRowsTableTableManager get tabRows =>
      $$TabRowsTableTableManager(_db, _db.tabRows);
  $$TabGroupRowsTableTableManager get tabGroupRows =>
      $$TabGroupRowsTableTableManager(_db, _db.tabGroupRows);
  $$SessionMetaTableTableManager get sessionMeta =>
      $$SessionMetaTableTableManager(_db, _db.sessionMeta);
  $$HistoryVisitsTableTableManager get historyVisits =>
      $$HistoryVisitsTableTableManager(_db, _db.historyVisits);
  $$BookmarkFolderRowsTableTableManager get bookmarkFolderRows =>
      $$BookmarkFolderRowsTableTableManager(_db, _db.bookmarkFolderRows);
  $$BookmarkRowsTableTableManager get bookmarkRows =>
      $$BookmarkRowsTableTableManager(_db, _db.bookmarkRows);
  $$DownloadRowsTableTableManager get downloadRows =>
      $$DownloadRowsTableTableManager(_db, _db.downloadRows);
}
