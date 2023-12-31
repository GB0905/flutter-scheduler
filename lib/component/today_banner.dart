import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:schedule_management/const/colors.dart';
import 'package:schedule_management/model/schedule_with_category.dart';
import 'package:schedule_management/database/drift_database.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDay;

  const TodayBanner({
    required this.selectedDay,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
              style: textStyle,
            ),
            StreamBuilder<List<ScheduleWithCategory>>(
                stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDay),
                builder: (context, snapshot) {

                  int count = 0;

                  if(snapshot.hasData){
                    count = snapshot.data!.length;
                  }

                  return Text(
                    '일정 $count개',
                    style: textStyle,
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}


