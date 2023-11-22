import 'package:drift/drift.dart';
// 드리프트가 알아서 SQlite와 소통해서 테이블 생성해줌
class Schedules extends Table{


  // ID, CONTENT, DATE, STARTTIME, ENDTIME, COLORID, CREATEDAT
  // '1', '일정123', 2023-11-14, 12, 14, 1, 디폴트 값으로 지금 시간 받아옴

  // PRIMARY KEY (자동 생성)
  IntColumn get id => integer().autoIncrement()();

  // 내용
  TextColumn get content => text()();

  // 일정 날짜
  DateTimeColumn get date => dateTime()();

  // 시작 시간
  IntColumn get startTime => integer()();

  // 종료 시간
  IntColumn get endTime => integer()();

  // 카테고리 색상 Table ID
  IntColumn get colorId => integer()();

  // 생성 날짜
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now(),)();
}