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
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  // backing data
  List<User> _data = [];
  final path = 'users';
  final FirebaseFirestore finstance = FirebaseFirestore.instance;
  final FirestoreDataSource dataSource =
      FirestoreDataSource(FirebaseFirestore.instance);
  num index = 0;

  @override
  Future<void> initState() async {
    for (var user in mockusers.users) {
      var ref = finstance.collection(path).doc(user['uid']);
      ref.set(user);
      index++;
    }
    _data = await dataSource.getCollection<User>(path, User.fromJSON);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          child: AnimatedList(
            // Give the Animated list the global key
            key: listKey,
            initialItemCount: _data.length,
            // Similar to ListView itemBuilder, but AnimatedList has
            // an additional animation parameter.
            itemBuilder: (context, index, animation) {
              // Breaking the row widget out as a method so that we can
              // share it with the _removeSingleItem() method.
              var name = _data[index].name;
              if (name != null) {
                return _buildItem(name, animation);
              }
              return _buildItem("", animation);
            },
          ),
        ),
        ElevatedButton(
          child: Text('Insert item', style: TextStyle(fontSize: 20)),
          onPressed: () {
            _insertSingleItem();
          },
        ),
        ElevatedButton(
          child: Text('Remove item', style: TextStyle(fontSize: 20)),
          onPressed: () {
            _removeSingleItem();
          },
        )
      ],
    );
  }

  // This is the animated row with the Card.
  Widget _buildItem(String name, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(
            name,
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
    dataSource.create(
      path,
      user.toJson(),
      id: index.toString(),
    );
    _data.insert(insertIndex, user);
  }

  void _removeSingleItem() {
    int removeIndex = 2;
    // Remove item from data list but keep copy to give to the animation.
    User removedItem = _data.removeAt(removeIndex);
    var uid = removedItem.uid;
    if (uid != null) {
      dataSource.delete(path, uid);
      // This builder is just for showing the row while it is still
      // animating away. The item is already gone from the data list.
    }
  }
}
