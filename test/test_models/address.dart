class Address {
  final String? uid;
  final String? street;
  final String? city;
  final String? state;
  final int? zip;

  Address({
    this.uid,
    this.street,
    this.state,
    this.city,
    this.zip,
  });

  static Address fromJSON(Map<String, dynamic>? json, String id) {
    if (json == null) {
      return Address();
    }
    List<dynamic>? properties = [];
    List<String> propertyRefs = [];
    if (json.containsKey('properties')) {
      properties = json['properties'];
      for (String string in properties as Iterable<String>) {
        propertyRefs.add(string);
      }
    }
    return Address(
      uid: json['uid'] as String?,
      street: json['street'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      zip: json['zip'] as int?,
    );
  }

  Address copyWith(
      {String? uid,
      String? street,
      String? city,
      String? state,
      String? phoneNumber,
      int? zip,
      int? score,
      String? date,
      List? userzip}) {
    return Address(
        uid: uid ?? this.uid,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        zip: zip ?? this.zip);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'street': street,
        'state': state,
        'city': city,
        'zip': zip,
      };
}
