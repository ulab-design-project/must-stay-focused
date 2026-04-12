// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_usage.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppUsageCollection on Isar {
  IsarCollection<AppUsage> get appUsages => this.collection();
}

const AppUsageSchema = CollectionSchema(
  name: r'AppUsage',
  id: 3726360622219358497,
  properties: {
    r'appId': PropertySchema(
      id: 0,
      name: r'appId',
      type: IsarType.string,
    ),
    r'isLimitedToday': PropertySchema(
      id: 1,
      name: r'isLimitedToday',
      type: IsarType.bool,
    ),
    r'isTracked': PropertySchema(
      id: 2,
      name: r'isTracked',
      type: IsarType.bool,
    ),
    r'maxDailyTimeLimit': PropertySchema(
      id: 3,
      name: r'maxDailyTimeLimit',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'totalUsedTime': PropertySchema(
      id: 5,
      name: r'totalUsedTime',
      type: IsarType.long,
    )
  },
  estimateSize: _appUsageEstimateSize,
  serialize: _appUsageSerialize,
  deserialize: _appUsageDeserialize,
  deserializeProp: _appUsageDeserializeProp,
  idName: r'id',
  indexes: {
    r'appId': IndexSchema(
      id: -6867569882656943350,
      name: r'appId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'appId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'user': LinkSchema(
      id: 1511194618298856602,
      name: r'user',
      target: r'UserSettings',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _appUsageGetId,
  getLinks: _appUsageGetLinks,
  attach: _appUsageAttach,
  version: '3.1.0+1',
);

int _appUsageEstimateSize(
  AppUsage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _appUsageSerialize(
  AppUsage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appId);
  writer.writeBool(offsets[1], object.isLimitedToday);
  writer.writeBool(offsets[2], object.isTracked);
  writer.writeLong(offsets[3], object.maxDailyTimeLimit);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.totalUsedTime);
}

AppUsage _appUsageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppUsage();
  object.appId = reader.readString(offsets[0]);
  object.id = id;
  object.isLimitedToday = reader.readBool(offsets[1]);
  object.isTracked = reader.readBool(offsets[2]);
  object.maxDailyTimeLimit = reader.readLong(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.totalUsedTime = reader.readLong(offsets[5]);
  return object;
}

P _appUsageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appUsageGetId(AppUsage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appUsageGetLinks(AppUsage object) {
  return [object.user];
}

void _appUsageAttach(IsarCollection<dynamic> col, Id id, AppUsage object) {
  object.id = id;
  object.user.attach(col, col.isar.collection<UserSettings>(), r'user', id);
}

extension AppUsageByIndex on IsarCollection<AppUsage> {
  Future<AppUsage?> getByAppId(String appId) {
    return getByIndex(r'appId', [appId]);
  }

  AppUsage? getByAppIdSync(String appId) {
    return getByIndexSync(r'appId', [appId]);
  }

  Future<bool> deleteByAppId(String appId) {
    return deleteByIndex(r'appId', [appId]);
  }

  bool deleteByAppIdSync(String appId) {
    return deleteByIndexSync(r'appId', [appId]);
  }

  Future<List<AppUsage?>> getAllByAppId(List<String> appIdValues) {
    final values = appIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'appId', values);
  }

  List<AppUsage?> getAllByAppIdSync(List<String> appIdValues) {
    final values = appIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'appId', values);
  }

  Future<int> deleteAllByAppId(List<String> appIdValues) {
    final values = appIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'appId', values);
  }

  int deleteAllByAppIdSync(List<String> appIdValues) {
    final values = appIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'appId', values);
  }

  Future<Id> putByAppId(AppUsage object) {
    return putByIndex(r'appId', object);
  }

  Id putByAppIdSync(AppUsage object, {bool saveLinks = true}) {
    return putByIndexSync(r'appId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAppId(List<AppUsage> objects) {
    return putAllByIndex(r'appId', objects);
  }

  List<Id> putAllByAppIdSync(List<AppUsage> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'appId', objects, saveLinks: saveLinks);
  }
}

extension AppUsageQueryWhereSort on QueryBuilder<AppUsage, AppUsage, QWhere> {
  QueryBuilder<AppUsage, AppUsage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppUsageQueryWhere on QueryBuilder<AppUsage, AppUsage, QWhereClause> {
  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> appIdEqualTo(
      String appId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'appId',
        value: [appId],
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterWhereClause> appIdNotEqualTo(
      String appId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [],
              upper: [appId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [appId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [appId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [],
              upper: [appId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AppUsageQueryFilter
    on QueryBuilder<AppUsage, AppUsage, QFilterCondition> {
  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> appIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> isLimitedTodayEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLimitedToday',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> isTrackedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTracked',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition>
      maxDailyTimeLimitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxDailyTimeLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition>
      maxDailyTimeLimitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxDailyTimeLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition>
      maxDailyTimeLimitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxDailyTimeLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition>
      maxDailyTimeLimitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxDailyTimeLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> totalUsedTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalUsedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition>
      totalUsedTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalUsedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> totalUsedTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalUsedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> totalUsedTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalUsedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppUsageQueryObject
    on QueryBuilder<AppUsage, AppUsage, QFilterCondition> {}

extension AppUsageQueryLinks
    on QueryBuilder<AppUsage, AppUsage, QFilterCondition> {
  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> user(
      FilterQuery<UserSettings> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'user');
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterFilterCondition> userIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'user', 0, true, 0, true);
    });
  }
}

extension AppUsageQuerySortBy on QueryBuilder<AppUsage, AppUsage, QSortBy> {
  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByAppId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByAppIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByIsLimitedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLimitedToday', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByIsLimitedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLimitedToday', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByIsTracked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTracked', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByIsTrackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTracked', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByMaxDailyTimeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDailyTimeLimit', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByMaxDailyTimeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDailyTimeLimit', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByTotalUsedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsedTime', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> sortByTotalUsedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsedTime', Sort.desc);
    });
  }
}

extension AppUsageQuerySortThenBy
    on QueryBuilder<AppUsage, AppUsage, QSortThenBy> {
  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByAppId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByAppIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByIsLimitedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLimitedToday', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByIsLimitedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLimitedToday', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByIsTracked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTracked', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByIsTrackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTracked', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByMaxDailyTimeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDailyTimeLimit', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByMaxDailyTimeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDailyTimeLimit', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByTotalUsedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsedTime', Sort.asc);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QAfterSortBy> thenByTotalUsedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsedTime', Sort.desc);
    });
  }
}

extension AppUsageQueryWhereDistinct
    on QueryBuilder<AppUsage, AppUsage, QDistinct> {
  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByAppId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByIsLimitedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLimitedToday');
    });
  }

  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByIsTracked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTracked');
    });
  }

  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByMaxDailyTimeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxDailyTimeLimit');
    });
  }

  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppUsage, AppUsage, QDistinct> distinctByTotalUsedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalUsedTime');
    });
  }
}

extension AppUsageQueryProperty
    on QueryBuilder<AppUsage, AppUsage, QQueryProperty> {
  QueryBuilder<AppUsage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppUsage, String, QQueryOperations> appIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appId');
    });
  }

  QueryBuilder<AppUsage, bool, QQueryOperations> isLimitedTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLimitedToday');
    });
  }

  QueryBuilder<AppUsage, bool, QQueryOperations> isTrackedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTracked');
    });
  }

  QueryBuilder<AppUsage, int, QQueryOperations> maxDailyTimeLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxDailyTimeLimit');
    });
  }

  QueryBuilder<AppUsage, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AppUsage, int, QQueryOperations> totalUsedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalUsedTime');
    });
  }
}
