import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreParser<T> {
  List<T> parse(QuerySnapshot querySnapshot, FromJson fromJson) {
    return querySnapshot.docs.map((documentSnapshot) {
      T data = fromJson(documentSnapshot.data(), documentSnapshot.id);
      return data;
    }).toList();
  }

  T parseIndividual(DocumentSnapshot document, FromJson fromJson) {
    T user = fromJson(document.data(), document.id);
    return user;
  }
}

typedef T FromJson<T>(Map<String, dynamic>? data, String id);
