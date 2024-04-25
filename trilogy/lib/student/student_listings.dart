import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/classes/check_box_modal.dart';
import 'package:trilogy/classes/listing.dart';
import 'package:trilogy/student/student_submit_app.dart';
import 'package:trilogy/tabs/student_tab.dart';

// This class is a widget that displays all of the listings available to the student.
class StudentListings extends StatefulWidget {
  const StudentListings({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<StudentListings> createState() => _StudentListingsState();
}

class _StudentListingsState extends State<StudentListings> {
  List<Listing> listingData = [];
  List<Listing> displayedListings = [];

  TextEditingController locationController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();

  bool isFilter = false;
  bool isLoading = false;

  final typeCheckedBoxList = [
    CheckBoxModal(title: 'Job'),
    CheckBoxModal(title: 'Internship'),
    CheckBoxModal(title: 'Volunteer')
  ];

  final ageCheckedBoxList = [
    CheckBoxModal(title: '9th'),
    CheckBoxModal(title: '10th'),
    CheckBoxModal(title: '11th'),
    CheckBoxModal(title: '12th'),
  ];

  TextEditingController controller = TextEditingController();

  // Gets all available listings from Firestore.
  Future<void> getListings() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('listings')
        .get()
        .then((value) => {
              value.docs.forEach((element) async {
                DateTime deadline = element.data()['deadline'].toDate();
                if (deadline.compareTo(DateTime.now()) > 0) {
                  String applicationRef = element.data()['applicationRef'];
                  String description = element.data()['description'];
                  String gradeLevel = element.data()['gradeLevel'];
                  String location = element.data()['location'];
                  String name = element.data()['name'];
                  String refName = element.data()['refName'];
                  String title = element.data()['title'];
                  String type = element.data()['type'];
                  String logoRef = element.data()['logoRef'];
                  var ref = FirebaseStorage.instance
                      .ref()
                      .child("logos/" + logoRef.split('/')[1]);
                  String logo_url = (await ref.getDownloadURL()).toString();
                  Listing listing = Listing(
                      applicationRef,
                      refName,
                      logo_url,
                      name,
                      title,
                      description,
                      location,
                      type,
                      gradeLevel,
                      deadline);

                  setState(() {
                    listingData.add(listing);
                    displayedListings.add(listing);
                  });
                }
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
    getListings();
  }

  // Facilitates the filtering mechanism.
  void onItemClicked(CheckBoxModal ckbItem, String filterName) {
    final newValue = !ckbItem.value;
    setState(() {
      ckbItem.value = newValue;
      updateDisplayedPartnerships();
    });
  }

  // Updates partnerships that are displayed to the user based on the filtered results.
  void updateDisplayedPartnerships() {
    setState(() {
      displayedListings = listingData.where((listing) {
        return typeCheckedBoxList
                .any((item) => item.value && item.title == listing.type) &&
            ageCheckedBoxList.any((item) =>
                (item.value && item.title == listing.gradeLevel) ||
                listing.gradeLevel == 'No Requirement') &&
            listing.location
                .toLowerCase()
                .contains(locationController.text.toLowerCase()) &&
            listing.name
                .toLowerCase()
                .contains(companyNameController.text.toLowerCase());
      }).toList();
    });
  }

  // Builds filters for text fields (such as company or name).
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
                                    TextField(
                                      controller: controller,
                                      onChanged: (_) =>
                                          updateDisplayedPartnerships(),
                                      decoration: InputDecoration(
                                        // border: InputBorder.,
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

  // Builds filters for checkboxes for other filters incorporated.
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

  // Builds the actual layout of the listings and filtering.
  @override
  Widget build(BuildContext context) {
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
            buildFilterRow(ageCheckedBoxList, 'Grade'),
            SizedBox(
              width: 20,
            ),
            buildTextFieldFilter('Company Name', companyNameController),
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.grey,
            ))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Browse Listings',
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
                                  return StudentTabBar(
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
                              onChanged: searchListing,
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
                                  'Search for a listing',
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
                                searchListing('');
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
                        height: 10,
                      ),
                      displayedListings.length == 0
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
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: displayedListings.length,
                              itemBuilder: (context, index) {
                                return buildListingsCard(
                                    displayedListings[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Displays each card with all of the necessary information.
  Widget buildListingsCard(Listing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return StudentSubmitApp(
              listing: listing,
              user: widget.user,
            );
          },
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: Offset(1, 1)),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              listing.logo_url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Text(
                                listing.name + ' • ' + listing.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff2C003F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Colors.grey.withOpacity(0.15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      listing.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.business_center,
                              size: 17,
                              color: Color(0xff8FD694),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              listing.type,
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 12),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              color: Color(0xff8FD694),
                              size: 17,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              listing.gradeLevel,
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filters via the search field at the top of the screen.
  void searchListing(String query) {
    final suggestions = listingData.where((listing) {
      final name = listing.name.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      displayedListings.clear();
      displayedListings.addAll(suggestions);
    });

    if (query.isEmpty) {
      setState(() {
        displayedListings.clear();
        displayedListings.addAll(listingData);
      });
    }
  }
}
