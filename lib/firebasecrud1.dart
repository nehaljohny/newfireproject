import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FireBaseCrud extends StatefulWidget {
  const FireBaseCrud({super.key});

  @override
  State<FireBaseCrud> createState() => _FireBaseCrudState();
}

class _FireBaseCrudState extends State<FireBaseCrud> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  late CollectionReference _userCollection;

  @override
  void initState() {
    _userCollection = FirebaseFirestore.instance.collection("users");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Center(
            child: Text(
              "Add Users Data",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 28,
                  fontStyle: FontStyle.italic),
            )),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.deepPurple.withOpacity(.3)),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  border: InputBorder.none,
                  labelText: 'Name',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.deepPurple.withOpacity(.3)),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    border: InputBorder.none,
                    labelText: 'E-mail'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {
                addUser();
              },
              color: Colors.deepPurple.withOpacity(.3),
              shape: const StadiumBorder(),
              child: const Text(
                "Add User",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // StreamBuilder listens to the Query Stream (here getUser() method)
            // rebuild the ui whenever there is a new data
            StreamBuilder<QuerySnapshot>(
                stream: getUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error:${snapshot.error}"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data!.docs;

                  return Expanded(
                      child: ListView.builder(itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = user.id;
                        final username = user['name'];
                        final useremail = user['email'];
                        return Card(
                          child: ListTile(
                            title: Text(username),
                            subtitle: Text(useremail),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      editBox(userId, username, useremail);
                                    }, icon: Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      deleteUser(userId);
                                    }, icon: Icon(Icons.delete))
                              ],
                            ),
                          ),
                        );
                      }));
                })
          ],
        ),
      ),
    );
  }

  Future<void> addUser() {
    return _userCollection
        .add({'name': nameController.text, 'email': emailController.text}).then(
            (value) {
          print("User Added Successfully");
          nameController.clear();
          emailController.clear();
        }).catchError((error) {
      print("Failed to Add user :$error");
    });
  }

  // QuerySnapshot contains result of query(data from fire store)
  // and metadata (additional information like errors warnings etc)
  Stream<QuerySnapshot> getUser() {
    return _userCollection.snapshots();
  }

  void editBox(userId, username, useremail) {
    showDialog(
        context: context,
        builder: (context) {
          final newNameCntrl = TextEditingController(text: username);
          final newEmailCntrl = TextEditingController(text: useremail);
          return AlertDialog(
            title: const Text("Edit User!!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newNameCntrl,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: newEmailCntrl,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Email"),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  updateUser(userId, newNameCntrl.text, newEmailCntrl.text)
                      .then((v){
                    Navigator.pop(context);
                  });
                },
                color: Colors.deepPurple.withOpacity(.3),
                minWidth: 80,
                child: const Text("Update User"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.deepPurple.withOpacity(.5),
                minWidth: 80,
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  Future<void> updateUser(String id, String uname, String uemail) {
    var data = {'name': uname, 'email': uemail};
    return _userCollection
        .doc(id)
        .update(data)
        .then((value) {
      print("User Updated Successfully");
    }).catchError((error) {
      print("Failed to Update User $error");
    });
  }

  Future<void> deleteUser(String id) {
    return _userCollection.doc(id).delete().then((v){
      print("User Deleted Successfully");
    }).catchError((error) {
      print("Failed to delete User $error");
    });
  }
}