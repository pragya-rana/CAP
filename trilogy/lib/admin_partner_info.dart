import 'package:flutter/material.dart';
import 'package:trilogy/admin_tab_bar.dart';

class AdminPartnerInfo extends StatefulWidget {
  const AdminPartnerInfo({Key? key}) : super(key: key);

  @override
  State<AdminPartnerInfo> createState() => _AdminPartnerInfoState();
}

class _AdminPartnerInfoState extends State<AdminPartnerInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(
              'images/dallas_cowboys_cover_picture.jpeg',
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
                  Navigator.of(context).pop();
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
                              AssetImage('images/dallas_cowboys_logo.jpeg'),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color(0xff8FD694).withOpacity(0.2),
                              radius: 20,
                              child: Icon(
                                Icons.monetization_on,
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
                                Icons.sports_football,
                                color: Color(0xff2C003F),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Spacer(),
                    Text(
                      'Dallas Cowboys',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Spacer(),
                    Row(
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
                            Text('Dallas, Texas')
                          ],
                        ),
                        SizedBox(
                          width: 50,
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
                            Text('123-456-789')
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                        'The Dallas Cowboys are the best team in the NFL. They are better than the Philadelphia Eagles. In fact, I think they can win the divsion this year. They may not have had good games against over .500 teams, but I still love the blowouts. Dak Prescott is doing so well (except for that last game). Ceedee Lamb too. Micah Parsons needs to get better. The whole defensive line needs to start sacking the QB. Anyways, that\'s the Dallas Cowboys in a couple of words.'),
                    Spacer(),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
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
                          onPressed: () {},
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
