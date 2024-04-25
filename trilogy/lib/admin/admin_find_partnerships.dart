import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/admin/admin_partner_info.dart';
import 'package:trilogy/classes/check_box_modal.dart';
import 'package:trilogy/tabs/admin_tab_bar.dart';
import 'package:trilogy/classes/partner.dart';

// This class is a widget that allows the admin to browse through existing partnerships.
class AdminFindPartnerships extends StatefulWidget {
  const AdminFindPartnerships({Key? key, required this.user}) : super(key: key);

  final GoogleSignInAccount user;

  @override
  State<AdminFindPartnerships> createState() => _AdminFindPartnershipsState();
}

class _AdminFindPartnershipsState extends State<AdminFindPartnerships> {
  List<Partner> partnershipData = [];
  TextEditingController locationController = TextEditingController();

  bool isFilter = false;
  bool isLoading = false;

  // Filter fields that user can click on
  final typeCheckedBoxList = [
    CheckBoxModal(title: 'Business'),
    CheckBoxModal(title: 'Nonprofit'),
    CheckBoxModal(title: 'Agency'),
  ];

  final statusCheckedBoxList = [
    CheckBoxModal(title: 'Accepted'),
    CheckBoxModal(title: 'Pending'),
    CheckBoxModal(title: 'Rejected')
  ];

  final fieldCheckedBoxList = [
    CheckBoxModal(title: 'Information Technology'),
    CheckBoxModal(title: 'Transportation'),
    CheckBoxModal(title: 'Healthcare'),
    CheckBoxModal(title: 'Agriculture'),
    CheckBoxModal(title: 'Engineering'),
    CheckBoxModal(title: 'Creative Arts'),
    CheckBoxModal(title: 'Business'),
  ];

  List<Partner> displayedPartnerships = [];

  // Represents search bar at the top of the page.
  TextEditingController controller = TextEditingController();

  // Gets all partners with school from Firebase
  Future<void> getPartnerships() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('partnerships')
        .get()
        .then((value) => {
              value.docs.forEach((element) async {
                String status = element.data()['status'] as String;
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
                    field, url, '', partnerId, location, description);
                setState(() {
                  partnershipData.add(partner);
                  displayedPartnerships.add(partner);
                });
              })
            });
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPartnerships();
  }

  // Facilitates the filtering process by setting variables to boolean values.
  void onItemClicked(CheckBoxModal ckbItem, String filterName) {
    final newValue = !ckbItem.value;
    setState(() {
      ckbItem.value = newValue;
      updateDisplayedPartnerships();
    });
  }

  // Updates partnerships that are displayed to the screen after being filtered.
  void updateDisplayedPartnerships() {
    setState(() {
      displayedPartnerships = partnershipData.where((partnership) {
        return typeCheckedBoxList
                .any((item) => item.value && item.title == partnership.type) &&
            statusCheckedBoxList.any(
                (item) => item.value && item.title == partnership.status) &&
            fieldCheckedBoxList
                .any((item) => item.value && item.title == partnership.field) &&
            partnership.location
                .toLowerCase()
                .contains(locationController.text.toLowerCase());
      }).toList();
    });
  }

  // For location and company fields, filtering is done via text
  Widget buildTextFieldFilter(
      String filterName, TextEditingController controller) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            color: Color(0xff2C003F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  filterName,
                  style: TextStyle(color: Color(0xff2C003F)),
                ),
                IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Automatically updates with every letter the user types.
                                    TextField(
                                      controller: controller,
                                      onChanged: (_) =>
                                          updateDisplayedPartnerships(),
                                      decoration: InputDecoration(
                                        hintText: 'Enter $filterName',
                                        hintStyle:
                                            TextStyle(color: Color(0xff2C003F)),
                                      ),
                                      showCursor: true,
                                      style:
                                          TextStyle(color: Color(0xff2C003F)),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        updateDisplayedPartnerships();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff2C003F)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Apply Filter',
                                            style: TextStyle(
                                                color: Color(0xff2C003F)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      isDismissible: true,
                      isScrollControlled: true,
                    );
                  },
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xff2C003F)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // For fields with checkboxes, this widget represents them.
  Row buildFilterRow(List<CheckBoxModal> checkBoxList, String filterName) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            color: Color(0xff2C003F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  filterName,
                  style: TextStyle(color: Color(0xff2C003F)),
                ),
                IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: checkBoxList.length + 2,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          'Filter by $filterName:',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      );
                                    } else if (index <= checkBoxList.length) {
                                      final item = checkBoxList[index - 1];
                                      return ListTile(
                                        onTap: () {
                                          setState(() {
                                            onItemClicked(
                                                item, filterName.toLowerCase());
                                          });
                                        },
                                        leading: Checkbox(
                                          value: item.value,
                                          onChanged: (value) {
                                            setState(() {
                                              onItemClicked(item,
                                                  filterName.toLowerCase());
                                            });
                                          },
                                        ),
                                        title: Text(
                                          item.title,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            updateDisplayedPartnerships();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xff2C003F)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(
                                                'Apply Filter',
                                                style: TextStyle(
                                                    color: Color(0xff2C003F)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      isDismissible: true,
                      isScrollControlled: true,
                    );
                  },
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xff2C003F)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds the actual layout of this page.
  @override
  Widget build(BuildContext context) {
    // Filter options only visible if user clicks on the filter icon.
    var visibility = Visibility(
      visible: isFilter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildFilterRow(typeCheckedBoxList, 'Type'),
            SizedBox(
              width: 20,
            ),
            buildFilterRow(fieldCheckedBoxList, 'Field'),
            SizedBox(
              width: 20,
            ),
            buildFilterRow(statusCheckedBoxList, 'Status'),
            SizedBox(
              width: 20,
            ),
            buildTextFieldFilter('Location', locationController),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.grey,
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Find\nPartnerships',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return AdminTabBar(
                                    currentPage: 1,
                                    user: widget.user,
                                  );
                                },
                              ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(-10, 10),
                                        blurRadius: 30,
                                        color: Colors.black.withOpacity(0.15)),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xff8FD694),
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.60,
                            height: MediaQuery.of(context).size.height * 0.065,
                            decoration: BoxDecoration(
                              color: Color(0xff8FD694).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: controller,
                              onChanged: searchPartnership,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xff8FD694),
                                  ),
                                ),
                                label: Text(
                                  'Search for a partnership',
                                  style: TextStyle(
                                      color: Color(0xff8FD694),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                controller.text = '';
                                searchPartnership('');
                                isFilter = !isFilter;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff8FD694).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width * 0.15,
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              child: Icon(
                                Icons.filter_list,
                                color: Color(0xff8FD694),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      visibility,
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      displayedPartnerships.length == 0
                          ? Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'Looks like we couldn\'t find a match. Please try searching for another partnership.',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Icon(
                                    Icons.not_listed_location_outlined,
                                    size: 110,
                                  )
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                                childAspectRatio: MediaQuery.of(context)
                                        .size
                                        .width /
                                    (MediaQuery.of(context).size.height / 1.6),
                              ),
                              itemCount: displayedPartnerships.length,
                              itemBuilder: (context, index) {
                                return partnershipCard(
                                    displayedPartnerships[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Represents each partner with lots of information.
  Widget partnershipCard(Partner partner) {
    return TextButton(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(1, 1),
              blurRadius: 40,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.21,
                height: MediaQuery.of(context).size.width * 0.21,
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
                height: 5,
              ),
              Center(
                child: Text(
                  partner.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                partner.type,
                style: TextStyle(color: Color(0xff9E9E9E), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Represents the search bar at the top of the screen.
  // This is another way to filter the partners.
  void searchPartnership(String query) {
    final suggestions = partnershipData.where((partnership) {
      final name = partnership.name.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      displayedPartnerships.clear();
      displayedPartnerships.addAll(suggestions);
    });

    if (query.isEmpty) {
      setState(() {
        displayedPartnerships.clear();
        displayedPartnerships.addAll(partnershipData);
      });
    }
  }
}
