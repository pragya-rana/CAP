import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/student/student_messsages.dart';
import 'package:trilogy/classes/icon_field.dart';
import 'package:trilogy/classes/icon_type.dart';
import 'package:trilogy/classes/partner.dart';
import 'package:trilogy/tabs/admin_tab_bar.dart';

// This class is a widget provides information about each partner
// to the administrator.
class AdminPartnerInfo extends StatefulWidget {
  final Partner partner;
  final GoogleSignInAccount user;
  const AdminPartnerInfo({Key? key, required this.partner, required this.user})
      : super(key: key);

  @override
  State<AdminPartnerInfo> createState() => _AdminPartnerInfoState();
}

class _AdminPartnerInfoState extends State<AdminPartnerInfo> {
  String coverUrl = '';
  Future<void> getCoverImage() async {
    var ref =
        FirebaseStorage.instance.ref().child("cover_images/cover_image.jpg");
    String url = (await ref.getDownloadURL()).toString();
    setState(() {
      coverUrl = url;
    });
  }

  @override
  void initState() {
    getCoverImage();
    super.initState();
  }

  // Builds the layout of the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: coverUrl == ''
                ? Container()
                : Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 32, left: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return AdminTabBar(currentPage: 1, user: widget.user);
                    },
                  ));
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.5),
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(widget.partner.logo_url),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color(0xff8FD694).withOpacity(0.2),
                              radius: 20,
                              child: Icon(
                                IconType(widget.partner.type).findIcon(),
                                color: Color(0xff8FD694),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CircleAvatar(
                              backgroundColor:
                                  Color(0xff2C003F).withOpacity(0.1),
                              radius: 20,
                              child: Icon(
                                IconField(widget.partner.field).findIcon(),
                                color: Color(0xff2C003F),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Spacer(),
                    Text(
                      widget.partner.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xff8FD694),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(widget.partner.location)
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Color(0xff8FD694),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(widget.partner.contactInfo)
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      widget.partner.description,
                    ),
                    Spacer(),
                    // Dynamically updates status of each partner through Firebase
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('partnerships')
                            .doc(widget.partner.partnerId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return Text('Document does not exist');
                          } else {
                            var status = snapshot.data!['status'] as String;
                            if (status == 'Pending') {
                              return buildApproveButton(widget.partner);
                            } else if (status == 'Accepted') {
                              return buildAcceptedButton();
                            } else {
                              return Container();
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The administrator has the ability to reject a business
  // if they feel that the partnership is not suitable.
  Widget buildRejectedButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(-4, 4),
            blurRadius: 20,
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          'Partner Has Been Rejected',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // The administrator has the ability to message the business
  // when the business has been approved for partnership.
  Widget buildAcceptedButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return MessagesPage(
                admin: widget.user.displayName!, business: widget.partner.name);
          },
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff8FD694),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: Offset(-4, 4),
              blurRadius: 20,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Message',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // The administrator has the ability to accept the business
  // as a partner if they believe the partnership is acceptable.
  Widget buildApproveButton(Partner partner) {
    return Row(
      children: [
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('partnerships')
                .doc(partner.partnerId)
                .update({'status': 'Accepted'});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xff8FD694),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  offset: Offset(-4, 4),
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Approve Partnership',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('partnerships')
                .doc(partner.partnerId)
                .update({'status': 'Rejected'});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xff2C003F),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  offset: Offset(-4, 4),
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
