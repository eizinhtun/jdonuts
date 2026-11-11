// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MemberRowsTable extends MemberRows
    with TableInfo<$MemberRowsTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountPhoneMeta = const VerificationMeta(
    'accountPhone',
  );
  @override
  late final GeneratedColumn<String> accountPhone = GeneratedColumn<String>(
    'account_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsToGoldMeta = const VerificationMeta(
    'pointsToGold',
  );
  @override
  late final GeneratedColumn<int> pointsToGold = GeneratedColumn<int>(
    'points_to_gold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsMeta = const VerificationMeta(
    'notifications',
  );
  @override
  late final GeneratedColumn<int> notifications = GeneratedColumn<int>(
    'notifications',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member.svg'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountPhone,
    name,
    tier,
    points,
    pointsToGold,
    notifications,
    image,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_phone')) {
      context.handle(
        _accountPhoneMeta,
        accountPhone.isAcceptableOrUnknown(
          data['account_phone']!,
          _accountPhoneMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('points_to_gold')) {
      context.handle(
        _pointsToGoldMeta,
        pointsToGold.isAcceptableOrUnknown(
          data['points_to_gold']!,
          _pointsToGoldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsToGoldMeta);
    }
    if (data.containsKey('notifications')) {
      context.handle(
        _notificationsMeta,
        notifications.isAcceptableOrUnknown(
          data['notifications']!,
          _notificationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationsMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_phone'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      pointsToGold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_to_gold'],
      )!,
      notifications: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notifications'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
    );
  }

  @override
  $MemberRowsTable createAlias(String alias) {
    return $MemberRowsTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String? accountPhone;
  final String name;
  final String tier;
  final int points;
  final int pointsToGold;
  final int notifications;
  final String image;
  const MemberRow({
    required this.id,
    this.accountPhone,
    required this.name,
    required this.tier,
    required this.points,
    required this.pointsToGold,
    required this.notifications,
    required this.image,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || accountPhone != null) {
      map['account_phone'] = Variable<String>(accountPhone);
    }
    map['name'] = Variable<String>(name);
    map['tier'] = Variable<String>(tier);
    map['points'] = Variable<int>(points);
    map['points_to_gold'] = Variable<int>(pointsToGold);
    map['notifications'] = Variable<int>(notifications);
    map['image'] = Variable<String>(image);
    return map;
  }

  MemberRowsCompanion toCompanion(bool nullToAbsent) {
    return MemberRowsCompanion(
      id: Value(id),
      accountPhone: accountPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(accountPhone),
      name: Value(name),
      tier: Value(tier),
      points: Value(points),
      pointsToGold: Value(pointsToGold),
      notifications: Value(notifications),
      image: Value(image),
    );
  }

  factory MemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      accountPhone: serializer.fromJson<String?>(json['accountPhone']),
      name: serializer.fromJson<String>(json['name']),
      tier: serializer.fromJson<String>(json['tier']),
      points: serializer.fromJson<int>(json['points']),
      pointsToGold: serializer.fromJson<int>(json['pointsToGold']),
      notifications: serializer.fromJson<int>(json['notifications']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountPhone': serializer.toJson<String?>(accountPhone),
      'name': serializer.toJson<String>(name),
      'tier': serializer.toJson<String>(tier),
      'points': serializer.toJson<int>(points),
      'pointsToGold': serializer.toJson<int>(pointsToGold),
      'notifications': serializer.toJson<int>(notifications),
      'image': serializer.toJson<String>(image),
    };
  }

  MemberRow copyWith({
    String? id,
    Value<String?> accountPhone = const Value.absent(),
    String? name,
    String? tier,
    int? points,
    int? pointsToGold,
    int? notifications,
    String? image,
  }) => MemberRow(
    id: id ?? this.id,
    accountPhone: accountPhone.present ? accountPhone.value : this.accountPhone,
    name: name ?? this.name,
    tier: tier ?? this.tier,
    points: points ?? this.points,
    pointsToGold: pointsToGold ?? this.pointsToGold,
    notifications: notifications ?? this.notifications,
    image: image ?? this.image,
  );
  MemberRow copyWithCompanion(MemberRowsCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      accountPhone: data.accountPhone.present
          ? data.accountPhone.value
          : this.accountPhone,
      name: data.name.present ? data.name.value : this.name,
      tier: data.tier.present ? data.tier.value : this.tier,
      points: data.points.present ? data.points.value : this.points,
      pointsToGold: data.pointsToGold.present
          ? data.pointsToGold.value
          : this.pointsToGold,
      notifications: data.notifications.present
          ? data.notifications.value
          : this.notifications,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('accountPhone: $accountPhone, ')
          ..write('name: $name, ')
          ..write('tier: $tier, ')
          ..write('points: $points, ')
          ..write('pointsToGold: $pointsToGold, ')
          ..write('notifications: $notifications, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountPhone,
    name,
    tier,
    points,
    pointsToGold,
    notifications,
    image,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.accountPhone == this.accountPhone &&
          other.name == this.name &&
          other.tier == this.tier &&
          other.points == this.points &&
          other.pointsToGold == this.pointsToGold &&
          other.notifications == this.notifications &&
          other.image == this.image);
}

class MemberRowsCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String?> accountPhone;
  final Value<String> name;
  final Value<String> tier;
  final Value<int> points;
  final Value<int> pointsToGold;
  final Value<int> notifications;
  final Value<String> image;
  final Value<int> rowid;
  const MemberRowsCompanion({
    this.id = const Value.absent(),
    this.accountPhone = const Value.absent(),
    this.name = const Value.absent(),
    this.tier = const Value.absent(),
    this.points = const Value.absent(),
    this.pointsToGold = const Value.absent(),
    this.notifications = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberRowsCompanion.insert({
    required String id,
    this.accountPhone = const Value.absent(),
    required String name,
    required String tier,
    required int points,
    required int pointsToGold,
    required int notifications,
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       tier = Value(tier),
       points = Value(points),
       pointsToGold = Value(pointsToGold),
       notifications = Value(notifications);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? accountPhone,
    Expression<String>? name,
    Expression<String>? tier,
    Expression<int>? points,
    Expression<int>? pointsToGold,
    Expression<int>? notifications,
    Expression<String>? image,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountPhone != null) 'account_phone': accountPhone,
      if (name != null) 'name': name,
      if (tier != null) 'tier': tier,
      if (points != null) 'points': points,
      if (pointsToGold != null) 'points_to_gold': pointsToGold,
      if (notifications != null) 'notifications': notifications,
      if (image != null) 'image': image,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberRowsCompanion copyWith({
    Value<String>? id,
    Value<String?>? accountPhone,
    Value<String>? name,
    Value<String>? tier,
    Value<int>? points,
    Value<int>? pointsToGold,
    Value<int>? notifications,
    Value<String>? image,
    Value<int>? rowid,
  }) {
    return MemberRowsCompanion(
      id: id ?? this.id,
      accountPhone: accountPhone ?? this.accountPhone,
      name: name ?? this.name,
      tier: tier ?? this.tier,
      points: points ?? this.points,
      pointsToGold: pointsToGold ?? this.pointsToGold,
      notifications: notifications ?? this.notifications,
      image: image ?? this.image,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountPhone.present) {
      map['account_phone'] = Variable<String>(accountPhone.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (pointsToGold.present) {
      map['points_to_gold'] = Variable<int>(pointsToGold.value);
    }
    if (notifications.present) {
      map['notifications'] = Variable<int>(notifications.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberRowsCompanion(')
          ..write('id: $id, ')
          ..write('accountPhone: $accountPhone, ')
          ..write('name: $name, ')
          ..write('tier: $tier, ')
          ..write('points: $points, ')
          ..write('pointsToGold: $pointsToGold, ')
          ..write('notifications: $notifications, ')
          ..write('image: $image, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductRowsTable extends ProductRows
    with TableInfo<$ProductRowsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _priceMmkMeta = const VerificationMeta(
    'priceMmk',
  );
  @override
  late final GeneratedColumn<int> priceMmk = GeneratedColumn<int>(
    'price_mmk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedColumn<bool> isNew = GeneratedColumn<bool>(
    'is_new',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_new" IN (0, 1))',
    ),
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<int> discountPercent = GeneratedColumn<int>(
    'discount_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    priceMmk,
    isNew,
    discountPercent,
    image,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_mmk')) {
      context.handle(
        _priceMmkMeta,
        priceMmk.isAcceptableOrUnknown(data['price_mmk']!, _priceMmkMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMmkMeta);
    }
    if (data.containsKey('is_new')) {
      context.handle(
        _isNewMeta,
        isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta),
      );
    } else if (isInserting) {
      context.missing(_isNewMeta);
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priceMmk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_mmk'],
      )!,
      isNew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_new'],
      )!,
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_percent'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $ProductRowsTable createAlias(String alias) {
    return $ProductRowsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String code;
  final String name;
  final int priceMmk;
  final bool isNew;
  final int? discountPercent;
  final String image;
  final String description;
  const ProductRow({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    this.discountPercent,
    required this.image,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['price_mmk'] = Variable<int>(priceMmk);
    map['is_new'] = Variable<bool>(isNew);
    if (!nullToAbsent || discountPercent != null) {
      map['discount_percent'] = Variable<int>(discountPercent);
    }
    map['image'] = Variable<String>(image);
    map['description'] = Variable<String>(description);
    return map;
  }

  ProductRowsCompanion toCompanion(bool nullToAbsent) {
    return ProductRowsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      priceMmk: Value(priceMmk),
      isNew: Value(isNew),
      discountPercent: discountPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercent),
      image: Value(image),
      description: Value(description),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      priceMmk: serializer.fromJson<int>(json['priceMmk']),
      isNew: serializer.fromJson<bool>(json['isNew']),
      discountPercent: serializer.fromJson<int?>(json['discountPercent']),
      image: serializer.fromJson<String>(json['image']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'priceMmk': serializer.toJson<int>(priceMmk),
      'isNew': serializer.toJson<bool>(isNew),
      'discountPercent': serializer.toJson<int?>(discountPercent),
      'image': serializer.toJson<String>(image),
      'description': serializer.toJson<String>(description),
    };
  }

  ProductRow copyWith({
    String? id,
    String? code,
    String? name,
    int? priceMmk,
    bool? isNew,
    Value<int?> discountPercent = const Value.absent(),
    String? image,
    String? description,
  }) => ProductRow(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    priceMmk: priceMmk ?? this.priceMmk,
    isNew: isNew ?? this.isNew,
    discountPercent: discountPercent.present
        ? discountPercent.value
        : this.discountPercent,
    image: image ?? this.image,
    description: description ?? this.description,
  );
  ProductRow copyWithCompanion(ProductRowsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      priceMmk: data.priceMmk.present ? data.priceMmk.value : this.priceMmk,
      isNew: data.isNew.present ? data.isNew.value : this.isNew,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      image: data.image.present ? data.image.value : this.image,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('priceMmk: $priceMmk, ')
          ..write('isNew: $isNew, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('image: $image, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    priceMmk,
    isNew,
    discountPercent,
    image,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.priceMmk == this.priceMmk &&
          other.isNew == this.isNew &&
          other.discountPercent == this.discountPercent &&
          other.image == this.image &&
          other.description == this.description);
}

class ProductRowsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<int> priceMmk;
  final Value<bool> isNew;
  final Value<int?> discountPercent;
  final Value<String> image;
  final Value<String> description;
  final Value<int> rowid;
  const ProductRowsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.priceMmk = const Value.absent(),
    this.isNew = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.image = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductRowsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required int priceMmk,
    required bool isNew,
    this.discountPercent = const Value.absent(),
    required String image,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       priceMmk = Value(priceMmk),
       isNew = Value(isNew),
       image = Value(image),
       description = Value(description);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? priceMmk,
    Expression<bool>? isNew,
    Expression<int>? discountPercent,
    Expression<String>? image,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (priceMmk != null) 'price_mmk': priceMmk,
      if (isNew != null) 'is_new': isNew,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (image != null) 'image': image,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<int>? priceMmk,
    Value<bool>? isNew,
    Value<int?>? discountPercent,
    Value<String>? image,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return ProductRowsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      priceMmk: priceMmk ?? this.priceMmk,
      isNew: isNew ?? this.isNew,
      discountPercent: discountPercent ?? this.discountPercent,
      image: image ?? this.image,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceMmk.present) {
      map['price_mmk'] = Variable<int>(priceMmk.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<int>(discountPercent.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductRowsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('priceMmk: $priceMmk, ')
          ..write('isNew: $isNew, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('image: $image, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BannerRowsTable extends BannerRows
    with TableInfo<$BannerRowsTable, BannerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BannerRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, subtitle, image];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'banner_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BannerRow> instance, {
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
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BannerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BannerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
    );
  }

  @override
  $BannerRowsTable createAlias(String alias) {
    return $BannerRowsTable(attachedDatabase, alias);
  }
}

class BannerRow extends DataClass implements Insertable<BannerRow> {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  const BannerRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['image'] = Variable<String>(image);
    return map;
  }

  BannerRowsCompanion toCompanion(bool nullToAbsent) {
    return BannerRowsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      image: Value(image),
    );
  }

  factory BannerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BannerRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'image': serializer.toJson<String>(image),
    };
  }

  BannerRow copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? image,
  }) => BannerRow(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    image: image ?? this.image,
  );
  BannerRow copyWithCompanion(BannerRowsCompanion data) {
    return BannerRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BannerRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, subtitle, image);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BannerRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.image == this.image);
}

class BannerRowsCompanion extends UpdateCompanion<BannerRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> image;
  final Value<int> rowid;
  const BannerRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BannerRowsCompanion.insert({
    required String id,
    required String title,
    required String subtitle,
    required String image,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       subtitle = Value(subtitle),
       image = Value(image);
  static Insertable<BannerRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? image,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (image != null) 'image': image,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BannerRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? image,
    Value<int>? rowid,
  }) {
    return BannerRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
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
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BannerRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('image: $image, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SectionRowsTable extends SectionRows
    with TableInfo<$SectionRowsTable, SectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdsJsonMeta = const VerificationMeta(
    'productIdsJson',
  );
  @override
  late final GeneratedColumn<String> productIdsJson = GeneratedColumn<String>(
    'product_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, productIdsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'section_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SectionRow> instance, {
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
    if (data.containsKey('product_ids_json')) {
      context.handle(
        _productIdsJsonMeta,
        productIdsJson.isAcceptableOrUnknown(
          data['product_ids_json']!,
          _productIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      productIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_ids_json'],
      )!,
    );
  }

  @override
  $SectionRowsTable createAlias(String alias) {
    return $SectionRowsTable(attachedDatabase, alias);
  }
}

class SectionRow extends DataClass implements Insertable<SectionRow> {
  final String id;
  final String title;
  final String productIdsJson;
  const SectionRow({
    required this.id,
    required this.title,
    required this.productIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['product_ids_json'] = Variable<String>(productIdsJson);
    return map;
  }

  SectionRowsCompanion toCompanion(bool nullToAbsent) {
    return SectionRowsCompanion(
      id: Value(id),
      title: Value(title),
      productIdsJson: Value(productIdsJson),
    );
  }

  factory SectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SectionRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      productIdsJson: serializer.fromJson<String>(json['productIdsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'productIdsJson': serializer.toJson<String>(productIdsJson),
    };
  }

  SectionRow copyWith({String? id, String? title, String? productIdsJson}) =>
      SectionRow(
        id: id ?? this.id,
        title: title ?? this.title,
        productIdsJson: productIdsJson ?? this.productIdsJson,
      );
  SectionRow copyWithCompanion(SectionRowsCompanion data) {
    return SectionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      productIdsJson: data.productIdsJson.present
          ? data.productIdsJson.value
          : this.productIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SectionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('productIdsJson: $productIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, productIdsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.productIdsJson == this.productIdsJson);
}

class SectionRowsCompanion extends UpdateCompanion<SectionRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> productIdsJson;
  final Value<int> rowid;
  const SectionRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.productIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionRowsCompanion.insert({
    required String id,
    required String title,
    required String productIdsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       productIdsJson = Value(productIdsJson);
  static Insertable<SectionRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? productIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (productIdsJson != null) 'product_ids_json': productIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? productIdsJson,
    Value<int>? rowid,
  }) {
    return SectionRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      productIdsJson: productIdsJson ?? this.productIdsJson,
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
    if (productIdsJson.present) {
      map['product_ids_json'] = Variable<String>(productIdsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('productIdsJson: $productIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopRowsTable extends ShopRows with TableInfo<$ShopRowsTable, ShopRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShopRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ShopRowsTable createAlias(String alias) {
    return $ShopRowsTable(attachedDatabase, alias);
  }
}

class ShopRow extends DataClass implements Insertable<ShopRow> {
  final int id;
  final String name;
  const ShopRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ShopRowsCompanion toCompanion(bool nullToAbsent) {
    return ShopRowsCompanion(id: Value(id), name: Value(name));
  }

  factory ShopRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ShopRow copyWith({int? id, String? name}) =>
      ShopRow(id: id ?? this.id, name: name ?? this.name);
  ShopRow copyWithCompanion(ShopRowsCompanion data) {
    return ShopRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopRow && other.id == this.id && other.name == this.name);
}

class ShopRowsCompanion extends UpdateCompanion<ShopRow> {
  final Value<int> id;
  final Value<String> name;
  const ShopRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ShopRowsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ShopRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ShopRowsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ShopRowsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ChallengeRowsTable extends ChallengeRows
    with TableInfo<$ChallengeRowsTable, ChallengeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    progress,
    target,
    points,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeRow> instance, {
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
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $ChallengeRowsTable createAlias(String alias) {
    return $ChallengeRowsTable(attachedDatabase, alias);
  }
}

class ChallengeRow extends DataClass implements Insertable<ChallengeRow> {
  final String id;
  final String title;
  final int progress;
  final int target;
  final int points;
  final String kind;
  const ChallengeRow({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.points,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['progress'] = Variable<int>(progress);
    map['target'] = Variable<int>(target);
    map['points'] = Variable<int>(points);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  ChallengeRowsCompanion toCompanion(bool nullToAbsent) {
    return ChallengeRowsCompanion(
      id: Value(id),
      title: Value(title),
      progress: Value(progress),
      target: Value(target),
      points: Value(points),
      kind: Value(kind),
    );
  }

  factory ChallengeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      progress: serializer.fromJson<int>(json['progress']),
      target: serializer.fromJson<int>(json['target']),
      points: serializer.fromJson<int>(json['points']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'progress': serializer.toJson<int>(progress),
      'target': serializer.toJson<int>(target),
      'points': serializer.toJson<int>(points),
      'kind': serializer.toJson<String>(kind),
    };
  }

  ChallengeRow copyWith({
    String? id,
    String? title,
    int? progress,
    int? target,
    int? points,
    String? kind,
  }) => ChallengeRow(
    id: id ?? this.id,
    title: title ?? this.title,
    progress: progress ?? this.progress,
    target: target ?? this.target,
    points: points ?? this.points,
    kind: kind ?? this.kind,
  );
  ChallengeRow copyWithCompanion(ChallengeRowsCompanion data) {
    return ChallengeRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      progress: data.progress.present ? data.progress.value : this.progress,
      target: data.target.present ? data.target.value : this.target,
      points: data.points.present ? data.points.value : this.points,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('progress: $progress, ')
          ..write('target: $target, ')
          ..write('points: $points, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, progress, target, points, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.progress == this.progress &&
          other.target == this.target &&
          other.points == this.points &&
          other.kind == this.kind);
}

class ChallengeRowsCompanion extends UpdateCompanion<ChallengeRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> progress;
  final Value<int> target;
  final Value<int> points;
  final Value<String> kind;
  final Value<int> rowid;
  const ChallengeRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.progress = const Value.absent(),
    this.target = const Value.absent(),
    this.points = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengeRowsCompanion.insert({
    required String id,
    required String title,
    required int progress,
    required int target,
    required int points,
    required String kind,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       progress = Value(progress),
       target = Value(target),
       points = Value(points),
       kind = Value(kind);
  static Insertable<ChallengeRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? progress,
    Expression<int>? target,
    Expression<int>? points,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (progress != null) 'progress': progress,
      if (target != null) 'target': target,
      if (points != null) 'points': points,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengeRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? progress,
    Value<int>? target,
    Value<int>? points,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return ChallengeRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      points: points ?? this.points,
      kind: kind ?? this.kind,
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
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('progress: $progress, ')
          ..write('target: $target, ')
          ..write('points: $points, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthAccountRowsTable extends AuthAccountRows
    with TableInfo<$AuthAccountRowsTable, AuthAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthAccountRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMillisMeta = const VerificationMeta(
    'birthDateMillis',
  );
  @override
  late final GeneratedColumn<int> birthDateMillis = GeneratedColumn<int>(
    'birth_date_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    phone,
    firstName,
    lastName,
    birthDateMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_account_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('birth_date_millis')) {
      context.handle(
        _birthDateMillisMeta,
        birthDateMillis.isAcceptableOrUnknown(
          data['birth_date_millis']!,
          _birthDateMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {phone};
  @override
  AuthAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthAccountRow(
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      birthDateMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_date_millis'],
      ),
    );
  }

  @override
  $AuthAccountRowsTable createAlias(String alias) {
    return $AuthAccountRowsTable(attachedDatabase, alias);
  }
}

class AuthAccountRow extends DataClass implements Insertable<AuthAccountRow> {
  final String phone;
  final String firstName;
  final String lastName;
  final int? birthDateMillis;
  const AuthAccountRow({
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.birthDateMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['phone'] = Variable<String>(phone);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || birthDateMillis != null) {
      map['birth_date_millis'] = Variable<int>(birthDateMillis);
    }
    return map;
  }

  AuthAccountRowsCompanion toCompanion(bool nullToAbsent) {
    return AuthAccountRowsCompanion(
      phone: Value(phone),
      firstName: Value(firstName),
      lastName: Value(lastName),
      birthDateMillis: birthDateMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDateMillis),
    );
  }

  factory AuthAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthAccountRow(
      phone: serializer.fromJson<String>(json['phone']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      birthDateMillis: serializer.fromJson<int?>(json['birthDateMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'phone': serializer.toJson<String>(phone),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'birthDateMillis': serializer.toJson<int?>(birthDateMillis),
    };
  }

  AuthAccountRow copyWith({
    String? phone,
    String? firstName,
    String? lastName,
    Value<int?> birthDateMillis = const Value.absent(),
  }) => AuthAccountRow(
    phone: phone ?? this.phone,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    birthDateMillis: birthDateMillis.present
        ? birthDateMillis.value
        : this.birthDateMillis,
  );
  AuthAccountRow copyWithCompanion(AuthAccountRowsCompanion data) {
    return AuthAccountRow(
      phone: data.phone.present ? data.phone.value : this.phone,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      birthDateMillis: data.birthDateMillis.present
          ? data.birthDateMillis.value
          : this.birthDateMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthAccountRow(')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDateMillis: $birthDateMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(phone, firstName, lastName, birthDateMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthAccountRow &&
          other.phone == this.phone &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.birthDateMillis == this.birthDateMillis);
}

class AuthAccountRowsCompanion extends UpdateCompanion<AuthAccountRow> {
  final Value<String> phone;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int?> birthDateMillis;
  final Value<int> rowid;
  const AuthAccountRowsCompanion({
    this.phone = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.birthDateMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthAccountRowsCompanion.insert({
    required String phone,
    required String firstName,
    required String lastName,
    this.birthDateMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : phone = Value(phone),
       firstName = Value(firstName),
       lastName = Value(lastName);
  static Insertable<AuthAccountRow> custom({
    Expression<String>? phone,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? birthDateMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (phone != null) 'phone': phone,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDateMillis != null) 'birth_date_millis': birthDateMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthAccountRowsCompanion copyWith({
    Value<String>? phone,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int?>? birthDateMillis,
    Value<int>? rowid,
  }) {
    return AuthAccountRowsCompanion(
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDateMillis: birthDateMillis ?? this.birthDateMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (birthDateMillis.present) {
      map['birth_date_millis'] = Variable<int>(birthDateMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthAccountRowsCompanion(')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDateMillis: $birthDateMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberChallengeRowsTable extends MemberChallengeRows
    with TableInfo<$MemberChallengeRowsTable, MemberChallengeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberChallengeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountPhoneMeta = const VerificationMeta(
    'accountPhone',
  );
  @override
  late final GeneratedColumn<String> accountPhone = GeneratedColumn<String>(
    'account_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeIdMeta = const VerificationMeta(
    'challengeId',
  );
  @override
  late final GeneratedColumn<String> challengeId = GeneratedColumn<String>(
    'challenge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountPhone, challengeId, progress];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_challenge_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberChallengeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_phone')) {
      context.handle(
        _accountPhoneMeta,
        accountPhone.isAcceptableOrUnknown(
          data['account_phone']!,
          _accountPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountPhoneMeta);
    }
    if (data.containsKey('challenge_id')) {
      context.handle(
        _challengeIdMeta,
        challengeId.isAcceptableOrUnknown(
          data['challenge_id']!,
          _challengeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeIdMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountPhone, challengeId};
  @override
  MemberChallengeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberChallengeRow(
      accountPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_phone'],
      )!,
      challengeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_id'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
    );
  }

  @override
  $MemberChallengeRowsTable createAlias(String alias) {
    return $MemberChallengeRowsTable(attachedDatabase, alias);
  }
}

class MemberChallengeRow extends DataClass
    implements Insertable<MemberChallengeRow> {
  final String accountPhone;
  final String challengeId;
  final int progress;
  const MemberChallengeRow({
    required this.accountPhone,
    required this.challengeId,
    required this.progress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_phone'] = Variable<String>(accountPhone);
    map['challenge_id'] = Variable<String>(challengeId);
    map['progress'] = Variable<int>(progress);
    return map;
  }

  MemberChallengeRowsCompanion toCompanion(bool nullToAbsent) {
    return MemberChallengeRowsCompanion(
      accountPhone: Value(accountPhone),
      challengeId: Value(challengeId),
      progress: Value(progress),
    );
  }

  factory MemberChallengeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberChallengeRow(
      accountPhone: serializer.fromJson<String>(json['accountPhone']),
      challengeId: serializer.fromJson<String>(json['challengeId']),
      progress: serializer.fromJson<int>(json['progress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountPhone': serializer.toJson<String>(accountPhone),
      'challengeId': serializer.toJson<String>(challengeId),
      'progress': serializer.toJson<int>(progress),
    };
  }

  MemberChallengeRow copyWith({
    String? accountPhone,
    String? challengeId,
    int? progress,
  }) => MemberChallengeRow(
    accountPhone: accountPhone ?? this.accountPhone,
    challengeId: challengeId ?? this.challengeId,
    progress: progress ?? this.progress,
  );
  MemberChallengeRow copyWithCompanion(MemberChallengeRowsCompanion data) {
    return MemberChallengeRow(
      accountPhone: data.accountPhone.present
          ? data.accountPhone.value
          : this.accountPhone,
      challengeId: data.challengeId.present
          ? data.challengeId.value
          : this.challengeId,
      progress: data.progress.present ? data.progress.value : this.progress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberChallengeRow(')
          ..write('accountPhone: $accountPhone, ')
          ..write('challengeId: $challengeId, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountPhone, challengeId, progress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberChallengeRow &&
          other.accountPhone == this.accountPhone &&
          other.challengeId == this.challengeId &&
          other.progress == this.progress);
}

class MemberChallengeRowsCompanion extends UpdateCompanion<MemberChallengeRow> {
  final Value<String> accountPhone;
  final Value<String> challengeId;
  final Value<int> progress;
  final Value<int> rowid;
  const MemberChallengeRowsCompanion({
    this.accountPhone = const Value.absent(),
    this.challengeId = const Value.absent(),
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberChallengeRowsCompanion.insert({
    required String accountPhone,
    required String challengeId,
    required int progress,
    this.rowid = const Value.absent(),
  }) : accountPhone = Value(accountPhone),
       challengeId = Value(challengeId),
       progress = Value(progress);
  static Insertable<MemberChallengeRow> custom({
    Expression<String>? accountPhone,
    Expression<String>? challengeId,
    Expression<int>? progress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountPhone != null) 'account_phone': accountPhone,
      if (challengeId != null) 'challenge_id': challengeId,
      if (progress != null) 'progress': progress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberChallengeRowsCompanion copyWith({
    Value<String>? accountPhone,
    Value<String>? challengeId,
    Value<int>? progress,
    Value<int>? rowid,
  }) {
    return MemberChallengeRowsCompanion(
      accountPhone: accountPhone ?? this.accountPhone,
      challengeId: challengeId ?? this.challengeId,
      progress: progress ?? this.progress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountPhone.present) {
      map['account_phone'] = Variable<String>(accountPhone.value);
    }
    if (challengeId.present) {
      map['challenge_id'] = Variable<String>(challengeId.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberChallengeRowsCompanion(')
          ..write('accountPhone: $accountPhone, ')
          ..write('challengeId: $challengeId, ')
          ..write('progress: $progress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MemberRowsTable memberRows = $MemberRowsTable(this);
  late final $ProductRowsTable productRows = $ProductRowsTable(this);
  late final $BannerRowsTable bannerRows = $BannerRowsTable(this);
  late final $SectionRowsTable sectionRows = $SectionRowsTable(this);
  late final $ShopRowsTable shopRows = $ShopRowsTable(this);
  late final $ChallengeRowsTable challengeRows = $ChallengeRowsTable(this);
  late final $AuthAccountRowsTable authAccountRows = $AuthAccountRowsTable(
    this,
  );
  late final $MemberChallengeRowsTable memberChallengeRows =
      $MemberChallengeRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    memberRows,
    productRows,
    bannerRows,
    sectionRows,
    shopRows,
    challengeRows,
    authAccountRows,
    memberChallengeRows,
  ];
}

typedef $$MemberRowsTableCreateCompanionBuilder = MemberRowsCompanion Function({
  required String id,
  Value<String?> accountPhone,
  required String name,
  required String tier,
  required int points,
  required int pointsToGold,
  required int notifications,
  Value<String> image,
  Value<int> rowid,
});
typedef $$MemberRowsTableUpdateCompanionBuilder = MemberRowsCompanion Function({
  Value<String> id,
  Value<String?> accountPhone,
  Value<String> name,
  Value<String> tier,
  Value<int> points,
  Value<int> pointsToGold,
  Value<int> notifications,
  Value<String> image,
  Value<int> rowid,
});

class $$MemberRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MemberRowsTable> {
  $$MemberRowsTableFilterComposer({
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

  ColumnFilters<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsToGold => $composableBuilder(
    column: $table.pointsToGold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberRowsTable> {
  $$MemberRowsTableOrderingComposer({
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

  ColumnOrderings<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsToGold => $composableBuilder(
    column: $table.pointsToGold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberRowsTable> {
  $$MemberRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get pointsToGold => $composableBuilder(
    column: $table.pointsToGold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => column,
  );

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);
}

class $$MemberRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberRowsTable,
          MemberRow,
          $$MemberRowsTableFilterComposer,
          $$MemberRowsTableOrderingComposer,
          $$MemberRowsTableAnnotationComposer,
          $$MemberRowsTableCreateCompanionBuilder,
          $$MemberRowsTableUpdateCompanionBuilder,
          (
            MemberRow,
            BaseReferences<_$AppDatabase, $MemberRowsTable, MemberRow>,
          ),
          MemberRow,
          PrefetchHooks Function()
        > {
  $$MemberRowsTableTableManager(_$AppDatabase db, $MemberRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> accountPhone = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> pointsToGold = const Value.absent(),
                Value<int> notifications = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberRowsCompanion(
                id: id,
                accountPhone: accountPhone,
                name: name,
                tier: tier,
                points: points,
                pointsToGold: pointsToGold,
                notifications: notifications,
                image: image,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> accountPhone = const Value.absent(),
                required String name,
                required String tier,
                required int points,
                required int pointsToGold,
                required int notifications,
                Value<String> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberRowsCompanion.insert(
                id: id,
                accountPhone: accountPhone,
                name: name,
                tier: tier,
                points: points,
                pointsToGold: pointsToGold,
                notifications: notifications,
                image: image,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemberRowsTable, MemberRow>(table),
                  BaseReferences<_$AppDatabase, $MemberRowsTable, MemberRow>(
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

typedef $$MemberRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberRowsTable,
      MemberRow,
      $$MemberRowsTableFilterComposer,
      $$MemberRowsTableOrderingComposer,
      $$MemberRowsTableAnnotationComposer,
      $$MemberRowsTableCreateCompanionBuilder,
      $$MemberRowsTableUpdateCompanionBuilder,
      (MemberRow, BaseReferences<_$AppDatabase, $MemberRowsTable, MemberRow>),
      MemberRow,
      PrefetchHooks Function()
    >;
typedef $$ProductRowsTableCreateCompanionBuilder =
    ProductRowsCompanion Function({
      required String id,
      required String code,
      required String name,
      required int priceMmk,
      required bool isNew,
      Value<int?> discountPercent,
      required String image,
      required String description,
      Value<int> rowid,
    });
typedef $$ProductRowsTableUpdateCompanionBuilder =
    ProductRowsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<int> priceMmk,
      Value<bool> isNew,
      Value<int?> discountPercent,
      Value<String> image,
      Value<String> description,
      Value<int> rowid,
    });

class $$ProductRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMmk => $composableBuilder(
    column: $table.priceMmk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMmk => $composableBuilder(
    column: $table.priceMmk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priceMmk =>
      $composableBuilder(column: $table.priceMmk, builder: (column) => column);

  GeneratedColumn<bool> get isNew =>
      $composableBuilder(column: $table.isNew, builder: (column) => column);

  GeneratedColumn<int> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$ProductRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductRowsTable,
          ProductRow,
          $$ProductRowsTableFilterComposer,
          $$ProductRowsTableOrderingComposer,
          $$ProductRowsTableAnnotationComposer,
          $$ProductRowsTableCreateCompanionBuilder,
          $$ProductRowsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductRowsTableTableManager(_$AppDatabase db, $ProductRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priceMmk = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<int?> discountPercent = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductRowsCompanion(
                id: id,
                code: code,
                name: name,
                priceMmk: priceMmk,
                isNew: isNew,
                discountPercent: discountPercent,
                image: image,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required int priceMmk,
                required bool isNew,
                Value<int?> discountPercent = const Value.absent(),
                required String image,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => ProductRowsCompanion.insert(
                id: id,
                code: code,
                name: name,
                priceMmk: priceMmk,
                isNew: isNew,
                discountPercent: discountPercent,
                image: image,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductRowsTable, ProductRow>(table),
                  BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>(
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

typedef $$ProductRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductRowsTable,
      ProductRow,
      $$ProductRowsTableFilterComposer,
      $$ProductRowsTableOrderingComposer,
      $$ProductRowsTableAnnotationComposer,
      $$ProductRowsTableCreateCompanionBuilder,
      $$ProductRowsTableUpdateCompanionBuilder,
      (
        ProductRow,
        BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
      ),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$BannerRowsTableCreateCompanionBuilder = BannerRowsCompanion Function({
  required String id,
  required String title,
  required String subtitle,
  required String image,
  Value<int> rowid,
});
typedef $$BannerRowsTableUpdateCompanionBuilder = BannerRowsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> subtitle,
  Value<String> image,
  Value<int> rowid,
});

class $$BannerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BannerRowsTable> {
  $$BannerRowsTableFilterComposer({
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

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BannerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BannerRowsTable> {
  $$BannerRowsTableOrderingComposer({
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

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BannerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BannerRowsTable> {
  $$BannerRowsTableAnnotationComposer({
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

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);
}

class $$BannerRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BannerRowsTable,
          BannerRow,
          $$BannerRowsTableFilterComposer,
          $$BannerRowsTableOrderingComposer,
          $$BannerRowsTableAnnotationComposer,
          $$BannerRowsTableCreateCompanionBuilder,
          $$BannerRowsTableUpdateCompanionBuilder,
          (
            BannerRow,
            BaseReferences<_$AppDatabase, $BannerRowsTable, BannerRow>,
          ),
          BannerRow,
          PrefetchHooks Function()
        > {
  $$BannerRowsTableTableManager(_$AppDatabase db, $BannerRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BannerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BannerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BannerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BannerRowsCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                image: image,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String subtitle,
                required String image,
                Value<int> rowid = const Value.absent(),
              }) => BannerRowsCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                image: image,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BannerRowsTable, BannerRow>(table),
                  BaseReferences<_$AppDatabase, $BannerRowsTable, BannerRow>(
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

typedef $$BannerRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BannerRowsTable,
      BannerRow,
      $$BannerRowsTableFilterComposer,
      $$BannerRowsTableOrderingComposer,
      $$BannerRowsTableAnnotationComposer,
      $$BannerRowsTableCreateCompanionBuilder,
      $$BannerRowsTableUpdateCompanionBuilder,
      (BannerRow, BaseReferences<_$AppDatabase, $BannerRowsTable, BannerRow>),
      BannerRow,
      PrefetchHooks Function()
    >;
typedef $$SectionRowsTableCreateCompanionBuilder =
    SectionRowsCompanion Function({
      required String id,
      required String title,
      required String productIdsJson,
      Value<int> rowid,
    });
typedef $$SectionRowsTableUpdateCompanionBuilder =
    SectionRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> productIdsJson,
      Value<int> rowid,
    });

class $$SectionRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionRowsTable> {
  $$SectionRowsTableFilterComposer({
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

  ColumnFilters<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SectionRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionRowsTable> {
  $$SectionRowsTableOrderingComposer({
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

  ColumnOrderings<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionRowsTable> {
  $$SectionRowsTableAnnotationComposer({
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

  GeneratedColumn<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => column,
  );
}

class $$SectionRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionRowsTable,
          SectionRow,
          $$SectionRowsTableFilterComposer,
          $$SectionRowsTableOrderingComposer,
          $$SectionRowsTableAnnotationComposer,
          $$SectionRowsTableCreateCompanionBuilder,
          $$SectionRowsTableUpdateCompanionBuilder,
          (
            SectionRow,
            BaseReferences<_$AppDatabase, $SectionRowsTable, SectionRow>,
          ),
          SectionRow,
          PrefetchHooks Function()
        > {
  $$SectionRowsTableTableManager(_$AppDatabase db, $SectionRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> productIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionRowsCompanion(
                id: id,
                title: title,
                productIdsJson: productIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String productIdsJson,
                Value<int> rowid = const Value.absent(),
              }) => SectionRowsCompanion.insert(
                id: id,
                title: title,
                productIdsJson: productIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionRowsTable, SectionRow>(table),
                  BaseReferences<_$AppDatabase, $SectionRowsTable, SectionRow>(
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

typedef $$SectionRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionRowsTable,
      SectionRow,
      $$SectionRowsTableFilterComposer,
      $$SectionRowsTableOrderingComposer,
      $$SectionRowsTableAnnotationComposer,
      $$SectionRowsTableCreateCompanionBuilder,
      $$SectionRowsTableUpdateCompanionBuilder,
      (
        SectionRow,
        BaseReferences<_$AppDatabase, $SectionRowsTable, SectionRow>,
      ),
      SectionRow,
      PrefetchHooks Function()
    >;
typedef $$ShopRowsTableCreateCompanionBuilder = ShopRowsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ShopRowsTableUpdateCompanionBuilder = ShopRowsCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$ShopRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopRowsTable> {
  $$ShopRowsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopRowsTable> {
  $$ShopRowsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopRowsTable> {
  $$ShopRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ShopRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopRowsTable,
          ShopRow,
          $$ShopRowsTableFilterComposer,
          $$ShopRowsTableOrderingComposer,
          $$ShopRowsTableAnnotationComposer,
          $$ShopRowsTableCreateCompanionBuilder,
          $$ShopRowsTableUpdateCompanionBuilder,
          (ShopRow, BaseReferences<_$AppDatabase, $ShopRowsTable, ShopRow>),
          ShopRow,
          PrefetchHooks Function()
        > {
  $$ShopRowsTableTableManager(_$AppDatabase db, $ShopRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => ShopRowsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => ShopRowsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShopRowsTable, ShopRow>(table),
                  BaseReferences<_$AppDatabase, $ShopRowsTable, ShopRow>(
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

typedef $$ShopRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopRowsTable,
      ShopRow,
      $$ShopRowsTableFilterComposer,
      $$ShopRowsTableOrderingComposer,
      $$ShopRowsTableAnnotationComposer,
      $$ShopRowsTableCreateCompanionBuilder,
      $$ShopRowsTableUpdateCompanionBuilder,
      (ShopRow, BaseReferences<_$AppDatabase, $ShopRowsTable, ShopRow>),
      ShopRow,
      PrefetchHooks Function()
    >;
typedef $$ChallengeRowsTableCreateCompanionBuilder =
    ChallengeRowsCompanion Function({
      required String id,
      required String title,
      required int progress,
      required int target,
      required int points,
      required String kind,
      Value<int> rowid,
    });
typedef $$ChallengeRowsTableUpdateCompanionBuilder =
    ChallengeRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> progress,
      Value<int> target,
      Value<int> points,
      Value<String> kind,
      Value<int> rowid,
    });

class $$ChallengeRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableFilterComposer({
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

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengeRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableOrderingComposer({
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

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableAnnotationComposer({
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

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$ChallengeRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeRowsTable,
          ChallengeRow,
          $$ChallengeRowsTableFilterComposer,
          $$ChallengeRowsTableOrderingComposer,
          $$ChallengeRowsTableAnnotationComposer,
          $$ChallengeRowsTableCreateCompanionBuilder,
          $$ChallengeRowsTableUpdateCompanionBuilder,
          (
            ChallengeRow,
            BaseReferences<_$AppDatabase, $ChallengeRowsTable, ChallengeRow>,
          ),
          ChallengeRow,
          PrefetchHooks Function()
        > {
  $$ChallengeRowsTableTableManager(_$AppDatabase db, $ChallengeRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeRowsCompanion(
                id: id,
                title: title,
                progress: progress,
                target: target,
                points: points,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int progress,
                required int target,
                required int points,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => ChallengeRowsCompanion.insert(
                id: id,
                title: title,
                progress: progress,
                target: target,
                points: points,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChallengeRowsTable, ChallengeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChallengeRowsTable,
                    ChallengeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeRowsTable,
      ChallengeRow,
      $$ChallengeRowsTableFilterComposer,
      $$ChallengeRowsTableOrderingComposer,
      $$ChallengeRowsTableAnnotationComposer,
      $$ChallengeRowsTableCreateCompanionBuilder,
      $$ChallengeRowsTableUpdateCompanionBuilder,
      (
        ChallengeRow,
        BaseReferences<_$AppDatabase, $ChallengeRowsTable, ChallengeRow>,
      ),
      ChallengeRow,
      PrefetchHooks Function()
    >;
typedef $$AuthAccountRowsTableCreateCompanionBuilder =
    AuthAccountRowsCompanion Function({
      required String phone,
      required String firstName,
      required String lastName,
      Value<int?> birthDateMillis,
      Value<int> rowid,
    });
typedef $$AuthAccountRowsTableUpdateCompanionBuilder =
    AuthAccountRowsCompanion Function({
      Value<String> phone,
      Value<String> firstName,
      Value<String> lastName,
      Value<int?> birthDateMillis,
      Value<int> rowid,
    });

class $$AuthAccountRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AuthAccountRowsTable> {
  $$AuthAccountRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthDateMillis => $composableBuilder(
    column: $table.birthDateMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthAccountRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthAccountRowsTable> {
  $$AuthAccountRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthDateMillis => $composableBuilder(
    column: $table.birthDateMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthAccountRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthAccountRowsTable> {
  $$AuthAccountRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get birthDateMillis => $composableBuilder(
    column: $table.birthDateMillis,
    builder: (column) => column,
  );
}

class $$AuthAccountRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthAccountRowsTable,
          AuthAccountRow,
          $$AuthAccountRowsTableFilterComposer,
          $$AuthAccountRowsTableOrderingComposer,
          $$AuthAccountRowsTableAnnotationComposer,
          $$AuthAccountRowsTableCreateCompanionBuilder,
          $$AuthAccountRowsTableUpdateCompanionBuilder,
          (
            AuthAccountRow,
            BaseReferences<
              _$AppDatabase,
              $AuthAccountRowsTable,
              AuthAccountRow
            >,
          ),
          AuthAccountRow,
          PrefetchHooks Function()
        > {
  $$AuthAccountRowsTableTableManager(
    _$AppDatabase db,
    $AuthAccountRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthAccountRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthAccountRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthAccountRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> phone = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int?> birthDateMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthAccountRowsCompanion(
                phone: phone,
                firstName: firstName,
                lastName: lastName,
                birthDateMillis: birthDateMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String phone,
                required String firstName,
                required String lastName,
                Value<int?> birthDateMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthAccountRowsCompanion.insert(
                phone: phone,
                firstName: firstName,
                lastName: lastName,
                birthDateMillis: birthDateMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthAccountRowsTable, AuthAccountRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AuthAccountRowsTable,
                    AuthAccountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthAccountRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthAccountRowsTable,
      AuthAccountRow,
      $$AuthAccountRowsTableFilterComposer,
      $$AuthAccountRowsTableOrderingComposer,
      $$AuthAccountRowsTableAnnotationComposer,
      $$AuthAccountRowsTableCreateCompanionBuilder,
      $$AuthAccountRowsTableUpdateCompanionBuilder,
      (
        AuthAccountRow,
        BaseReferences<_$AppDatabase, $AuthAccountRowsTable, AuthAccountRow>,
      ),
      AuthAccountRow,
      PrefetchHooks Function()
    >;
typedef $$MemberChallengeRowsTableCreateCompanionBuilder =
    MemberChallengeRowsCompanion Function({
      required String accountPhone,
      required String challengeId,
      required int progress,
      Value<int> rowid,
    });
typedef $$MemberChallengeRowsTableUpdateCompanionBuilder =
    MemberChallengeRowsCompanion Function({
      Value<String> accountPhone,
      Value<String> challengeId,
      Value<int> progress,
      Value<int> rowid,
    });

class $$MemberChallengeRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MemberChallengeRowsTable> {
  $$MemberChallengeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberChallengeRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberChallengeRowsTable> {
  $$MemberChallengeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberChallengeRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberChallengeRowsTable> {
  $$MemberChallengeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountPhone => $composableBuilder(
    column: $table.accountPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);
}

class $$MemberChallengeRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberChallengeRowsTable,
          MemberChallengeRow,
          $$MemberChallengeRowsTableFilterComposer,
          $$MemberChallengeRowsTableOrderingComposer,
          $$MemberChallengeRowsTableAnnotationComposer,
          $$MemberChallengeRowsTableCreateCompanionBuilder,
          $$MemberChallengeRowsTableUpdateCompanionBuilder,
          (
            MemberChallengeRow,
            BaseReferences<
              _$AppDatabase,
              $MemberChallengeRowsTable,
              MemberChallengeRow
            >,
          ),
          MemberChallengeRow,
          PrefetchHooks Function()
        > {
  $$MemberChallengeRowsTableTableManager(
    _$AppDatabase db,
    $MemberChallengeRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberChallengeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberChallengeRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MemberChallengeRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountPhone = const Value.absent(),
                Value<String> challengeId = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberChallengeRowsCompanion(
                accountPhone: accountPhone,
                challengeId: challengeId,
                progress: progress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountPhone,
                required String challengeId,
                required int progress,
                Value<int> rowid = const Value.absent(),
              }) => MemberChallengeRowsCompanion.insert(
                accountPhone: accountPhone,
                challengeId: challengeId,
                progress: progress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemberChallengeRowsTable, MemberChallengeRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MemberChallengeRowsTable,
                    MemberChallengeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemberChallengeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberChallengeRowsTable,
      MemberChallengeRow,
      $$MemberChallengeRowsTableFilterComposer,
      $$MemberChallengeRowsTableOrderingComposer,
      $$MemberChallengeRowsTableAnnotationComposer,
      $$MemberChallengeRowsTableCreateCompanionBuilder,
      $$MemberChallengeRowsTableUpdateCompanionBuilder,
      (
        MemberChallengeRow,
        BaseReferences<
          _$AppDatabase,
          $MemberChallengeRowsTable,
          MemberChallengeRow
        >,
      ),
      MemberChallengeRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MemberRowsTableTableManager get memberRows =>
      $$MemberRowsTableTableManager(_db, _db.memberRows);
  $$ProductRowsTableTableManager get productRows =>
      $$ProductRowsTableTableManager(_db, _db.productRows);
  $$BannerRowsTableTableManager get bannerRows =>
      $$BannerRowsTableTableManager(_db, _db.bannerRows);
  $$SectionRowsTableTableManager get sectionRows =>
      $$SectionRowsTableTableManager(_db, _db.sectionRows);
  $$ShopRowsTableTableManager get shopRows =>
      $$ShopRowsTableTableManager(_db, _db.shopRows);
  $$ChallengeRowsTableTableManager get challengeRows =>
      $$ChallengeRowsTableTableManager(_db, _db.challengeRows);
  $$AuthAccountRowsTableTableManager get authAccountRows =>
      $$AuthAccountRowsTableTableManager(_db, _db.authAccountRows);
  $$MemberChallengeRowsTableTableManager get memberChallengeRows =>
      $$MemberChallengeRowsTableTableManager(_db, _db.memberChallengeRows);
}
