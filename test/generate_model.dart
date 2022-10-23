import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/src/base_model.dart';
import 'test_models/address.dart';
import 'test_models/user.dart';

Model generateModel<Model extends BaseModel>(
    Map<String, dynamic> json, String id) {
  BaseModel? model;

  if (Model == User) {
    model = User(json);
  } else if (Model == Address) {
    model = Address(json);
  } else {
    Type type = typeOf<Model>();
    throw ModelNotFoundError(
        "Cannont Find Model: " + type.toString(), StackTrace.current);
  }

  return model as Model;
}

Type typeOf<T>() => T;
