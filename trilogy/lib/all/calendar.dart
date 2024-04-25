import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trilogy/classes/event.dart';

// This class is a widget that represents a calendar with events that the user can see.
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    print('is init state first');
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _getEventsFromFirestore();
    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    super.dispose();
  }

  // gets events from a certain DateTime.
  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  // Accesses Firebase Firestore to get events from a certina DateTime.
  Future<List<Event>> _getEventsForDayFromFirestore(DateTime day) async {
    DateTime startOfDay = DateTime(day.year, day.month, day.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: startOfDay)
        .where('startDate', isLessThan: endOfDay)
        .get();

    final events = snapshot.docs.map((doc) {
      final title = doc['title'] as String;
      final description = doc['description'] as String;
      final name = doc['name'] as String;
      final startTime = DateFormat('h:mm a').format(doc['startDate'].toDate());
      final endTime = DateFormat('h:mm a').format(doc['endDate'].toDate());
      final location = doc['location'] as String;
      return Event(title, description, name, startTime, endTime, location);
    }).toList();

    return events;
  }

  // When a certain day is clicked on the calendar, this method is called.
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

  // Accessed Firebase Firestore to get a list of events that are available to the user.
  Future<void> _getEventsFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    Map<DateTime, List<Event>> events = {};
    snapshot.docs.forEach((doc) {
      final date = (doc['startDate'] as Timestamp).toDate();
      final title = doc['title'] as String;
      final description = doc['description'] as String;
      final name = doc['name'] as String;
      final startTime = DateFormat('hh:mm a').format(doc['startDate'].toDate());
      final endTime = DateFormat('hh:mm a').format(doc['endDate'].toDate());
      final location = doc['location'] as String;

      if (events.containsKey(date)) {
        events[date]!
            .add(Event(title, description, name, startTime, endTime, location));
      } else {
        events[date] = [
          Event(title, description, name, startTime, endTime, location)
        ];
      }
    });
    setState(() {
      this.events = events;
    });
  }

  // Displays the actual layout of the calendar.
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

  // Displays each event under the calendar to provided additional information to the user.
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
                    SizedBox(height: 3),
                    Text(
                      event.name,
                      style: TextStyle(color: Color(0xff2C003F), fontSize: 14),
                    ),
                  ],
                ),
              ),
              trailing: Icon(Icons.more_vert, color: Colors.grey),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    title: Text(
                      'Description:',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    subtitle: Text(
                      event.description,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    title: Text(
                      'Location:',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    subtitle: Text(
                      event.location,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
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
