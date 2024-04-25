import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/admin/admin_partner_info.dart';
import 'package:trilogy/classes/partner.dart';

// This class allows administrators to approve businesses/roganizations
class AdminApprovals extends StatefulWidget {
  final GoogleSignInAccount user;
  const AdminApprovals({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminApprovals> createState() => _AdminApprovalsState();
}

class _AdminApprovalsState extends State<AdminApprovals> {
  List<Partner> pendingApprovals = [];

  @override
  void initState() {
    super.initState();
    getPendingApprovals();
  }

  // Retrieves requests from businesses to becoome partner through Firebase
  Future<void> getPendingApprovals() async {
    await FirebaseFirestore.instance
        .collection('partnerships')
        .get()
        .then((value) => {
              value.docs.forEach((element) async {
                String status = element.data()['status'] as String;
                if (status == 'Pending') {
                  String name = element.data()['name'] as String;
                  String field = element.data()['field'] as String;
                  String type = element.data()['type'] as String;
                  String contactInfo = element.data()['contactInfo'] as String;
                  String partnerId = element.id;
                  String logoRef = element.data()['logoRef'];
                  String location = element.data()['location'] as String;
                  String description = element.data()['description'] as String;
                  var ref = FirebaseStorage.instance
                      .ref()
                      .child("logos/" + logoRef.split('/')[1]);
                  String url = (await ref.getDownloadURL()).toString();
                  Partner partner = Partner(name, contactInfo, status, type,
                      field, url, url, partnerId, location, description);
                  setState(() {
                    pendingApprovals.add(partner);
                  });
                }
              })
            });
  }

  // Displays pending approvals widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Approvals',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pendingApprovals.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: StretchMotion(),
                          children: [
                            // Admin can automatically reject
                            SlidableAction(
                              backgroundColor: Color(0xff8FD694),
                              icon: Icons.delete,
                              label: 'Reject',
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              onPressed: (context) {
                                setState(() {
                                  String partnerId =
                                      pendingApprovals[index].partnerId;
                                  FirebaseFirestore.instance
                                      .collection('partnerships')
                                      .doc(partnerId)
                                      .update({'status': 'Rejected'});
                                  pendingApprovals.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        child: approvalCard(pendingApprovals[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Represents each business that requires approval.
  Widget approvalCard(Partner partner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(1, 1),
            blurRadius: 40,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  partner.logo_url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    partner.type,
                    style: TextStyle(color: Color(0xff8FD694)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return AdminPartnerInfo(
                      partner: partner,
                      user: widget.user,
                    );
                  },
                ));
              },
              icon: Icon(
                Icons.more_vert_sharp,
                color: Color(0xff9E9E9E),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
