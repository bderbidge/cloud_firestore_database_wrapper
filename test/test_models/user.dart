class User {
  final String? uid;
  final String? name;
  final String? photoUrl;
  final String? email;
  final String? phoneNumber;
  final String? date;
  final int? type;
  final int? score;
  final List? userType;

  User({
    this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.type,
    this.score,
    this.date,
    this.userType,
  });

  static User fromJSON(Map<String, dynamic>? json, String id) {
    if (json == null) {
      return User();
    }
    List<dynamic>? properties = [];
    List<String> propertyRefs = [];
    if (json.containsKey('properties')) {
      properties = json['properties'];
      for (String string in properties as Iterable<String>) {
        propertyRefs.add(string);
      }
    }
    return User(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      type: json['type'] as int?,
      score: json['score'] as int?,
      date: json['date'] as String?,
      userType: [],
    );
  }

  User copyWith(
      {String? uid,
      String? name,
      String? photoUrl,
      String? email,
      String? phoneNumber,
      int? type,
      int? score,
      String? date,
      List? userType}) {
    return User(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        type: type ?? this.type,
        score: score ?? this.score,
        date: date ?? this.date,
        userType: userType ?? this.userType);
  }

  Map<String, dynamic> toJson() => {
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
}
