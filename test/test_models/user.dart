import 'package:cloud_firestore_database_wrapper/src/base_model.dart';

class User extends BaseModel {
  final String? name;
  final String? photoUrl;
  String? email;
  final String? phoneNumber;
  final String? date;
  final int? type;
  final int? score;
  final List? userType;

  User(
    Map<String, dynamic> json,
  )   : name = json["name"],
        email = json["email"],
        phoneNumber = json["phoneNumber"],
        photoUrl = json["photoUrl"],
        type = json["type"],
        score = json["score"],
        date = json["date"],
        userType = json["userType"],
        super(json, json["uid"]);

  Map<String, dynamic> toJSON() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'type': type,
        'score': score,
        'date': date,
        'userType': userType,
      };

  @override
  String getId() {
    return uid;
  }

  @override
  String getPath() {
    return "users";
  }
}
