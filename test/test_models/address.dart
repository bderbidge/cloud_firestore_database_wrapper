import 'package:cloud_firestore_database_wrapper/src/base_model.dart';

class Address extends BaseModel {
  final String? street;
  final String? city;
  final String? state;
  final int? zip;

  Address(json)
      : street = json["street"],
        city = json["city"],
        state = json["state"],
        zip = json["zip"],
        super(json, json["uid"]);

  Map<String, dynamic> toJSON() => {
        'uid': uid,
        'street': street,
        'state': state,
        'city': city,
        'zip': zip,
      };

  @override
  String? getId() {
    return uid;
  }

  @override
  String getPath() {
    return "Address";
  }
}
