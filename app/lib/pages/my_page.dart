import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyPage extends StatefulWidget {
  MyPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin{

  bool isReadOnly=true;

  var _wishList='0';
  var _footprint='0';
  var _fontSizeUp=15.0;

  TextEditingController address1;
  TextEditingController address2;
  TextEditingController address3;

  List<MaterialButton> buttons;

  String buttonText="修改地址";

  String oldAddress1="";
  String oldAddress2="";
  String oldAddress3="";

  List<MaterialButton> loginButton;

  MaterialButton materialButton;

  @override
  void initState() {

    super.initState();

    address1=new TextEditingController();
    address2=new TextEditingController();
    address3=new TextEditingController();

    loginButton=[
      MaterialButton(
        color: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),),
        child: Text("登陆",style: TextStyle(color:Colors.white,)),
        onPressed: ()async{
          var s=await Navigator.of(context).pushNamed("LoginView");
          if (s=="T"){
            showDialog(
                context: context,
                builder: (context) {
                  return new AlertDialog(
                    content: new SingleChildScrollView(
                      child: new Column(
                        children: <Widget>[
                          Text("登陆成功"),
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
            setState(() {
              materialButton=loginButton[1];
            });
          }
        }),
      MaterialButton(
        color: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),),
          child: Text("退出账号",style: TextStyle(color:Colors.white,)),
          onPressed: (){
            showDialog(
                context: context,
                builder: (context) {
                  return new AlertDialog(
                    content: new SingleChildScrollView(
                      child: new Column(
                        children: <Widget>[
                          Text("是否确认退出账号"),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        onPressed: () {
                          UserData.userID="-1";
                          UserData.isLogin=false;
                          Navigator.pop(context);
                          setState(() {
                            materialButton=loginButton[0];
                          });
                          },
                        child: new Text("确认"),
                      ),
                      new FlatButton(
                        onPressed: () {Navigator.pop(context);},
                        child: new Text("取消"),
                      ),
                    ],
                  );
                });
          }),
    ];

    if(UserData.isLogin==true){
      materialButton=loginButton[1];
    }else{
      materialButton=loginButton[0];
    }

    buttons=[
      MaterialButton(
        child: Text(buttonText,style: TextStyle(color:Colors.deepOrange,)),
        onPressed: (){
          if(buttonText=="修改地址"){
            setState(() {
              isReadOnly=false;
              buttonText="确认修改";
              buttons.add(MaterialButton(
                child: Text("取消",style: TextStyle(color:Colors.deepOrange,)),
                onPressed: (){
                  setState(() {
                    isReadOnly=true;
                    buttons.removeAt(1);
                  });
                  address1.text=oldAddress1;
                  address2.text=oldAddress2;
                  address3.text=oldAddress3;
                },
              ));
            });
          }else{
            showDialog(
                context: context,
                builder: (context){
                  return new AlertDialog(
                    title: new Text("提示信息"),
                    content: new Text("是否确定修改地址？"),
                    actions: <Widget>[
                      new FlatButton(child: new Text("确定"),onPressed: (){
                        Navigator.of(context).pop();
                      }),
                      new FlatButton(child: new Text("取消"),onPressed: (){
                        setState(() {
                          buttonText="修改地址";
                          buttons=[buttons[0]];
                          _editAddress();
                        });
                        Navigator.of(context).pop();
                      }),
                    ],
                  );
                });
          }
        },
      )
    ];
    _initFunc();

  }

  Widget build(BuildContext context) {

    if(UserData.isLogin==false){
      materialButton=loginButton[0];
    }else{
      materialButton=loginButton[1];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UserData.userName + "的主页",style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.format_list_bulleted),
            onPressed: (){

            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15,top: 10),
                child: Text("我的地址:",style: TextStyle(fontSize: 20,color: Colors.deepOrange),),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: SizedBox(
                    height: 200,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13.0)),),
                      child: Column(
                        children: <Widget>[
                          addressEditInput(address1,1),
                          addressEditInput(address2,2),
                          addressEditInput(address3,3),
                        ],
                      ),
                    )
                ),
              ),
              Column(
                  children:<Widget>[
                    Column(
                      children: buttons,
                    ),
                    materialButton
                  ]
              )
            ]
        )
      ),
        persistentFooterButtons:<Widget>[
          OutlineButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),),
            borderSide: BorderSide(color: Colors.deepOrange,width: 1.0),
            onPressed: (){
              if(UserData.isLogin==false){
                return;
              }
              Navigator.of(context).pushNamed("WishListPage");},
            color: Colors.deepOrange,
            textColor: Colors.deepOrange,
            child: Text(
              '愿望清单('+_wishList+")",
              style: new TextStyle(
                fontSize: _fontSizeUp,
                color: Colors.deepOrange,
              ),
            ),
          ),
          OutlineButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),),
            borderSide: BorderSide(color: Colors.deepOrange,width: 1.0),
            onPressed: (){
              if(UserData.isLogin==false){
                return;
              }
              Navigator.of(context).pushNamed("getFootprintPage");
            },
            color: Colors.deepOrange,
            textColor: Colors.deepOrange,
            child: new Text(
              '足迹('+_footprint+")",
              style: new TextStyle(
                fontSize: _fontSizeUp,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ]
    );
  }

  Future<dynamic> _initFunc() async {

    if(UserData.userID=="-1"){
      return;
    }

    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getMyPage"],
          body:{
            'type':'getMyPage',
            'userID': UserData.userID,
          });
      if(response.body.length!=0) {

        //wishlist@footprint@address1#address2

        var results=response.body.split("@");

        var addresses=results[2].split("#");

        setState(() {
          _wishList=results[0];
          _footprint=results[1];
          try {
            address1.text = addresses[0];
            oldAddress1=addresses[0];
          }catch(e){
          //do nothing
          }
          try {
            address2.text = addresses[1];
            oldAddress2=addresses[1];
          }catch(e){
            //do nothing
          }
          try {
            address3.text = addresses[2];
            oldAddress3=addresses[2];
          }catch(e){
            //do nothing
          }
        });
      }
    }
    catch (e){
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  // ignore: missing_return
  Future<void> _onRefresh() {
    _initFunc();
  }

  Widget addressEditInput(TextEditingController textEditingController,int i){
    return new Theme(
        data: new ThemeData(primaryColor: Colors.deepOrangeAccent, hintColor: Colors.deepOrange),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
          child: new Stack(
            alignment: Alignment(1.0, 1.0),
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Expanded(
                      child: new TextField(
                        textAlign: TextAlign.center,
                        readOnly: isReadOnly,
                        controller: textEditingController,
                        decoration: InputDecoration(
                            labelText: "地址"+i.toString(),
                            contentPadding: EdgeInsets.all(15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                        ),
                      )
                  ),
                ],
              ),
            ],
          ) ,
        )
    );
  }

  _editAddress() async{
    var client = new http.Client();
    try {
      var addresses="";
      if(address1.text==""&&address2.text==""&&address3.text==""){
        return;
      }
      if(address1.text!=""){
        addresses=address1.text;
      }
      if(address2.text!=""){
        addresses=addresses+"#"+address2.text;
      }
      if(address3.text!=""){
        addresses=addresses+"#"+address3.text;
      }

      var response = await client.post(NetWork.addressList["getAddress"],
          body:{
            'type':'editAddress',
            'userID': UserData.userID,
            'order':addresses
          });
      if(response.body.length!=0) {
        oldAddress1=address1.text;
        oldAddress2=address2.text;
        oldAddress3=address3.text;
        showDialog(
            context: context,
            builder: (context){
              return new AlertDialog(
                title: new Text("提示信息"),
                content: new Text("修改地址成功"),
                actions: <Widget>[
                  new FlatButton(child: new Text("确定"),onPressed: (){
                    Navigator.of(context).pop();
                  }),
                ],
              );
            });
      }
    }
    catch (e){
      print(e.toString());
    }
    finally {
      client.close();
    }
  }
}