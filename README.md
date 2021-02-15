# cloud_firestore_database_wrapper

## Getting Started

```
instance = FirebaseFirestore.instance;
dataSource = FirestoreDataSource(instance);

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
await dataSource.create(path, id: user.uid, data: user.toJson());

User user = await dataSource.getSingleByRefId<User>(
            path, originaluser.uid, User.fromJSON);
```

//TODO: Fill in these sections

### Implement FromJson

### Get Single

### Create

### Delete

### Get Collection

### Update

### Get Collection With Params

### Get Collection Stream With Params
