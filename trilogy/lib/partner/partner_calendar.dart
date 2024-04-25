import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trilogy/classes/event.dart';

// This class represents the calendar that the partner sees.
class PartnerCalendar extends StatefulWidget {
  const PartnerCalendar({super.key, required this.user});

  final GoogleSignInAccount user;
  @override
  State<PartnerCalendar> createState() => _PartnerCalendarState();
}

class _PartnerCalendarState extends State<PartnerCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;
  String companyName = '';

  @override
  void initState() {
    print('is init state first');
    getName();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _getEventsFromFirestore();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Gets the event only for a specific DateTime/
  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  // Gets the name of the company from Firebase.
  Future<void> getName() async {
    var userQuery = await FirebaseFirestore.instance
        .collection('partnerships')
        .where('contactInfo', isEqualTo: widget.user.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userSnapshot = userQuery.docs.first;
      setState(() {
        companyName = userSnapshot.data()['name'];
      });
    }
  }

  // Gets a list of events offered by the company from Firestore.
  Future<List<Event>> _getEventsForDayFromFirestore(DateTime day) async {
    DateTime startOfDay = DateTime(day.year, day.month, day.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: startOfDay)
        .where('startDate', isLessThan: endOfDay)
        .where('name', isEqualTo: companyName)
        .get();

    final events = snapshot.docs.map((doc) {
      final name = doc['name'] as String;
      final title = doc['title'] as String;
      final description = doc['description'] as String;
      final startTime = DateFormat('h:mm a').format(doc['startDate'].toDate());
      final endTime = DateFormat('h:mm a').format(doc['endDate'].toDate());
      final location = doc['location'] as String;
      return Event(title, description, name, startTime, endTime, location);
    }).toList();

    return events;
  }

  // This method is called when the user clicks on a certain date on the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      final eventsForSelectedDay =
          await _getEventsForDayFromFirestore(selectedDay);
      setState(() {
        _selectedEvents.value = eventsForSelectedDay;
      });
    }
  }

  // Gets all of the events from Firestore.
  Future<void> _getEventsFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    Map<DateTime, List<Event>> events = {};
    snapshot.docs.forEach((doc) {
      final name = doc['name'] as String;
      if (name == companyName) {
        final date = (doc['startDate'] as Timestamp).toDate();
        final title = doc['title'] as String;
        final description = doc['description'] as String;
        final startTime =
            DateFormat('hh:mm a').format(doc['startDate'].toDate());
        final endTime = DateFormat('hh:mm a').format(doc['endDate'].toDate());
        final location = doc['location'] as String;

        if (events.containsKey(date)) {
          events[date]!.add(
              Event(title, description, name, startTime, endTime, location));
        } else {
          events[date] = [
            Event(title, description, name, startTime, endTime, location)
          ];
        }
      }
    });
    setState(() {
      this.events = events;
    });
  }

  // This method builds the actual layout of the calendar that the partner sees.
  @override
  Widget build(BuildContext context) {
    print('is build first');
    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                child: TableCalendar(
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final dateWithoutTime =
                            DateTime(date.year, date.month, date.day);
                        if (this.events.keys.any((key) {
                          final keyWithoutTime =
                              DateTime(key.year, key.month, key.day);
                          return keyWithoutTime
                              .isAtSameMomentAs(dateWithoutTime);
                        })) {
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff2C003F),
                              ),
                              width: 6.0,
                              height: 6.0,
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    eventLoader: _getEventsForDay,
                    rowHeight: 50,
                    focusedDay: _focusedDay,
                    availableGestures: AvailableGestures.all,
                    headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        )),
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2100),
                    onDaySelected: _onDaySelected,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusDay) {
                      _focusedDay = focusDay;
                    },
                    calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xff8FD694),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Color(0xff2C003F),
                          fontWeight: FontWeight.bold,
                        ),
                        todayDecoration: BoxDecoration())),
              ),
              SizedBox(
                height: 8,
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.length == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(1, 1),
                                      blurRadius: 40),
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'There are no events this day.\nFeel free to browse through other available events.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Icon(
                                  Icons.event_busy,
                                  color: Color(0xff8FD694),
                                  size: 80,
                                )
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: buildEventItem(value[index]));
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  // This method displays information about each event underneath the calendar.
  Widget buildEventItem(Event event) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(1, 1),
                      blurRadius: 40)
                ]),
            child: ExpansionTile(
              shape: Border(),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later,
                          size: 20,
                          color: Color(0xff8FD694),
                        ),
                        SizedBox(width: 10),
                        Text(
                          event.startTime + ' - ' + event.endTime,
                          style:
                              TextStyle(color: Color(0xff9E9E9E), fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Icon(Icons.more_vert, color: Colors.grey),
              children: [
                ListTile(
                  title: Text(
                    'Description:',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  subtitle: Text(
                    event.description,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Location:',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  subtitle: Text(
                    event.location,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            )),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
