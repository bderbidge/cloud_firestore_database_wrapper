import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/interfaces/i_data_source.dart';
import 'package:cloud_firestore_database_wrapper/src/firestore_data_source.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock_data/mock_user.dart' as mockusers;
import 'test_models/user.dart';

void main() {
  /*
  * TODO: keep the create update and delete at the end of the tests or 
  * create a new group otherwise tests will fail due to concurency issues
  */
  group('Mock Firestore methods', () {
    MockFirestoreInstance instance = MockFirestoreInstance();
    FirestoreDataSource dataSource = FirestoreDataSource(instance);
    final List<User> users = [];
    final path = 'users';
    setUpAll(() async {
      for (var user in mockusers.users) {
        var ref = instance.collection(path).doc(user['uid']);
        ref.set(user);
        users.add(User.fromJSON(user, user['uid']));
      }
    });

    tearDownAll(() async {
      instance.dump();
    });

    Future<User> createNewUser(String uid) async {
      final user = User(
          uid: uid,
          name: "Bob",
          photoUrl: "url",
          email: "example@example.com",
          phoneNumber: "1234567890",
          type: 3,
          date: "12/14/2020",
          score: 300,
          userType: []);
      await dataSource.create(
        path,
        user.toJson(),
        id: user.uid,
      );
      return user;
    }

    Future<bool> deleteUser(String id) async {
      dataSource.delete(path, id);
      try {
        await dataSource.getSingleByRefId<User>(path, id, User.fromJSON);
      } catch (err) {
        if (!(err is GetSingleDocumentException)) {
          throw err;
        }
      }
      return true;
    }

    test('get single document as user model', () async {
      try {
        final originaluser = users.first;
        final uid = originaluser.uid;
        if (uid != null) {
          User user =
              await dataSource.getSingleByRefId<User>(path, uid, User.fromJSON);
          expect(originaluser.toJson(), user.toJson());
        }
        throw Exception();
      } catch (err) {
        print(err);
        throw err;
      }
    });

    test('get collections', () async {
      final list = await dataSource.getCollection<User>(path, User.fromJSON);
      expect(users.length, list.length);
    });

    test('get collections with single where param', () async {
      final map = [
        QueryType(
            id: 'type', value: 1, whereQueryType: WhereQueryType.IsEqualTo)
      ];
      final list = await dataSource.getCollectionwithParams(path, User.fromJSON,
          where: map);

      final typeList = users.where((element) => element.type == 1);
      expect(typeList.length, list.length);
    });

    test('get collections with 2 params', () async {
      final map = [
        QueryType(
            id: 'type', value: [1, 2], whereQueryType: WhereQueryType.WhereIn),
        QueryType(
            id: 'date',
            value: "12/1/2020",
            whereQueryType: WhereQueryType.IsEqualTo)
      ];

      final list = await dataSource.getCollectionwithParams(path, User.fromJSON,
          where: map);

      final typeList = users.where((element) =>
          (element.type == 1 || element.type == 2) &&
          element.date == "12/1/2020");
      expect(typeList.length, list.length);
    });

    test('query range exceptions', () async {
      // valid
      // citiesRef.where("state", ">=", "CA").where("state", "<=", "IN");

      final validMap = [
        QueryType(
            id: 'score',
            value: 100,
            whereQueryType: WhereQueryType.IsGreaterThan),
        QueryType(
            id: 'score',
            value: 400,
            whereQueryType: WhereQueryType.IsLessThanOrEqualTo),
      ];

      try {
        final validList = await dataSource
            .getCollectionwithParams(path, User.fromJSON, where: validMap);
        final typeList = users.where(
            (element) => (element.score! > 100) && (element.score! <= 400));
        expect(typeList.length, validList.length);

        // citiesRef.where("state", "==", "CA").where("population", ">", 1000000);

        // invalid
        // citiesRef.where("state", ">=", "CA").where("population", ">", 100000);

        final invalidMap = [
          QueryType(
              id: 'type', value: 3, whereQueryType: WhereQueryType.IsLessThan),
          QueryType(
              id: 'score',
              value: 100,
              whereQueryType: WhereQueryType.IsGreaterThanOrEqualTo)
        ];
        final invalidlist = await dataSource
            .getCollectionwithParams(path, User.fromJSON, where: invalidMap);
        expect(null, invalidlist);
      } catch (err) {
        var isCorrectType = err is QueryRangeConditionException;
        expect(true, isCorrectType);
      }
    });

    test('create, update, and delete user', () async {
      try {
        final user = await createNewUser(users.length.toString());

        User createdUser = await dataSource.getSingleByRefId<User>(
            path, user.uid!, User.fromJSON);
        expect(user.toJson(), createdUser.toJson());

        var email = "example2@example.com";
        await dataSource.update(path, createdUser.uid!, {"email": email});
        final updatedUser = await dataSource.getSingleByRefId<User>(
            path, createdUser.uid!, User.fromJSON);
        expect(email, updatedUser.email);

        final deleted = await deleteUser(user.uid!);
        expect(true, deleted);
      } catch (err) {
        print(err);
        throw err;
      }
    });
  });
}
