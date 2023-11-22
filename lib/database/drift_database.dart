// SQLite와 플러터 프로젝트 연결
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:schedule_management/model/schedule_with_category.dart';
import 'package:schedule_management/model/category_color.dart';
import 'package:schedule_management/model/schedule.dart';

// private 값도 불러올 수 있음.
// 같은 파일을 2개로 나눈 느낌
// 코드 제너레이션 pub run build_runner build
// 실행시 자동 생성됨 (".g"가 패턴)
part 'drift_database.g.dart';

// 드리프트가 알아서 SQlite와 소통해서 테이블 생성해줌
@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
// drift가 자동으로 _$LocalDatabase 생성 ("_$"가 패턴)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // Create 데이터 베이스에 입력하는 것 (일정과 카테고리 삽입)
  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);
  
  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);


  // select
  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();
  
  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle(); // getSingle로 하나만 가져옴


  // update => id가 일치하는 것을 업데이트
  Future<int> updateScheduleById(int id,SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  // delete => id가 일치하는 것을 삭제
  // ..은 앞의 결과를 그대로 반환 즉, 함수가 실행이 된 대상이 반환
  // where이 아닌 delete에 go 실행 (delete.go로 삭제)
  Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go(); //삭제한 id의 int 값 리턴 받을 수 있지만 안 받을 것임


  // watch는 스트림을 반환
  // 스트림은 데이터가 변경될 때 마다 알려줌 (실시간으로 업데이트)
  // 선택한 날짜만 가져오기
  Stream<List<ScheduleWithCategory>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
      // join으로 colorId를 가져오는 것
    ]);

    query.where(schedules.date.equals(date));

    query.orderBy(
      [
        // 시간을 오름차순으로 정렬
        OrderingTerm.asc(schedules.startTime),
      ],
    );

    // rows를 매핑 받아 row를 매핑
    return query.watch().map(
          (rows) => rows.map(
                (row) => ScheduleWithCategory(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
          ).toList(),
        );
  }

  // 버전 관리
  // 변경할 때 마다 숫자 올려주면 됨
  @override
  int get schemaVersion => 1;
}

// lazy database는 실제로 db를 사용할 때 연결을 해줌
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory(); // 앱 전용으로 사용하는 로컬 폴더위치를 가져옴
    final file = File(p.join(dbFolder.path, 'db.sqlite')); // 경로를 합쳐줌
    return NativeDatabase(file); // NativeDatabase는 sqlite를 사용하는 것
  });
}
