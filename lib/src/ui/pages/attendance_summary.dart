import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/src/models/AttendaceList.dart';
import 'package:geo_attendance_system/src/services/fetch_attendance.dart';
import 'package:geo_attendance_system/src/ui/constants/colors.dart';
import 'package:geo_attendance_system/src/ui/widgets/loader_dialog.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 11, 18): ['Easter Monday'],
  DateTime(2019, 12, 25): ['Christmas Eve'],
};

class AttendanceSummary extends StatefulWidget {
  AttendanceSummary({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _AttendanceSummaryState createState() => _AttendanceSummaryState();
}

class _AttendanceSummaryState extends State<AttendanceSummary>
    with TickerProviderStateMixin {
  LinkedHashMap<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  DateTime _selectedDay;
  DateTime _focusedDay;
  CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    final _selectedDay = DateTime.now();

    _events = LinkedHashMap();

    _selectedEvents = _events[_selectedDay] ?? [];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _onDaySelected(DateTime day, List events) {
  //   onLoadingDialog(context);
  //   AttendanceDatabase.getAttendanceListOfParticularDateBasedOnUID(
  //           widget.user.uid, day)
  //       .then((AttendanceList attendanceList) {
  //     print(attendanceList.attendanceList);
  //     attendanceList.attendanceList.forEach((Attendance attendance) {
  //       print(attendance.office);
  //       events.add(
  //           "Type: ${attendance.type.toString().split('.').last} Time: ${attendance.time.hour} hours ${attendance.time.minute} minutes at ${attendance.office} ");
  //       setState(() {
  //         _selectedEvents = events;
  //       });
  //     });
  //
  //     if (attendanceList.attendanceList.length == 0) {
  //       setState(() {
  //         _selectedEvents = [];
  //       });
  //     }
  //
  //     Navigator.of(context, rootNavigator: true).pop('dialog');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarcolor,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Attendance History",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Poppins-Medium",
              fontSize: 22,
              letterSpacing: .6,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0.8,
        centerTitle: true,
        bottomOpacity: 0,
      ),
      body: SafeArea(
        child: Container(
          color: dashBoardColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTableCalendarWithBuilders(),
              const SizedBox(height: 8.0),
              _buildButtons(),
              const SizedBox(height: 8.0),
              Expanded(child: _buildEventList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'en_US',
      focusedDay: DateTime.now(),
      firstDay: DateTime(2000),
      lastDay: DateTime.now(),
      eventLoader: (dateTime) => _events[dateTime],
      holidayPredicate: (dateTime) => _holidays
          .containsKey(DateTime(dateTime.year, dateTime.month, dateTime.day)),
      calendarFormat: CalendarFormat.month,
      formatAnimationCurve: Curves.fastOutSlowIn,
      formatAnimationDuration: const Duration(milliseconds: 400),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        defaultTextStyle: TextStyle().copyWith(color: Colors.white),
        weekendTextStyle: TextStyle().copyWith(color: Colors.grey),
        holidayTextStyle: TextStyle().copyWith(color: Colors.white),
        outsideTextStyle: TextStyle().copyWith(color: Colors.grey),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle().copyWith(color: Colors.white),
        weekendStyle: TextStyle().copyWith(color: Colors.white),
      ),
      headerStyle: HeaderStyle(
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white60),
        rightChevronIcon:
            const Icon(Icons.chevron_right, color: Colors.white60),
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
        titleCentered: true,
        formatButtonVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 11.0, left: 12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber[500],
              ),
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        todayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 11.0, left: 12.0),
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(29, 209, 161, 1.0),
            ),
          );
        },
      ),

      selectedDayPredicate: (day) {
        // Use `selectedDayPredicate` to determine which day is currently selected.
        // If this returns true, then `day` will be marked as selected.

        // Using `isSameDay` is recommended to disregard
        // the time-part of compared DateTime objects.
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          // Call `setState()` when updating calendar format
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        _focusedDay = focusedDay;
      },

    );


  }


  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.weekend,
      size: 20.0,
      color: Colors.blueGrey,
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigo),
              ),
              child: Text(
                'Month',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  // _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal),
              ),
              child: Text(
                '2 weeks',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  // _calendarController
                  //     .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: Text(
                'Week',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  CalendarFormat.week;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 15.0),
        Text(
          "Attendance History Preview".toUpperCase(),
          style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 3),
        ),
        const SizedBox(height: 2.0),
      ],
    );
  }

  Widget _buildEventList() {
    return _selectedEvents.length != 0
        ? ListView(
            children: _selectedEvents
                .map((event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          event.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () => print('$event tapped!'),
                      ),
                    ))
                .toList(),
          )
        : Text(
            "No Records Found".toUpperCase(),
            style: TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontFamily: "poppins-medium"),
          );
  }
}
