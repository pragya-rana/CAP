import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AdminApprovals extends StatefulWidget {
  const AdminApprovals({Key? key}) : super(key: key);

  @override
  State<AdminApprovals> createState() => _AdminApprovalsState();
}

class _AdminApprovalsState extends State<AdminApprovals> {
  List<Map<String, String>> pendingApprovals = [
    {'image': 'images/lego_logo.png', 'name': 'LEGO', 'type': 'Business'},
    {
      'image': 'images/mcdonalds_logo.png',
      'name': 'McDonald\'s',
      'type': 'Business'
    },
    {'image': 'images/amazon_logo.jpeg', 'name': 'Amazon', 'type': 'Business'},
    {'image': 'images/xbox_logo.png', 'name': 'Xbox', 'type': 'Business'},
    {
      'image': 'images/dallas_cowboys_logo.jpeg',
      'name': 'Dallas Cowboys',
      'type': 'Business'
    },
    {
      'image': 'images/hollister_logo.png',
      'name': 'Hollister',
      'type': 'Business'
    },
    {'image': 'images/fanta_logo.png', 'name': 'Fanta', 'type': 'Business'},
    {
      'image': 'images/boxed_water_logo.png',
      'name': 'Boxed Water',
      'type': 'Business'
    },
  ];

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
                            SlidableAction(
                              backgroundColor: Color(0xff8FD694),
                              icon: Icons.delete,
                              label: 'Reject',
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              onPressed: (context) {
                                setState(() {
                                  pendingApprovals.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        child: approvalCard(
                          pendingApprovals[index]['image']!,
                          pendingApprovals[index]['name']!,
                          pendingApprovals[index]['type']!,
                        ),
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

  Widget approvalCard(String image_url, String name, String type) {
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
            // This will replace the image
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  image_url,
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
                    name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    type,
                    style: TextStyle(color: Color(0xff8FD694)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
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
