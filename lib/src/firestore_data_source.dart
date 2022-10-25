import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/src/base_model.dart';
import 'package:cloud_firestore_database_wrapper/util/check_query_constructor.dart';
import 'package:cloud_firestore_database_wrapper/util/firestore_parser.dart';

import "dart:async";

import '../interfaces/i_data_source.dart';

// Cloud Firestore
class FirestoreDataSource implements IDataSource {
  FirestoreParser parser;
  FirestoreDataSource(this.parser, this.db);
  final FirebaseFirestore db;

  // Get Single Documents

  @override
  Future<Model> getSingleById<Model extends BaseModel>(
    String path,
  ) async {
    try {
      var pathParam = path.split("/");
      var collection = collectionPath(pathParam);

      if (pathParam.length.isOdd) {
        var document = await collection.doc(pathParam.removeAt(0)).get();
        return parser.parseIndividual<Model>(document);
      } else {
        throw IsNotDocException(
            "Path does not end in a doc id", StackTrace.current);
      }
    } catch (err, s) {
      throw GetSingleDocumentError(err.toString(), s);
    }
  }

  @override
  Stream<Model> getStreamByID<Model extends BaseModel>(
    String path,
  ) {
    var pathParam = path.split("/");
    var collection = collectionPath(pathParam);

    if (pathParam.length.isOdd) {
      var snapshot = collection.doc(pathParam.removeAt(0)).snapshots();
      return snapshot.map((doc) => parser.parseIndividual<Model>(doc));
    } else {
      throw IsNotDocException(
          "Path does not end in a doc id", StackTrace.current);
    }
  }

  // Get collections

  @override
  Future<List<Model>> getCollectionwithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      String? startAfterID}) async {
    var pathParam = path.split("/");

    if (pathParam.length.isEven) {
      throw GetCollectionGroupError(
          "number of ids must be less than paths for subcollection",
          StackTrace.current);
    }

    if (where != null) {
      where = checkQueryConstructor(where);
    }

    try {
      DocumentSnapshot? startAfter;
      if (startAfterID != null) {
        // startAfter = await firestoreRef(path, startAfterID).get();
      }

      var collection = collectionPath(pathParam);

      var collectionReference = queryConstruction(collection,
          where: where, orderby: orderby, limit: limit, startAfter: startAfter);
      var query = await collectionReference.get();
      return parser.parse<Model>(query);
    } catch (err, s) {
      throw CollectionWithParamsError(err.toString(), s);
    }
  }

  @override
  Stream<List<Model>> getCollectionStream<Model extends BaseModel>(
    String path, {
    List<QueryType>? where,
    Map<String, bool>? orderby,
    int? limit,
  }) {
    var pathParam = path.split("/");
    if (pathParam.length.isEven) {
      throw GetCollectionGroupError(
          "number of ids must be less than paths for subcollection",
          StackTrace.current);
    }

    Query query = collectionPath(pathParam);
    if (where != null) {
      where = checkQueryConstructor(where);
    }

    var collection = queryConstruction(
      query,
      where: where,
      orderby: orderby,
      limit: limit,
    );
    Stream<QuerySnapshot> snapshots = collection.snapshots();
    return snapshots.map((snapshot) => parser.parse<Model>(snapshot));
  }

  //Post functions

  @override
  Future<String> addDocToCollection<Model extends BaseModel>(
      String path, BaseModel data) async {
    var pathParam = path.split("/");
    var collection = collectionPath(pathParam);

    if (!pathParam.length.isOdd) {
      var ref = await collection.add(data.toJSON());
      return ref.id;
    } else {
      var id = pathParam.removeAt(0);
      await collection.doc(id).set(data.toJSON());
      return id;
    }
  }

  //Put functions

  @override
  Future<void> update(String path, BaseModel data) async {
    try {
      var pathParam = path.split("/");
      var collection = collectionPath(pathParam);

      if (pathParam.length.isOdd) {
        await collection.doc(pathParam.removeAt(0)).update(data.toJSON());
      } else {
        throw IsNotDocException(
            "Path does not end in a doc id", StackTrace.current);
      }
    } catch (err, s) {
      throw UpdateSingleError(err.toString(), s);
    }
  }

  //Delete functions

  @override
  delete(String path) {
    try {
      var pathParam = path.split("/");
      var collection = collectionPath(pathParam);

      if (pathParam.length.isOdd) {
        collection.doc(pathParam.removeAt(0)).delete();
      } else {
        throw IsNotDocException(
            "Path does not end in a doc id", StackTrace.current);
      }
    } catch (err, s) {
      throw DeleteSingleError(err.toString(), s);
    }
  }

  // Helpers

  Query queryConstruction(Query query,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      DocumentSnapshot? startAfter}) {
    try {
      where?.forEach((value) {
        switch (value.whereQueryType) {
          case WhereQueryType.isEqualTo:
            query = query.where(value.id, isEqualTo: value.value);
            break;
          case WhereQueryType.isLessThan:
            query = query.where(value.id, isLessThan: value.value);
            break;
          case WhereQueryType.isLessThanOrEqualTo:
            query = query.where(value.id, isLessThanOrEqualTo: value.value);
            break;
          case WhereQueryType.isGreaterThan:
            query = query.where(value.id, isGreaterThan: value.value);
            break;
          case WhereQueryType.isGreaterThanOrEqualTo:
            query = query.where(value.id, isGreaterThanOrEqualTo: value.value);
            break;
          case WhereQueryType.arrayContains:
            query = query.where(value.id, arrayContains: value.value);
            break;
          case WhereQueryType.arrayContainsAny:
            query = query.where(value.id, arrayContainsAny: value.value);
            break;
          case WhereQueryType.whereIn:
            query = query.where(value.id, whereIn: value.value);
            break;
          case WhereQueryType.whereNotIn:
            query = query.where(value.id, whereNotIn: value.value);
            break;
          case WhereQueryType.isNull:
            query = query.where(value.id, isNull: value.value);
            break;
          case WhereQueryType.isNotEqualTo:
            query = query.where(value.id, isNotEqualTo: value.value);
            break;
          default:
            var type = value.whereQueryType;
            throw UnknownQueryError(
                'Unknown query type $type', StackTrace.current);
        }
      });

      if (orderby != null) {
        orderby.forEach((key, value) {
          query = query.orderBy(key, descending: value);
        });
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query;
    } catch (err, s) {
      throw FailedQueryConstructionError(err.toString(), s);
    }
  }

  CollectionReference<Map<String, dynamic>> collectionPath(
      List<String> pathParam) {
    var collection = db.collection(pathParam.removeAt(0));
    for (var i = 0; i < pathParam.length; i += 2) {
      if (i % 2 == 0 && i < pathParam.length - 1) {
        //collection
        var document = pathParam.removeAt(0);
        var col = pathParam.removeAt(0);
        collection = collection.doc(document).collection(col);
      }
    }

    return collection;
  }
}
