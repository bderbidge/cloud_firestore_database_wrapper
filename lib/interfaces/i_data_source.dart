import "dart:async";

import 'package:cloud_firestore_database_wrapper/util/firestore_parser.dart';

enum WhereQueryType {
  IsEqualTo,
  IsLessThan,
  IsLessThanOrEqualTo,
  IsGreaterThan,
  IsGreaterThanOrEqualTo,
  ArrayContains,
  ArrayContainsAny,
  WhereIn,
  WhereNotIn,
  IsNull,
  IsNotEqualTo,
}

final Set<WhereQueryType> queryRange = {
  WhereQueryType.IsLessThan,
  WhereQueryType.IsLessThanOrEqualTo,
  WhereQueryType.IsGreaterThan,
  WhereQueryType.IsGreaterThanOrEqualTo,
};

class QueryType {
  final id;
  final dynamic value;
  final WhereQueryType? whereQueryType;
  QueryType({this.id, this.value, this.whereQueryType});
}

abstract class IDataSource {
  delete(String path, String id);

  update(String path, String id, Map<String, dynamic> data);

  Future<String> create(String path, Map<String, dynamic> data, {String? id});

  Future<T> getSingleByRefId<T>(String path, String id, FromJson fromJson);

  Future<List<T>> getCollection<T>(String path, FromJson fromJson);

  Future<List<T>> getCollectionwithParams<T>(String path, FromJson fromJson,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      String? startAfterID});

  Stream<List<T>> getCollectionStreamWithParams<T>(
      String path, FromJson fromJson,
      {List<QueryType>? where, Map<String, bool>? orderby, int? limit});
}
