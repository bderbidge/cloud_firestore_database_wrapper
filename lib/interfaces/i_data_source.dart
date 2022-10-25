import "dart:async";

import 'package:cloud_firestore_database_wrapper/src/base_model.dart';

enum WhereQueryType {
  isEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
  isNotEqualTo,
}

final Set<WhereQueryType> queryRange = {
  WhereQueryType.isLessThan,
  WhereQueryType.isLessThanOrEqualTo,
  WhereQueryType.isGreaterThan,
  WhereQueryType.isGreaterThanOrEqualTo,
};

class QueryType {
  // ignore: prefer_typing_uninitialized_variables
  final id;
  final dynamic value;
  final WhereQueryType? whereQueryType;
  QueryType({this.id, this.value, this.whereQueryType});
}

abstract class IDataSource {
  Future<Model> getSingleById<Model extends BaseModel>(String path);

  Stream<Model> getStreamByID<Model extends BaseModel>(String path);

  Future<List<Model>> getCollectionwithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      String? startAfterID});

  Stream<List<Model>> getCollectionStream<Model extends BaseModel>(
    String path, {
    List<QueryType>? where,
    Map<String, bool>? orderby,
    int? limit,
  });

  Future<String> addDocToCollection<Model extends BaseModel>(
      String path, BaseModel data);

  Future<void> update(String path, BaseModel data);

  delete(String path);
}
