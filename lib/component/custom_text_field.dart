import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:schedule_management/const/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  // 참 = 시간, 거짓 = 내용
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime)
          Expanded(
            child: renderTextField(),
          ),
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,
      // null이 return 시 에러 X
      // 에리 있으면 에러를 String 값으로 return
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '값을 입력해주세요.';
        }

        if (isTime) {
          int time = int.parse(val!);

          if (val.length > 2) {
            return '2자 이하로 입력해주세요.';
          }
          if(time < 0){
            return '0시 이상으로 입력해주세요.';
          }
          if(time > 24){
            return '24시 이하로 입력해주세요.';
          }
        } else {
          if (val.length > 500) {
            return '500자 이하로 입력해주세요.';
          }
        }
        return null;
      },
      cursorColor: Colors.grey,
      expands: isTime ? false : true,
      maxLines: isTime ? 1 : null,
      initialValue: initialValue,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      inputFormatters: isTime
          ? [
        FilteringTextInputFormatter.digitsOnly,
      ]
          : [],
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null,
      ),
    );
  }
}
