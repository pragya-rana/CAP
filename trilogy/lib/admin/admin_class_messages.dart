import "package:chat_bubbles/chat_bubbles.dart";
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Initializes Firestore database
var db = FirebaseFirestore.instance;

// This class lists out all of the admins the partner can contact,
// so that they can message them.
// The business name and the admin are passed in, so they can provide
// additional information to the user.
// A widget that displays the messages and search box are returned.
class ListingsPage extends StatefulWidget {
  // Class constructor
  const ListingsPage({
    Key? key,
    required this.businessName,
    required this.admin,
  }) : super(key: key);

  // Name of the business
  final String businessName;

  // Name of the admin being contacted.
  final String admin;

  // State being initialized here.
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  // This controller contains text from an announcements.
  final TextEditingController _announcementController = TextEditingController();

  String imageUrl = '';

  // This list contains the all students' names in the class
  List<String> businesses = [];

  // Initalized the name and period (none if club) of the class/club through Firebase
  String schoolClassName = '';
  int period = 0;

  // This gets all of the students in the class and the club/class name when the screen initializes.
  @override
  void initState() {
    getBusinesses();
    super.initState();
  }

  // This function represents each individual student in the class
  ListTile buildList(String business) {
    return ListTile(
      title: Text(business,
          style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w300)),
      trailing: Icon(Icons.email),
      tileColor: Color.fromRGBO(76, 44, 114, 0.6),
    );
  }

  // This function gets all of the names of the students and appends them to a list
  // It accesses the students collections in the classes/activities collection.
  Future<void> getBusinesses() async {
    print('get businesses');
    print(widget.businessName);
    await db.collection('partnerships').get().then((value) => {
          value.docs.forEach((element) async {
            if (element.exists) {
              print('in hereeee');
              setState(() {
                businesses.add(element.data()['name']);
              });
            } else {
              print('nonexistent');
            }
          })
        });
  }

  // This will send an announcement by setting the announcement in Firebase.
  void sendAnnouncement() {
    print('announcement: ' + _announcementController.text);
    var data;

    String id;
    for (int index = 0; index < businesses.length; index++) {
      id = businesses[index].replaceAll(' ', '_').toLowerCase();

      data = {
        'businessName': widget.businessName,
        'content': imageUrl,
        'isImage': true,
        'announcement': false,
        'reciever': widget.businessName,
        'sender': widget.admin,
        'timeSent': Timestamp.now()
      };

      var ref = db
          .collection('conversations')
          .doc(widget.admin +
              businesses[index].replaceAll(' ', '_').toLowerCase())
          .collection('messages')
          .doc();

      ref.set(data);
    }
    _announcementController.clear();
  }

  // This will display the students' list and the send announcements button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          toolbarHeight: 100,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color.fromRGBO(143, 214, 148, 1)),
      body: Column(
        children: [
          Text(
            schoolClassName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          MessagesPage(
              businessName: widget.businessName,
              admin: widget.admin,
              imageUrl: imageUrl)
        ],
      ),
      backgroundColor: Color(0xffF7F7F7),
    );
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    Key? key,
    required this.businessName,
    required this.admin,
    required this.imageUrl,
  }) : super(key: key);

  final String businessName;
  final String admin;
  final String imageUrl;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

final TextEditingController _textController = TextEditingController();
final ScrollController _scrollController = ScrollController();
File? imageFile;

class _MessagesPageState extends State<MessagesPage> {
  Widget buildInputBox() {
    return Material(
      child: Row(children: [
        IconButton(
          icon: Icon(Icons.add),

          // images
          onPressed: () {},
        ),
        Expanded(
            child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  helperText: "Enter your message",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                ))),
        IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // clear text controller
              // call send message function
              String message = _textController.text;
              _textController.clear();
              sendMessage(message, 0);
            })
      ]),
    );
  }

// get image
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
  }

// load previous messages
  Widget loadMessages() {
    return StreamBuilder(
        stream: db
            .collection('conversations')
            .doc(widget.admin + '_' + widget.businessName)
            .collection('messages')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.size,
              itemBuilder: (context, index) =>
                  buildItem(snapshot.data?.docs[index]),
              reverse: true,
            );
          } else {
            return Center(child: Text("Be the first to send a message!"));
          }
        });
  }

  // build invididual message bubble
  // add in Image chain
  Widget buildItem(QueryDocumentSnapshot<Map<String, dynamic>>? document) {
    if (document?.get('reciever') == widget.admin) {
      if (document?.get('announcement')) {
        return Column(children: [
          Text("Announcement", style: TextStyle(fontSize: 30)),
          BubbleNormal(
              text: document?.get('content'),
              color: Color.fromRGBO(143, 214, 148, 1),
              tail: true,
              isSender: true)
        ]);
      }
      return BubbleNormal(
          text: document?.get('content'),
          color: Color.fromRGBO(143, 214, 148, 1),
          tail: true,
          isSender: true);
    } else {
      return BubbleNormal(
          text: document?.get('content'),
          color: Colors.grey,
          tail: true,
          isSender: false);
    }
  }

  //handle sending messages including images
  // 0 is text
  // 1 is image
  BubbleNormal sendMessage(String content, int type) {
    final data;
    if (type == 0) {
      data = {
        'businessName': widget.businessName,
        'content': widget.imageUrl,
        'isImage': true,
        'announcement': false,
        'reciever': widget.businessName,
        'sender': widget.admin,
        'timeSent': Timestamp.now()
      };
    } else {
      data = {
        'businessName': widget.businessName,
        'content': widget.imageUrl,
        'isImage': true,
        'announcement': false,
        'reciever': widget.businessName,
        'sender': widget.admin,
        'timeSent': Timestamp.now()
      };
    }

    final ref = db
        .collection('conversations')
        .doc(widget.admin + widget.businessName)
        .collection('messages')
        .doc();

    ref.set(data);

    return BubbleNormal(
        text: data['content'],
        isSender: true,
        color: Color.fromRGBO(143, 214, 148, 1),
        tail: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[loadMessages(), buildInputBox()]);
  }
}
