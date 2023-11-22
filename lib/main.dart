import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:schedule_management/screen/home_screen.dart';
import 'package:schedule_management/database/drift_database.dart';
import 'package:schedule_management/screen/loading_screen.dart';

const DEFAULT_COLORS = [
  // 빨강
  'F44336',
  // 주황
  'FF9800',
  // 노랑
  'FFEB3B',
  // 초록
  '4CAF50',
  // 파랑
  '2196F3',
  // 남
  '3F51B5',
  // 보라
  '9C27B0',
];

void main() async {
  // 초기화 확인 => runApp 실행전 어떤 코드를 실행해야할 경우
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  // db 기능
  final database = LocalDatabase();

  // GetIt은 싱글톤 패턴을 사용하는 라이브러리
  // GetIt이라는 클래스를 사용해서 어디에서든 데이터베이스를 가져올 수 있음.
  GetIt.I.registerSingleton<LocalDatabase>(database);

  final colors = await database.getCategoryColors();

  if(colors.isEmpty){
    for(String hexCode in DEFAULT_COLORS){
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode),
        ),
      );
    }
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: LoadingScreen(),
    ),
  );
}
