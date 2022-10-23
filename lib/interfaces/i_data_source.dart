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
  delete(String path, String id);

  update(String path, String id, BaseModel data);

  Future<String> create(String path, BaseModel data, {String? id});

  Future<Model> getSingleByRefId<Model extends BaseModel>(
      String path, String id);

  Future<List<Model>> getCollection<Model extends BaseModel>(String path);

  Future<List<Model>> getCollectionwithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      String? startAfterID});

  Stream<List<Model>> getCollectionStreamWithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit});

  Stream<Model> getStreamByID<Model extends BaseModel>(String path, String id);

  Future<List<Model>> getSubCollection<Model extends BaseModel>(
      List<String> paths, List<String> ids,
      {List<QueryType>? where, Map<String, bool>? orderby, int? limit});

  Future<String> addDocToSubcollection<Model extends BaseModel>(
      String path, BaseModel data);

  Stream<List<Model>> getStreamWhere<Model extends BaseModel>(
      String path, String name, num status);
}
