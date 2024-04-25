import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'teacher_messages.dart';

// Initializes Firestore database
var db = FirebaseFirestore.instance;

// This class lists out all of the businesses, so that they can message them.
class ListingsPage extends StatefulWidget {
  const ListingsPage({
    Key? key,
    required this.business,
  }) : super(key: key);

  final String business;

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  // This list contains the all businesses' names in the class
  Map<String, String> admins = {};
  List<String> adminNames = [];

  // This gets all of the businesses when the screen initializes.
  @override
  void initState() {
    getAdmins();
    super.initState();
  }

  // This function represents each indiv admin
  ListTile buildList(String administrator, String dept) {
    return ListTile(
      title: Text(administrator,
          style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w300)),
      subtitle: Text(dept,
          style: TextStyle(
              color: Colors.black, fontSize: 10, fontWeight: FontWeight.w300)),
      trailing: Icon(Icons.message),
      tileColor: Color.fromRGBO(76, 44, 114, 0.6),
    );
  }

  // This function gets all of the names of the admins and appends them to a list
  // It accesses the administrators collection.
  Future<void> getAdmins() async {
    print('get admins');
    await db.collection('administrators').get().then((value) => {
          value.docs.forEach((element) async {
            if (element.exists) {
              print('in hereeee');
              setState(() {
                print('hhhhhheeee');
                adminNames.add((element.data()['firstName']) +
                    ' ' +
                    element.data()['lastName']);
                admins[(element.data()['firstName']) +
                    ' ' +
                    element.data()['lastName']] = element.data()['department'];
              });
            } else {
              print('nonexistent');
            }
          })
        });
  }

  // This will display the businesses' list
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Container(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          toolbarHeight: 100,
          elevation: 0,
          backgroundColor: Color(0xff8FD694),
          title: Text(
            'Message CTE Admin',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          )),
      backgroundColor: Color(0xffF7F7F7),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("ADMINS", style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // Displays a list of all of the admins.
          // When the business clicks on an admin, they can message them.
          Container(
            height: 400,
            width: double.infinity,
            child: ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          ),
                          tileColor: Colors.white,
                          textColor: Colors.black,
                          title: Text(adminNames[index]),
                          subtitle: Text(admins[adminNames[index]]!),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TeacherMessagesPage(
                                    admin: adminNames[index],
                                    businessID: widget.business)));
                          },
                        ),
                        LayoutBuilder(builder: (context, constraints) {
                          if (index != adminNames.length - 1) {
                            return Divider(
                              indent: 20,
                              endIndent: 20,
                            );
                          } else {
                            return Container();
                          }
                        }),
                      ],
                    ),
                  );
                }),
          )
        ]),
      ),
    );
  }
}
