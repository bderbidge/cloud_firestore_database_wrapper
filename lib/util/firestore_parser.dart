import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore_database_wrapper/src/base_model.dart';

typedef ModelGenerator<Model> = Function<Model extends BaseModel>(
    Map<String, dynamic> json, String id);

class FirestoreParser<Model extends BaseModel> {
  final ModelGenerator generate;

  FirestoreParser(this.generate);

  List<Model> parse<Model extends BaseModel>(QuerySnapshot querySnapshot) {
    var list = querySnapshot.docs.map((documentSnapshot) {
      var data = generate<Model>(
          documentSnapshot.data() as Map<String, dynamic>,
          documentSnapshot.id) as Model;
      return data;
    }).toList();

    return list;
  }

  Model parseIndividual<Model extends BaseModel>(
      DocumentSnapshot<Map<String, dynamic>> document) {
    var user = generate<Model>(document.data() ?? {}, document.id);
    return user;
  }
}
