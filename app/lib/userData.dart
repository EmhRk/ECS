import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserData{
  static String userID="-1";
  static String userName="访客";
  static bool isLogin=false;

  static toFile(String password) async {

    if(isLogin==false){
      return;
    }

    //获取文件路径
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var appDocPath = appDocDir.path;

    String obj=userID+"&"+userName+"&"+password;

    try {
      //从文件中获取用户信息
      File fileAccount = new File('$appDocPath/account.data');
      fileAccount.writeAsString(obj);
    }on FileSystemException{
      print('Error:Data File Not Found');
    }
  }

}


class Share{
  static int downTabIndex=0;//下方导航栏选择Index
}