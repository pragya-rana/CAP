import "package:chat_bubbles/chat_bubbles.dart";
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Initializes Firestore database
var db = FirebaseFirestore.instance;

// This class displays the messaging page to the business.
// The student can directly interact with an admin via text and messages.
class MessagesPage extends StatefulWidget {
  const MessagesPage({
    Key? key,
    required this.admin,
    required this.business,
  }) : super(key: key);

  final String admin;
  final String business;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // This controller keeps track of the text that the user messages
  final TextEditingController _textController = TextEditingController();

  // This controller makes sure to scroll to the bottom after every text message
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

  // If the focus on the text field changes, the color of the text field will change as well.
  Color detailFocusColor = Colors.transparent;

  // This function will get the teacher's name from Firebase by accessing the teachers collection.
  Future<void> getAdminName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('administrators')
        .doc(widget.admin)
        .get();

    if (snapshot.exists) {
      setState(() {
        adminName =
            snapshot.data()!['firstName'] + ' ' + snapshot.data()!['lastName'];
      });
    }
  }

  // This will get the messages and admin name when the page initializes.
  @override
  void initState() {
    loadMessages();
    getAdminName();
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
                widget.business,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          loadMessages(),
          buildInputBox(),
        ]));
  }

  // This is the text box widget at the bottom of the screen.
  Widget buildInputBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 32),
            child: Row(children: [
              LayoutBuilder(builder: (context, constraints) {
                // If user has not selected photo, the add button will be present
                if (!isPhoto) {
                  return IconButton(
                    icon: Icon(Icons.add),

                    // The user will need to give permission to access images
                    onPressed: () {
                      () async {
                        var _permissionStatus = await Permission.storage.status;

                        //should allow user to grant permission to image gallery
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

                  // Otherwise, there will be a close icon to remove the image
                } else {
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
                  // If the user has not selected a photo, a text field will show for the user to type
                  // as message.
                  if (!isPhoto) {
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

                    // If the user has selected an image, the image will show in a container and the text field
                    // won't show up.
                  } else {
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

              // When the send button is clicked, either the message or the image will be
              // added to Firebase and Firebase Storage and show up in the display.
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (!isPhoto) {
                      String message = _textController.text;
                      print('message: ' + message);
                      sendMessage(message);
                      _textController.clear();
                      loadMessages();
                    } else {
                      print('in photo');
                      //send an image!
                      //sendImage();
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

  // This will return an image in a chat bubble based on an image url.
  Widget sendImage() {
    return BubbleNormalImage(
      id: '',
      image: Image.network(imageUrl),
      isSender: true,
    );
  }

  // This will set the image data in Firebase, so that it can be later retrieved.
  // It is set in the messages collection, which is in the conversations collection.
  Future<void> setImageData() async {
    CollectionReference imageMessageRef = await db
        .collection("conversations")
        .doc(widget.admin + widget.business)
        .collection('messages');

    var data = {
      'content': imageUrl,
      'isImage': true,
      'reciever': widget.admin,
      'sender': widget.business,
      'timeSent': Timestamp.now()
    };

    imageMessageRef.add(data);
  }

  // This will use the image picker to choose an image from the user's photos
  void uploadImage() async {
    // Pick image from gallery
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // Check if image null
    if (image == null) {
      print('image is null');
      return;
    }

    //T imestamp for unique name for image
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload to Firebase storage
    //Gget a reference to storage
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('messageImages');

    // Create reference for image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    // Handle error/success
    try {
      //Store the file
      await referenceImageToUpload.putFile(File(image.path));

      //get download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        isPhoto = true;
      });
    } catch (error) {}
  }

  // This function load previous messages using a StreamBuilder.
  // A StreamBuilder is used because this is happening in real time.
  Widget loadMessages() {
    print('in load messages');
    return StreamBuilder(
        stream: db
            .collection('conversations')
            .doc(widget.admin + widget.business)
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

  // This will build an invididual message bubble using the Chat Bubbles package.
  Widget buildItem(QueryDocumentSnapshot<Map<String, dynamic>>? document) {
    print('is in build item' + (document?.get('isImage') ? 'image' : 'text'));
    if (document?.get('isImage')) {
      print('is image');
      if (document?.get('sender') == widget.business) {
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
      if (document?.get('sender') == widget.business) {
        print('sending 2');
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
          child: Column(
            children: [
              BubbleNormal(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  text: document?.get('content'),
                  color: Color(0xff2C003F),
                  tail: true,
                  isSender: false),
            ],
          ),
        );
      }
    }
  }

  // This will handle sending messages by setting it in Firestore.
  void sendMessage(String content) {
    final data;
    data = {
      'content': content,
      'isImage': false,
      'reciever': widget.admin,
      'sender': widget.business,
      'timeSent': Timestamp.now(),
    };

    final ref = db
        .collection('conversations')
        .doc(widget.admin + widget.business)
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
  }
}
