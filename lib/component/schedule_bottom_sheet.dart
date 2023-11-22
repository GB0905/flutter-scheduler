import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:schedule_management/component/custom_text_field.dart';
import 'package:schedule_management/database/drift_database.dart';
import 'package:schedule_management/model/category_color.dart';
import 'package:schedule_management/const/colors.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.scheduleId,
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
          future: widget.scheduleId == null
              ? null
              : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
          builder: (context, snapshot) {

            if(snapshot.hasError){
              return Center(
                child: Text('일정을 불러올 수 없습니다.'),
              );
            }

            // FutureBuilder가 처음 실행됐고 로딩중 일때
            if(snapshot.connectionState != ConnectionState.none && //waiting으로 하면 매번 로딩할 때 마다 로딩을 보여줘서 none으로 처리함
                !snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // FutureBuilder가 실행되고 값이 있는데 한번도 startTime이 설정되지 않았을 때
            if(snapshot.hasData && startTime == null){
              startTime = snapshot.data!.startTime;
              endTime = snapshot.data!.endTime;
              content = snapshot.data!.content;
              selectedColorId = snapshot.data!.colorId;
            }

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5 + bottomInset,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                    child: Form(
                      key: formKey, //컨트롤러 역할
                      //autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ScheduleTimeSetting(
                            onStartSaved: (String? val) {
                              startTime = int.parse(val!);
                            },
                            onEndSaved: (String? val) {
                              endTime = int.parse(val!);
                            },
                            startInitialValue: startTime?.toString() ?? '',
                            endInitialValue: endTime?.toString() ?? '',
                          ),
                          SizedBox(height: 16.0),
                          _ScheduleContent(
                            onSaved: (String? val) {
                              content = val;
                            },
                            initialValue: content ?? '',
                          ),
                          SizedBox(height: 16.0),
                          // DB에서 기반하여 색깔 값 가져오기
                          // 비동기로 CategoryColor 가져오기 위해 FutureBuilder 사용
                          // Future를 사용하게 되면 미래의 잠재적인 값을 결정하게 되고 정보를 불러오는 동안 어떤걸 보여줄지 선택 가능
                          // 데이터를 받아올 때까지 앱에서는 정보를 언제 다 받는지 알수가 없다. 그렇기 때문에 future의 상태를 확실히 확인하는 과정을 거쳐야함
                          // 즉, DB를 불러올때 내용이 없으면 빈 리스트를 보여주고 내용이 있으면 색깔을 보여줌
                          FutureBuilder<List<CategoryColor>>(
                            // GetIt을 사용해 Dependency Injection으로 LocalDatabase가져오기
                              future: GetIt.I<LocalDatabase>().getCategoryColors(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    selectedColorId == null &&
                                    snapshot.data!.isNotEmpty) {
                                  selectedColorId = snapshot.data![0].id;
                                }
                                return _ColorPicker(
                                  colors: snapshot.hasData ? snapshot.data! : [],
                                  selectedColorId: selectedColorId, // 선택한 색깔의 id
                                  colorIdSetter: (int id){ // 선택한 색깔의 id를 받아옴
                                    setState(() {
                                      selectedColorId = id;
                                    });
                                  },
                                );
                              }),
                          SizedBox(height: 8.0),
                          _SaveButton(
                            onPressed: onSavePressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  void onSavePressed() async {
    // formKey는 생성을 했는데
    // Form 위젯과 결합을 안했을때
    if (formKey.currentState == null) {
      return;
    }
    // formKey.currentState!.validate()는 formKey.currentState가 null이 아닐때만 실행
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // startTime이 endTime보다 크거나 같으면 시간 에러 보여줌
      if (startTime != null && endTime != null && startTime! - endTime! >= 0) {
        showDialog(
            context: context,
            barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('시간 설정 오류'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('종료 시간을 올바르게 설정해주세요.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
        print('시간 에러가 있습니다.');
      }
      // startTime이 endTime보다 작으면 저장
      else {
        // 스케줄 아이디가 널이면 새로 생성
        if(widget.scheduleId == null){
          await GetIt.I<LocalDatabase>().createSchedule(
              SchedulesCompanion(
                date: Value(widget.selectedDate),
                startTime: Value(startTime!),
                endTime: Value(endTime!),
                content: Value(content!),
                colorId: Value(selectedColorId!),
              )
          );
        }
        // 스케줄 아이디가 널이 아니면 업데이트
        else {
          await GetIt.I<LocalDatabase>().updateScheduleById(
            widget.scheduleId!,
            SchedulesCompanion(
              date: Value(widget.selectedDate),
              startTime: Value(startTime!),
              endTime: Value(endTime!),
              content: Value(content!),
              colorId: Value(selectedColorId!),
            ),
          );
        }
        Navigator.of(context).pop();
      }
    } else {
      print('에러가 있습니다.');
    }
  }
}

class _ScheduleTimeSetting extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _ScheduleTimeSetting({
    required this.onStartSaved,
    required this.onEndSaved,
    required this.startInitialValue,
    required this.endInitialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작 시간',
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: CustomTextField(
            label: '종료 시간',
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
      ],
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _ScheduleContent({
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '일정 내용',
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}
// 함수 선언부를 정의해주는 것
typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors; //외부에서 색 받기
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 10.0,
      children: colors
          .map(
            (e) => GestureDetector(
          onTap: (){
            colorIdSetter(e.id); // 탭할 때 선택한 색깔의 id를 넘겨줌
          },
          child: renderColor(
              e,
              selectedColorId == e.id
          ),
        ),
      )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}', // 헥스 코드 앞에 FF 붙여줌
            radix: 16, //정수 값 16진수로 바꾸기
          ),
        ),
        border: isSelected ? Border.all(
            color: Colors.black,
            width: 2.5
        ) : null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}
