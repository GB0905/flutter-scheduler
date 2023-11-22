import 'dart:async';
import 'package:flutter/material.dart';

import 'package:schedule_management/screen/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    Timer(Duration(milliseconds: 2000), () {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomeScreen()
      )
      );
    });
  }

  // 로딩 화면
  @override
  Widget build(BuildContext context) {
    const String imageLogo = 'asset/image/Loading.png';

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor:1.0),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.3),
                Container(
                  child: Image.asset(
                    imageLogo,
                    // width: screenWidth * 0.2,
                    // height: screenHeight * 0.2,
                  ),
                ),
                Expanded(child: SizedBox()),
                Align(
                  child: Text("© Copyright 2023, WGO(일정 관리 도우미)",
                      style: TextStyle(
                        fontSize: screenWidth*( 14/360), color: Colors.grey[700],)
                  ),
                ),
                SizedBox( height: MediaQuery.of(context).size.height*0.0625,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
