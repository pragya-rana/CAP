import "package:chat_bubbles/chat_bubbles.dart";
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Initializes Firebase database
var db = FirebaseFirestore.instance;

// This widget will display the message page for the teacher with a particular student.
// The teacher can either text the student or add an image.
class TeacherMessagesPage extends StatefulWidget {
  const TeacherMessagesPage(
      {Key? key, required this.businessID, required this.admin})
      : super(key: key);

  final String businessID;
  final String admin;

  @override
  State<TeacherMessagesPage> createState() => _TeacherMessagesPageState();
}

class _TeacherMessagesPageState extends State<TeacherMessagesPage> {
  // The controller contains the message that the user types.
  final TextEditingController _textController = TextEditingController();

  // The scroll controller ensures that the screen automatically scrolls down when the
  // user has typed a message.
  final ScrollController _scrollController = ScrollController();

  // This file contains an image that the user chooses from the image picker.
  File? imageFile;

  // This is the file name of the image picked
  String fileName = "";

  // This is the url of the image to display the image
  String imageUrl = '';

  // This is the name of the admin initialized in Firebase
  String adminName = '';

  // This checks whether the user has chosen an image
  bool isPhoto = false;

  // This is the name of the business that the admin is messaging.
  String businessName = '';

  // If the focus on the text field changes, the color of the text field will change as well.
  Color detailFocusColor = Colors.transparent;

  // This will get the name of the business that the teacher is messaging by using the partnerships
  // collection in Firebase.
  Future<void> getBusinessName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('partnerships')
        .doc(widget.businessID)
        .get();

    if (snapshot.exists) {
      setState(() {
        businessName = snapshot.data()!['name'];
      });
    }
  }

  // This will get all of the messages and the name of the business the admin is messaging
  // when the screen initializes.
  @override
  void initState() {
    loadMessages();
    getBusinessName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          toolbarHeight: 100,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xff8FD694),
          title: Column(
            children: [
              Text(
                widget.admin,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          loadMessages(),
          buildInputBox(),
        ]));
  }

  // The text field, add icon, and send icon will all be built here.
  Widget buildInputBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 32),
            child: Row(children: [
              LayoutBuilder(builder: (context, constraints) {
                // When the user is not picking an image, the add button will show.
                if (!isPhoto) {
                  return IconButton(
                    icon: Icon(Icons.add),

                    // Permission is asked to access the user's images.
                    onPressed: () {
                      () async {
                        var _permissionStatus = await Permission.storage.status;

                        // Should allow user to grant permission to image gallery
                        if (_permissionStatus != PermissionStatus.granted) {
                          PermissionStatus permissionStatus =
                              await Permission.storage.request();
                          setState(() {
                            _permissionStatus = permissionStatus;
                          });
                        }
                      }();
                      uploadImage();
                    },
                  );
                } else {
                  // When the user is picking an image, the close icon will show, so that the
                  // user can remove the image.
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        isPhoto = false;
                      });
                    },
                    icon: Icon(Icons.close),
                  );
                }
              }),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  if (!isPhoto) {
                    // A text field will show up if the user has not selected an image.
                    return TextFormField(
                      textInputAction: TextInputAction.done,
                      maxLines: null,
                      controller: _textController,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                          hintText: 'Enter message here...',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: detailFocusColor,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff8FD694)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff8FD694)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ))),
                      onChanged: (value) => setState(() {
                        if (!value.isEmpty) {
                          detailFocusColor = Color(0xff8FD694).withOpacity(0.3);
                        } else {
                          detailFocusColor = Colors.transparent;
                        }
                      }),
                    );
                  } else {
                    // If the user has selected an image, a preview of the image will show in
                    // a container without the text field.
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(imageUrl)),
                    );
                  }
                }),
              ),
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // The message or image will send when the send icon is pressed.
                    if (!isPhoto) {
                      String message = _textController.text;
                      print('message: ' + message);
                      sendMessage(message);
                      _textController.clear();
                      loadMessages();
                    } else {
                      print('in photo');
                      // sendImage();
                      setImageData();
                      setState(() {
                        isPhoto = false;
                      });
                    }
                  })
            ]),
          ),
        ),
      ),
    );
  }

  // Widget sendImage() {
  //   return BubbleNormalImage(
  //     id: '',
  //     image: Image.network(imageUrl),
  //     isSender: true,
  //   );
  // }

  Future<void> setImageData() async {
    //store in corressponding document
    CollectionReference imageMessageRef = await db
        .collection("conversations")
        .doc(widget.admin + widget.businessID)
        .collection('messages');

    var data = {
      'content': imageUrl,
      'isImage': true,
      'reciever': widget.businessID,
      'sender': widget.admin,
      'timeSent': Timestamp.now()
    };
    imageMessageRef.add(data);
  }

  // This function calls an image picker to choose an image from user gallery
  void uploadImage() async {
    print('in upload image');

    // Pick image from gallery
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // Checks if image is null
    if (image == null) {
      print('image is null');
      return;
    }

    // Timestamp for unique name for image
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload to Firebase storage
    // Get a reference to storage
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('messageImages');

    // Create reference for image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    // Handle error/success
    try {
      // Store the file
      await referenceImageToUpload.putFile(File(image.path));

      // Get download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        isPhoto = true;
      });
    } catch (error) {}
  }

  // Widget will load previous messages
  Widget loadMessages() {
    print('in load messages');
    return StreamBuilder(
        stream: db
            .collection('conversations')
            .doc(widget.admin + widget.businessID)
            .collection('messages')
            .orderBy('timeSent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('snapshot has data');
            print('not waiting');
            print(snapshot.data?.size);
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data?.size,
                  itemBuilder: (context, index) {
                    return buildItem(snapshot.data?.docs[index]);
                  }),
            );
          } else {
            return Text("Be the first to send a message");
          }
        });
  }

  // This will build invididual message bubble using the Chat Bubbles package
  Widget buildItem(QueryDocumentSnapshot<Map<String, dynamic>>? document) {
    print('is in build item' + (document?.get('isImage') ? 'image' : 'text'));
    if (document?.get('isImage')) {
      print('is image');
      if (document?.get('sender') == widget.admin) {
        return BubbleNormalImage(
            color: Colors.transparent,
            id: '',
            isSender: true,
            image: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(0)),
                  child: Image.network(document?.get('content'))),
            ));
      } else {
        return BubbleNormalImage(
            color: Colors.transparent,
            id: "",
            isSender: false,
            image: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(20)),
                  child: Image.network(document?.get('content'))),
            ));
      }
    } else {
      print('sending');
      if (document?.get('sender') == widget.admin) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: BubbleNormal(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              text: document?.get('content'),
              color: Color(0xff8FD694),
              tail: true,
              isSender: true),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: BubbleNormal(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              text: document?.get('content'),
              color: Color(0xff2C003F),
              tail: true,
              isSender: false),
        );
      }
    }
  }

  // Handle sending messages including images
  void sendMessage(String content) {
    final data;
    data = {
      'content': content,
      'isImage': false,
      'reciever': widget.businessID,
      'sender': widget.admin,
      'timeSent': Timestamp.now()
    };

    final ref = db
        .collection('conversations')
        .doc(widget.admin + widget.businessID)
        .collection('messages')
        .doc();

    if (_textController.text != '') {
      ref.set(data);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    setState(() {
      detailFocusColor = Colors.transparent;
    });

    // return Text(
    //   data['content'],
    //   style: TextStyle(color: Colors.black),
    // );
    // return BubbleNormal(
    //     text: data['content'],
    //     isSender: true,
    //     color: Color.fromRGBO(120, 202, 210, 1),
    //     tail: true);
  }
}

  // This will display the messages and images in addition to the text field at the bottom.
