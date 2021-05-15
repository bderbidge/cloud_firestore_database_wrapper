import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_database_wrapper/util/check_query_constructor.dart';
import "dart:async";
import '../exception/exceptions.dart';
import '../interfaces/i_data_source.dart';
import '../util/firestore_parser.dart';

// Cloud Firestore
class FirestoreDataSource implements IDataSource {
  FirestoreDataSource(FirebaseFirestore db) : _db = db;
  final FirebaseFirestore _db;

  Future<T> getSingleByRefId<T>(
      String path, String id, FromJson fromJson) async {
    try {
      var ref = firestoreRef(path, id);
      var parser = FirestoreParser<T>();
      var document = await ref.get();
      return parser.parseIndividual(document, fromJson);
    } catch (err, s) {
      throw GetSingleDocumentError(err.toString(), s);
    }
  }

  Future<List<T>> getCollection<T>(String path, FromJson fromJson) async {
    try {
      var collectionReference = _db.collection(path);
      var snapshots = collectionReference
          .get()
          .then((snapshot) => FirestoreParser<T>().parse(snapshot, fromJson));
      return snapshots;
    } catch (err, s) {
      throw GetCollectionError(err.toString(), s);
    }
  }

  Future<List<T>> getCollectionwithParams<T>(String path, FromJson fromJson,
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
      Query query = _db.collection(path);
      var collectionReference = queryConstruction(query,
          where: where, orderby: orderby, limit: limit, startAfter: startAfter);
      var doc = await collectionReference.get();
      return FirestoreParser<T>().parse(doc, fromJson);
    } catch (err, s) {
      throw CollectionWithParamsError(err.toString(), s);
    }
  }

  Stream<List<T>> getCollectionStreamWithParams<T>(
      String path, FromJson fromJson,
      {List<QueryType>? where, Map<String, bool>? orderby, int? limit}) {
    if (where != null) {
      where = checkQueryConstructor(where);
    }
    try {
      Query query = _db.collection(path);
      var collectionReference = queryConstruction(
        query,
        where: where,
        orderby: orderby,
        limit: limit,
      );
      Stream<QuerySnapshot> snapshots = collectionReference.snapshots();
      return snapshots
          .map((snapshot) => FirestoreParser<T>().parse(snapshot, fromJson));
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
          case WhereQueryType.IsEqualTo:
            query = query.where(value.id, isEqualTo: value.value);
            break;
          case WhereQueryType.IsLessThan:
            query = query.where(value.id, isLessThan: value.value);
            break;
          case WhereQueryType.IsLessThanOrEqualTo:
            query = query.where(value.id, isLessThanOrEqualTo: value.value);
            break;
          case WhereQueryType.IsGreaterThan:
            query = query.where(value.id, isGreaterThan: value.value);
            break;
          case WhereQueryType.IsGreaterThanOrEqualTo:
            query = query.where(value.id, isGreaterThanOrEqualTo: value.value);
            break;
          case WhereQueryType.ArrayContains:
            query = query.where(value.id, arrayContains: value.value);
            break;
          case WhereQueryType.ArrayContainsAny:
            query = query.where(value.id, arrayContainsAny: value.value);
            break;
          case WhereQueryType.WhereIn:
            query = query.where(value.id, whereIn: value.value);
            break;
          case WhereQueryType.WhereNotIn:
            query = query.where(value.id, whereNotIn: value.value);
            break;
          case WhereQueryType.IsNull:
            query = query.where(value.id, isNull: value.value);
            break;
          case WhereQueryType.IsNotEqualTo:
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

  Future<String> create(String path, Map<String, dynamic> data,
      {String? id}) async {
    try {
      if (id != null) {
        firestoreRef(path, id).set(data);
        return id;
      } else {
        var ref = await _db.collection(path).add(data);
        return ref.id;
      }
    } catch (err, s) {
      throw CreateSingleError(err.toString(), s);
    }
  }

  addDocToSubcollection(
      DocumentReference ref, String collectionPath, Map<String, dynamic> data) {
    ref.collection(collectionPath).add(data);
  }

  //Put functions

  Future<Null> update(String path, String id, Map<String, dynamic> data) async {
    try {
      await firestoreRef(path, id).update(data);
    } catch (err, s) {
      throw UpdateSingleError(err.toString(), s);
    }
  }

  updateDocSubcollection(DocumentReference ref, Map<String, dynamic> data) {
    try {
      ref.update(data);
    } catch (err, s) {
      throw UpdateSingleError(err.toString(), s);
    }
  }

  //Delete functions

  delete(String path, String id) {
    try {
      firestoreRef(path, id).delete();
    } catch (err, s) {
      throw DeleteSingleError(err.toString(), s);
    }
  }

  DocumentReference firestoreRef(String path, String id) {
    try {
      return _db.collection(path).doc(id);
    } catch (err, s) {
      throw FirestoreReferenceError(err.toString(), s);
    }
  }

  Future<List<T>> getSubCollection<T>(
      List<String> paths, List<String> ids, FromJson fromJson,
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
      CollectionReference cr = _db.collection(paths[0]);
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
      return FirestoreParser<T>().parse(docs, fromJson);
    } catch (err, s) {
      throw GetCollectionGroupError(err.toString(), s);
    }
  }
}
