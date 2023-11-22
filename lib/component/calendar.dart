import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:schedule_management/const/colors.dart';


class Calendar extends StatelessWidget{
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final OnDaySelected? onDaySelected;

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      color: Colors.grey[200],
    );
    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(

      locale: 'ko_KR',
      daysOfWeekHeight:25,
      focusedDay: focusedDay,
      firstDay: DateTime(2000),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xff90BEF3),
          borderRadius: BorderRadius.circular(6.0),
        ),
        defaultDecoration: defaultBoxDeco,
        weekendDecoration: defaultBoxDeco,
        selectedDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white,
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
        outsideDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        defaultTextStyle: defaultTextStyle,
        weekendTextStyle: defaultTextStyle,
        selectedTextStyle: defaultTextStyle.copyWith(
          color: PRIMARY_COLOR,
        ),

      ),
      //날짜 선택시 실행되는 함수
      onDaySelected: onDaySelected,
      //선택된 날짜가 맞는지 확인하는 함수
      selectedDayPredicate: (DateTime date) {
        if(selectedDay == null) {
          return false;
        }
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      },
    );
  }
}
