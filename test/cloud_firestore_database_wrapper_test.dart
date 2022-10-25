import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/interfaces/i_data_source.dart';
import 'package:cloud_firestore_database_wrapper/src/firestore_data_source.dart';
import 'package:cloud_firestore_database_wrapper/util/firestore_parser.dart';
import 'generate_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock_data/mock_user.dart' as mock;
import 'test_models/address.dart';
import 'test_models/user.dart';

void main() {
  /*
  * TODO: keep the create update and delete at the end of the tests or 
  * create a new group otherwise tests will fail due to concurency issues
  */
  group('Mock Firestore methods', () {
    final instance = FakeFirebaseFirestore();
    FirestoreDataSource dataSource =
        FirestoreDataSource(FirestoreParser(generateModel), instance);
    final List<User> users = [];
    final List<Address> addresses = [];
    final path = 'users';
    final addressPath = 'address';
    setUpAll(() async {
      for (var user in mock.users) {
        var ref = instance.collection(path).doc(user['uid']);
        ref.set(user);
        users.add(User(user));
      }

      for (var address in mock.addresses) {
        var addressref = instance
            .collection(path)
            .doc(users.first.uid)
            .collection(addressPath)
            .doc(address['uid']);
        addressref.set(address);
        addresses.add(Address(address));
      }
    });

    tearDownAll(() async {
      instance.dump();
    });

    Future<User> createNewUser(String uid) async {
      final user = User({
        "uid": uid,
        "name": "Bob",
        "photoUrl": "url",
        "email": "example@example.com",
        "phoneNumber": "1234567890",
        "type": 3,
        "date": "12/14/2020",
        "score": 300,
        "userType": []
      });
      await dataSource.addDocToCollection(
        path + "/" + uid,
        user,
      );
      return user;
    }

    Future<bool> deleteUser(String id) async {
      dataSource.delete(path + "/" + id);
      try {
        await dataSource.getSingleById<User>(path);
      } catch (err) {
        if (!(err is GetSingleDocumentError)) {
          throw err;
        }
      }
      return true;
    }

    test('get single document as user model', () async {
      try {
        final originaluser = users.first;
        final uid = originaluser.uid;

        User user = await dataSource.getSingleById<User>(path + "/" + uid);
        expect(originaluser.toJSON(), user.toJSON());
      } catch (err) {
        print(err);
        throw err;
      }
    });

    test('get collections', () async {
      final list = await dataSource.getCollectionwithParams<User>(path);
      expect(users.length, list.length);
    });

    test('get collections with single where param', () async {
      final map = [
        QueryType(
            id: 'type', value: 1, whereQueryType: WhereQueryType.isEqualTo)
      ];
      final list =
          await dataSource.getCollectionwithParams<User>(path, where: map);

      final typeList = users.where((element) => element.type == 1);
      expect(typeList.length, list.length);
    });

    test('get collections with 2 params', () async {
      final map = [
        QueryType(
            id: 'type', value: [1, 2], whereQueryType: WhereQueryType.whereIn),
        QueryType(
            id: 'date',
            value: "12/1/2020",
            whereQueryType: WhereQueryType.isEqualTo)
      ];

      final list =
          await dataSource.getCollectionwithParams<User>(path, where: map);

      final typeList = users.where((element) =>
          (element.type == 1 || element.type == 2) &&
          element.date == "12/1/2020");
      expect(typeList.length, list.length);
    });

    test('query range Errors', () async {
      // valid
      // citiesRef.where("state", ">=", "CA").where("state", "<=", "IN");

      final validMap = [
        QueryType(
            id: 'score',
            value: 100,
            whereQueryType: WhereQueryType.isGreaterThan),
        QueryType(
            id: 'score',
            value: 400,
            whereQueryType: WhereQueryType.isLessThanOrEqualTo),
      ];

      try {
        final validList = await dataSource.getCollectionwithParams<User>(path,
            where: validMap);
        final typeList = users.where(
            (element) => (element.score! > 100) && (element.score! <= 400));
        expect(typeList.length, validList.length);

        // citiesRef.where("state", "==", "CA").where("population", ">", 1000000);

        // invalid
        // citiesRef.where("state", ">=", "CA").where("population", ">", 100000);

        final invalidMap = [
          QueryType(
              id: 'type', value: 3, whereQueryType: WhereQueryType.isLessThan),
          QueryType(
              id: 'score',
              value: 100,
              whereQueryType: WhereQueryType.isGreaterThanOrEqualTo)
        ];
        final invalidlist = await dataSource.getCollectionwithParams<User>(path,
            where: invalidMap);
        expect(null, invalidlist);
      } catch (err) {
        var isCorrectType = err is QueryRangeConditionError;
        expect(true, isCorrectType);
      }
    });

    test('create, update, and delete user', () async {
      try {
        final user = await createNewUser(users.length.toString());

        User createdUser =
            await dataSource.getSingleById<User>(path + "/" + user.uid);
        expect(user.toJSON(), createdUser.toJSON());

        var email = "example2@example.com";
        createdUser.email = email;
        await dataSource.update(path + "/" + createdUser.uid, createdUser);
        final updatedUser =
            await dataSource.getSingleById<User>(path + "/" + createdUser.uid);
        expect(email, updatedUser.email);

        final deleted = await deleteUser(user.uid);
        expect(true, deleted);
      } catch (err) {
        print(err);
        throw err;
      }
    });

    test('get all documents in subcollection', () async {
      final map = [
        QueryType(
            id: 'city',
            value: "Los Angeles",
            whereQueryType: WhereQueryType.isEqualTo)
      ];
      var addresses = await dataSource.getCollectionwithParams<Address>(
          path + "/" + users.first.uid + "/" + addressPath,
          where: map);
      expect(addresses.length, 6);
    });

    test('incorrect get all documents in subcollection', () async {
      try {
        final map = [
          QueryType(
              id: 'city',
              value: "Los Angeles",
              whereQueryType: WhereQueryType.isEqualTo)
        ];
        var addresses = await dataSource.getCollectionwithParams<Address>(
            path +
                "/" +
                users.first.uid +
                "/" +
                addressPath +
                "/" +
                users.last.uid,
            where: map);
        expect(addresses, null);
      } catch (err) {
        var isCorrectType = err is GetCollectionGroupError;
        expect(true, isCorrectType);
        expect(err.toString(),
            "number of ids must be less than paths for subcollection");
      }
    });
  });
}
