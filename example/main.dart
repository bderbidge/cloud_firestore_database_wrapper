import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_database_wrapper/src/firestore_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import '../test/mock_data/mock_user.dart' as mockusers;
import '../test//test_models/user.dart';

Future<void> main() async {
  // Pass all uncaught errors to Crashlytics.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  // The GlobalKey keeps track of the visible state of the list items
  // while they are being animated.
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  // backing data
  List<User> _data = [];
  final path = 'users';
  FirebaseFirestore instance;
  FirestoreDataSource dataSource;
  num index = 0;

  @override
  Future<void> initState() async {
    super.initState();
    instance = FirebaseFirestore.instance;
    dataSource = FirestoreDataSource(instance);

    for (var user in mockusers.users) {
      var ref = instance.collection(path).doc(user['uid']);
      ref.set(user);
      index++;
    }
    _data = await dataSource.getCollection<User>(path, User.fromJSON);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          child: AnimatedList(
            // Give the Animated list the global key
            key: _listKey,
            initialItemCount: _data.length,
            // Similar to ListView itemBuilder, but AnimatedList has
            // an additional animation parameter.
            itemBuilder: (context, index, animation) {
              // Breaking the row widget out as a method so that we can
              // share it with the _removeSingleItem() method.
              return _buildItem(_data[index], animation);
            },
          ),
        ),
        RaisedButton(
          child: Text('Insert item', style: TextStyle(fontSize: 20)),
          onPressed: () {
            _insertSingleItem();
          },
        ),
        RaisedButton(
          child: Text('Remove item', style: TextStyle(fontSize: 20)),
          onPressed: () {
            _removeSingleItem();
          },
        )
      ],
    );
  }

  // This is the animated row with the Card.
  Widget _buildItem(User item, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(
            item.name,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _insertSingleItem() {
    // Arbitrary location for demonstration purposes
    int insertIndex = 2;
    // Add the item to the data list.
    var date = DateTime.now();
    var user = User(
        date: date.toString(),
        email: "example@example.com",
        name: "John",
        photoUrl: "url",
        phoneNumber: "1234567890",
        type: 3,
        userType: [],
        score: 100);
    dataSource.create(path, id: index.toString(), data: user.toJson());
    _data.insert(insertIndex, user);

    // Add the item visually to the AnimatedList.
    _listKey.currentState.insertItem(insertIndex);
  }

  void _removeSingleItem() {
    int removeIndex = 2;
    // Remove item from data list but keep copy to give to the animation.
    User removedItem = _data.removeAt(removeIndex);
    dataSource.delete(path, removedItem.uid);
    // This builder is just for showing the row while it is still
    // animating away. The item is already gone from the data list.
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return _buildItem(removedItem, animation);
    };
    // Remove the item visually from the AnimatedList.
    _listKey.currentState.removeItem(removeIndex, builder);
  }
}
