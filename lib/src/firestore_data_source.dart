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

  @override
  Future<Model> getSingleByRefId<Model extends BaseModel>(
      String path, String id) async {
    try {
      var ref = firestoreRef(path, id);
      var document = await ref.get();
      return parser.parseIndividual<Model>(document);
    } catch (err, s) {
      throw GetSingleDocumentError(err.toString(), s);
    }
  }

  @override
  Future<List<Model>> getCollection<Model extends BaseModel>(
      String path) async {
    try {
      var collectionReference = db.collection(path);
      var snapshots = collectionReference
          .get()
          .then((snapshot) => parser.parse<Model>(snapshot));
      return snapshots;
    } catch (err, s) {
      throw GetCollectionError(err.toString(), s);
    }
  }

  @override
  Future<List<Model>> getCollectionwithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit,
      String? startAfterID}) async {
    if (where != null) {
      where = checkQueryConstructor(where);
    }
    try {
      DocumentSnapshot? startAfter;
      if (startAfterID != null) {
        startAfter = await firestoreRef(path, startAfterID).get();
      }
      var pathParam = path.split("/");
      var collection = db.collection(pathParam.removeAt(0));
      for (var i = 0; i < pathParam.length; i += 2) {
        if (i % 2 == 0 && i < pathParam.length - 1) {
          //collection
          collection =
              collection.doc(pathParam[i]).collection(pathParam[i + 1]);
        }
      }
      var collectionReference = queryConstruction(collection,
          where: where, orderby: orderby, limit: limit, startAfter: startAfter);
      var doc = await collectionReference.get();
      return parser.parse<Model>(doc);
    } catch (err, s) {
      throw CollectionWithParamsError(err.toString(), s);
    }
  }

  @override
  Stream<List<Model>> getCollectionStreamWithParams<Model extends BaseModel>(
      String path,
      {List<QueryType>? where,
      Map<String, bool>? orderby,
      int? limit}) {
    if (where != null) {
      where = checkQueryConstructor(where);
    }
    try {
      Query query = db.collection(path);
      var collectionReference = queryConstruction(
        query,
        where: where,
        orderby: orderby,
        limit: limit,
      );
      Stream<QuerySnapshot> snapshots = collectionReference.snapshots();
      return snapshots.map((snapshot) => parser.parse<Model>(snapshot));
    } catch (err, s) {
      throw CollectionStreamWithParamsError(err.toString(), s);
    }
  }

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

  //Post functions

  @override
  Future<String> create(String path, BaseModel data, {String? id}) async {
    try {
      if (id != null) {
        await firestoreRef(path, id).set(data.toJSON());
        return id;
      } else {
        var ref = await db.collection(path).add(data.toJSON());
        return ref.id;
      }
    } catch (err, s) {
      throw CreateSingleError(err.toString(), s);
    }
  }

  @override
  Future<String> addDocToSubcollection<Model extends BaseModel>(
      String path, BaseModel data) async {
    var pathParam = path.split("/");

    var collection = db.collection(pathParam.removeAt(0));
    if (pathParam.isEmpty) {
      var ref = await collection.add(data.toJSON());
      return ref.id;
    }

    for (var i = 0; i < pathParam.length; i += 2) {
      if (i % 2 == 0 && i < pathParam.length - 1) {
        //collection
        collection = collection.doc(pathParam[i]).collection(pathParam[i + 1]);
      }
    }

    var ref = await collection.add(data.toJSON());
    return ref.id;
  }

  @override
  Stream<Model> getStreamByID<Model extends BaseModel>(
    String path,
    String id,
  ) {
    var pathParam = path.split("/");

    var collection = db.collection(pathParam.removeAt(0));
    for (var i = 0; i < pathParam.length; i += 2) {
      if (i % 2 == 0 && i < pathParam.length - 1) {
        //collection
        collection = collection.doc(pathParam[i]).collection(pathParam[i + 1]);
      }
    }
    var snapshot = collection.doc(id).snapshots();
    return snapshot.map((doc) => parser.parseIndividual<Model>(doc));
  }

  @override
  Stream<List<Model>> getStreamWhere<Model extends BaseModel>(
      String path, String name, num status) {
    var pathParam = path.split("/");

    var collection = db.collection(pathParam.removeAt(0));
    for (var i = 0; i < pathParam.length; i += 2) {
      if (i % 2 == 0 && i < pathParam.length - 1) {
        //collection
        collection = collection.doc(pathParam[i]).collection(pathParam[i + 1]);
      }
    }
    Stream<QuerySnapshot> snapshots =
        collection.where(name, isLessThanOrEqualTo: status).snapshots();
    return snapshots.map((snapshot) => parser.parse<Model>(snapshot));
  }

  //Put functions

  @override
  Future<void> update(String path, String id, BaseModel data) async {
    try {
      await firestoreRef(path, id).update(data.toJSON());
    } catch (err, s) {
      throw UpdateSingleError(err.toString(), s);
    }
  }

  @override
  updateDocSubcollection(DocumentReference ref, Map<String, dynamic> data) {
    try {
      ref.update(data);
    } catch (err, s) {
      throw UpdateSingleError(err.toString(), s);
    }
  }

  //Delete functions

  @override
  delete(String path, String id) {
    try {
      firestoreRef(path, id).delete();
    } catch (err, s) {
      throw DeleteSingleError(err.toString(), s);
    }
  }

  DocumentReference<Map<String, dynamic>> firestoreRef(String path, String id) {
    try {
      return db.collection(path).doc(id);
    } catch (err, s) {
      throw FirestoreReferenceError(err.toString(), s);
    }
  }

  @override
  Future<List<Model>> getSubCollection<Model extends BaseModel>(
      List<String> paths, List<String> ids,
      {List<QueryType>? where, Map<String, bool>? orderby, int? limit}) async {
    if (where != null) {
      where = checkQueryConstructor(where);
    }

    if (ids.length >= paths.length) {
      throw GetCollectionGroupError(
          "number of ids must be less than paths for subcollection",
          StackTrace.current);
    }
    try {
      CollectionReference cr = db.collection(paths[0]);
      DocumentReference doc = cr.doc(ids[0]);
      paths.removeAt(0);
      ids.removeAt(0);
      for (var item in paths) {
        //if first do this
        cr = doc.collection(item);
        for (var id in ids) {
          doc = cr.doc(id);
        }
      }
      Query query = cr;
      var collectionReference = queryConstruction(query,
          where: where, orderby: orderby, limit: limit);
      var docs = await collectionReference.get();
      return parser.parse<Model>(docs);
    } catch (err, s) {
      throw GetCollectionGroupError(err.toString(), s);
    }
  }
}
