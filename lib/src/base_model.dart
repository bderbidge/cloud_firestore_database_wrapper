abstract class BaseModel {
  String uid;

  BaseModel(Map<String, dynamic>? json, String id) : uid = id;

  String getPath();
  String? getId();

  void setID(String id) {
    uid = id;
  }

  Map<String, dynamic> toJSON();
}
