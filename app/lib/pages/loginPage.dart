import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/pages/showAlertDialog.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;


String sex;
String job;
String area;

String loginText="登陆";
String reText="注册";

bool state=true;

class LoginState extends StatefulWidget {

  const LoginState() :super();

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State with SingleTickerProviderStateMixin{

  TabController tabController;

  List<String> sexList;
  List<String> jobList;
  List<String> areaList;


  @override
  void initState(){
    super.initState();

    sex="男";
    job="个体经营/服务";
    area="0";
    sexList=["男","女"];
    jobList=["个体经营/服务","公务员","公司职员","医务人员","学生","教职工"];
    areaList=["0","1","2","3","4","5"];

    tabController=new TabController(length: 2, vsync: this);
    tabController.addListener((){
      userController.clear();
      passController.clear();
      ageController.clear();
    });
  }

  @override
  void dispose() {

    tabController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("登录"),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
            tabs:<Widget>[
              Tab(text:"登陆"),
              Tab(text: "注册",)
            ]
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          ListView(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  loginUserEditInput(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: new Stack(
                      alignment: Alignment(1.0, 1.0),
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Padding(
                                padding: EdgeInsets.all(5.0),
                                child: new Icon(Icons.keyboard)
                            ),
                            new Expanded(
                                child: new TextField(
                                  obscureText: state,
                                  controller: passController,
                                  decoration: new InputDecoration(
                                      hintText: "请输入密码"
                                  ),
                                )
                            ),
                          ],
                        ),
                        new IconButton(icon: new Icon(Icons.remove_red_eye), onPressed: (){
                          setState(() {
                            state=!state;
                          });
                        })
                      ],
                    ),
                  ),
                  loginButton(context),
                ],
              )
            ],
          ),
          ListView(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  loginUserEditInput(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: new Stack(
                      alignment: Alignment(1.0, 1.0),
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Padding(
                                padding: EdgeInsets.all(5.0),
                                child: new Icon(Icons.keyboard)
                            ),
                            new Expanded(
                                child: new TextField(
                                  obscureText: state,
                                  controller: passController,
                                  decoration: new InputDecoration(
                                      hintText: "请输入密码"
                                  ),
                                )
                            ),
                          ],
                        ),
                        new IconButton(icon: new Icon(Icons.remove_red_eye), onPressed: (){
                          setState(() {
                            state=!state;
                          });
                        })
                      ],
                    ),
                  ),
                  ageEditInput(),
                  DropdownButton<String>( //sex
                    value:sex,
                    onChanged: (String newType){
                      setState(() {
                        sex=newType;
                      });
                    },
                    items: sexList.map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                          value:value,
                          child:Text(value)
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>( //job
                    value:job,
                    onChanged: (String newType){
                      setState(() {
                        job=newType;
                      });
                    },
                    items: jobList.map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                          value:value,
                          child:Text(value)
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>( //area
                    value:area,
                    onChanged: (String newType){
                      setState(() {
                        area=newType;
                      });
                    },
                    items: areaList.map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                          value:value,
                          child:Text(value)
                      );
                    }).toList(),
                  ),
                  registerButton(context),
                ],
              )
            ],
          ),
        ],
      )
      //new LoginView(),
    );
  }
}

TextEditingController userController   = new TextEditingController();
TextEditingController passController   = new TextEditingController();
TextEditingController ageController   = new TextEditingController();

class  LoginView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Column(
          children: <Widget>[
            loginUserEditInput(),
            loginPassEditInput(),
            loginButton(context),
          ],
        )
      ],
    );
  }
}

Widget loginUserEditInput(){
  return new Padding(
    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
    child: new Stack(
      alignment: Alignment(1.0, 1.0),
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.all(5.0),
              child: new Icon(Icons.person)
            ),
            new Expanded(
                child: new TextField(
                  controller: userController,
                  decoration: new InputDecoration(
                      hintText: "请输入用户名"
                  ),
                )
            ),
          ],
        ),
        new IconButton(icon: new Icon(Icons.clear), onPressed: (){
          userController.clear();
        })
      ],
    ) ,
  );
}

Widget loginPassEditInput(){
  return new Padding(
    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
    child: new Stack(
      alignment: Alignment(1.0, 1.0),
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.all(5.0),
              child: new Icon(Icons.keyboard)
            ),
            new Expanded(
                child: new TextField(
                  obscureText: state,
                  controller: passController,
                  decoration: new InputDecoration(
                      hintText: "请输入密码"
                  ),
                )
            ),
          ],
        ),
        new IconButton(icon: new Icon(Icons.remove_red_eye), onPressed: (){
          state=!state;
        })
      ],
    ),
  );
}

Widget ageEditInput(){
  return new Padding(
    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
    child: new Stack(
      alignment: Alignment(1.0, 1.0),
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.all(5.0),
              child: new Icon(Icons.tag_faces)
            ),
            new Expanded(
                child: new TextField(
                  controller: ageController,
                  decoration: new InputDecoration(
                      hintText: "请输入年龄"
                  ),
                )
            ),
          ],
        ),
        new IconButton(icon: new Icon(Icons.clear), onPressed: (){
          userController.clear();
        })
      ],
    ) ,
  );
}

Widget loginButton(BuildContext context){
  return new Container(
    width: 300.0,
    padding: EdgeInsets.fromLTRB(30.0,15.0 , 30.0, 0.0),
    child: new Card(
      elevation: 10.0, // 正常情况下浮动的距离
      color: Colors.deepOrange,
      child: new FlatButton(
        color: Colors.deepOrange,
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Text("登录",
            style: new TextStyle(
                color: Colors.white,
                fontSize: 16.0
            ),),
        ),
        onPressed: (){
          _checkLoginSub(context);
        },
      ),
    ),
  );
}

Widget registerButton(BuildContext context){
  return new Container(
    width: 300.0,
    padding: EdgeInsets.fromLTRB(30.0,15.0 , 30.0, 0.0),
    child: new Card(
      elevation: 10.0, // 正常情况下浮动的距离
      color: Colors.deepOrange,
      child: new FlatButton(
        color: Colors.deepOrange,
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Text("注册",
            style: new TextStyle(
                color: Colors.white,
                fontSize: 16.0
            ),),
        ),
        onPressed: (){
          if(reText=="注册"){
            _checkRegisterSub(context);
          }else if(reText=="注册成功，点击返回"){
            Navigator.pop(context,"T");
          }
        },
      ),
    ),
  );
}

Future _checkLoginSub(BuildContext context) async {
  String msgStr = "";
  if(!userController.text.isNotEmpty){
    msgStr = "用户账号不能为空";
  }else  if(!passController.text.isNotEmpty){
    msgStr = "用户密码不能为空";
  }

  if(msgStr != ''){
    showDialog(
        context: context,
        builder: (context){
          return new AlertDialog(
            title: new Text("提示信息"),
            content: new Text(msgStr),
            actions: <Widget>[
              new FlatButton(child: new Text("确定"),onPressed: (){
                Navigator.of(context).pop();
              }),
            ],
          );
        }
    );
  }else{
    //向服务器请求登陆
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["login"],
          body: {
            'type': 'login',
            'userName': userController.text,
            'userpassword': generateMd5(passController.text),
          });
      if (response.body.length!=0){
        var result=response.body.split("&");
        print(result);
        if (result[0]=="T"){
          UserData.isLogin=true;
          UserData.userID=result[1];
          UserData.userName=userController.text;
          UserData.toFile(generateMd5(passController.text));
          print('signsucceed');
          Navigator.pop(context,"T");
        }
        else if (result[0]=='F'){
          shower(context,"账号或密码错误");
        }else{

        }
      }
    }
    catch (e){
      shower(context,"请检查网络");
      print(e.toString());
    }
    finally{
      client.close();
    }
  }
}

Future _checkRegisterSub(BuildContext context) async {
  String msgStr = "";
  if(!userController.text.isNotEmpty){
    msgStr = "用户账号不能为空";
  }else  if(!passController.text.isNotEmpty){
    msgStr = "用户密码不能为空";
  }else  if(!ageController.text.isNotEmpty||int.parse(ageController.text)<=0||int.parse(ageController.text)>=150){
    msgStr = "请输入年龄";
  }

  if(msgStr != ''){
    showDialog(
        context: context,
        builder: (context){
          return new AlertDialog(
            title: new Text("提示信息"),
            content: new Text(msgStr),
            actions: <Widget>[
              new FlatButton(child: new Text("确定"),onPressed: (){
                Navigator.of(context).pop();
              }),
            ],
          );
        }
    );
  }else{
    //向服务器请求注册
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["login"],
          body: {
            'type': 'register',
            'userName': userController.text,
            'userpassword': generateMd5(passController.text),
            'data': sex+"#"+job+"#"+area+"#"+ageController.text
          });
      if (response.body.length!=0){
        utf8.encode("");
        var result=response.body.split("&");
        if (result[0]=="T"){
          UserData.isLogin=true;
          UserData.userID=result[1];
          UserData.userName=userController.text;

          UserData.toFile(generateMd5(passController.text));

          print('signsucceed');
          Navigator.pop(context,"T");
        }
        else{
          shower(context,"用户名已存在");
        }
      }
    }
    catch (e){
      print(e.toString());
      shower(context,"请检查网络");
    }
    finally{
      client.close();
    }
  }
}

void shower(BuildContext context,String text) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {Navigator.pop(context);},
              child: new Text("确认"),
            ),
          ],
        );
      });
}

// md5 加密
String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  // 这里其实就是 digest.toString()
  return hex.encode(digest.bytes);
}