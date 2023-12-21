import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AdminFindPartnerships extends StatefulWidget {
  const AdminFindPartnerships({Key? key}) : super(key: key);

  @override
  State<AdminFindPartnerships> createState() => _AdminFindPartnershipsState();
}

class _AdminFindPartnershipsState extends State<AdminFindPartnerships> {
  var partnershipData = [
    {'image': 'images/lego_logo.png', 'name': 'LEGO', 'type': 'Business'},
    {
      'image': 'images/mcdonalds_logo.png',
      'name': 'McDonald\'s',
      'type': 'Business',
      'location': 'New York',
      'subject': 'Food'
    },
    {
      'image': 'images/amazon_logo.jpeg',
      'name': 'Amazon',
      'type': 'Business',
      'location': 'Washington',
      'subject': 'Technology'
    },
    {
      'image': 'images/xbox_logo.png',
      'name': 'Xbox',
      'type': 'Business',
      'location': 'Washington',
      'subject': 'Technology'
    },
    {
      'image': 'images/dallas_cowboys_logo.jpeg',
      'name': 'Dallas Cowboys',
      'type': 'Business',
      'location': 'Texas',
      'subject': 'Sports'
    },
    {
      'image': 'images/hollister_logo.png',
      'name': 'Hollister',
      'type': 'Business',
      'location': 'California',
      'subject': 'Fashion'
    },
    {
      'image': 'images/fanta_logo.png',
      'name': 'Fanta',
      'type': 'Business',
      'location': 'New York',
      'subject': 'Food'
    },
    {
      'image': 'images/boxed_water_logo.png',
      'name': 'Boxed Water',
      'type': 'Business',
      'location': 'New York',
      'subject': 'Food'
    },
  ];

  bool isFilter = false;

  final typeCheckedBoxList = [
    CheckBoxModal(title: 'Business'),
    CheckBoxModal(title: 'Nonprofit'),
    CheckBoxModal(title: 'Internship'),
  ];

  final locationCheckedBoxList = [
    CheckBoxModal(title: 'New York'),
    CheckBoxModal(title: 'California'),
    CheckBoxModal(title: 'Washington'),
    CheckBoxModal(title: 'Texas'),
  ];

  final subjectCheckedBoxList = [
    CheckBoxModal(title: 'Technology'),
    CheckBoxModal(title: 'Food'),
    CheckBoxModal(title: 'Fashion'),
    CheckBoxModal(title: 'Sports')
  ];

  List<Map<String, String>> displayedPartnerships = [];

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedPartnerships.addAll(partnershipData);
  }

  void onItemClicked(CheckBoxModal ckbItem, String filterName) {
    final newValue = !ckbItem.value;
    setState(() {
      ckbItem.value = newValue;
      updateDisplayedPartnerships();
    });
  }

  void updateDisplayedPartnerships() {
    setState(() {
      displayedPartnerships = partnershipData.where((partnership) {
        return typeCheckedBoxList.any(
                (item) => item.value && item.title == partnership['type']) &&
            locationCheckedBoxList.any((item) =>
                item.value && item.title == partnership['location']) &&
            subjectCheckedBoxList.any(
                (item) => item.value && item.title == partnership['subject']);
      }).toList();
    });
  }

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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 60),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Filter by ' + filterName + ':',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Spacer(),
                                    ...checkBoxList.map(
                                      (item) => ListTile(
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
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Spacer(),
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
            buildFilterRow(locationCheckedBoxList, 'Location'),
            SizedBox(
              width: 20,
            ),
            buildFilterRow(subjectCheckedBoxList, 'Subject'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find\nPartnerships',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
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
                        height: MediaQuery.of(context).size.height * 0.065,
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.6),
                  ),
                  itemCount: displayedPartnerships.length,
                  itemBuilder: (context, index) {
                    return partnershipCard(
                      displayedPartnerships[index]['image']!,
                      displayedPartnerships[index]['name']!,
                      displayedPartnerships[index]['type']!,
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

  Widget partnershipCard(imageUrl, name, type) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                name,
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
              type,
              style: TextStyle(color: Color(0xff9E9E9E), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void searchPartnership(String query) {
    final suggestions = partnershipData.where((partnership) {
      final name = partnership['name']?.toLowerCase();
      final input = query.toLowerCase();
      return name!.contains(input);
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

class CheckBoxModal {
  String title;
  bool value;

  CheckBoxModal({
    required this.title,
    this.value = true,
  });
}
