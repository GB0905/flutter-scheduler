import 'package:drift/drift.dart' hide Column; //복수 참조되서 hide로 Column 제거
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:schedule_management/database/drift_database.dart';
import 'package:schedule_management/model/schedule_with_category.dart';
import 'package:schedule_management/component/calendar.dart';
import 'package:schedule_management/component/schedule_bottom_sheet.dart';
import 'package:schedule_management/component/schedule_card.dart';
import 'package:schedule_management/component/today_banner.dart';
import 'package:schedule_management/const/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Timezone(시차) 에러로 인해 UTC로 변경
  //즉, 로컬 시간과 UTC의 시간차로 인한 오류가 계속 발생하므로
  //따라서 시작할 때 UTC 기준으로 selectedDay 변경 (일반화)
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [

            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDay: selectedDay,
            ),
            SizedBox(height: 8.0),
            _ScheduleList(
              selectedDate: selectedDay,
            ),
          ],
        ),
      ),
    );
  }

  // 등록 버튼
  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) {
              return ScheduleBottomSheet(
                selectedDate: selectedDay,
              );
            }
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(Icons.edit),
    );
  }

  // 선택된 날짜를 저장하는 함수
  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });
  }
}

// 일정 목록
class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;

  const _ScheduleList({required this.selectedDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<ScheduleWithCategory>>(
            stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator()); // 로딩화면
              }

              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Text('등록된 일정이 없습니다.'),
                );
              }

              // 모든 일정을 다 불러오기 때문에 메모리 문제 발생 -> 필요한 날짜의 데이터만 불러오게 수정
              // List<Schedule> schedules = [];
              // if(snapshot.hasData){
              //   schedules = snapshot.data!
              //       .where((element) => element.date.toUtc() == selectedDate)
              //       .toList();
              // }
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8.0);
                },
                itemBuilder: (context, index) {
                  final scheduleWithCategory = snapshot.data![index];

                  return Dismissible(
                    key: ObjectKey(scheduleWithCategory.schedule.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.red,
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (DismissDirection direction) {
                      GetIt.I<LocalDatabase>().removeSchedule(
                        scheduleWithCategory.schedule.id,
                      );
                    },
                    child: GestureDetector(
                      onTap: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (_) {
                              return ScheduleBottomSheet(
                                selectedDate: selectedDate,
                                scheduleId: scheduleWithCategory.schedule.id,
                              );
                            }
                        );
                      },
                      child: ScheduleCard(
                        startTime: scheduleWithCategory.schedule.startTime,
                        endTime: scheduleWithCategory.schedule.endTime,
                        content: scheduleWithCategory.schedule.content,
                        color: Color(
                          // string 값을 헥스코드로
                          int.parse('FF${scheduleWithCategory.categoryColor.hexCode}',
                              radix: 16),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
        ),
      ),
    );
  }
}
