import 'dart:io';
import 'package:e_commerce_system/pages/CommentPage(deserted).dart';
import 'package:e_commerce_system/pages/loginPage.dart';
import 'package:e_commerce_system/pages/mainPage.dart';
import 'package:e_commerce_system/pages/my_page.dart';
import 'package:e_commerce_system/pages/pay_page.dart';
import 'package:e_commerce_system/pages/product_page.dart';
import 'package:e_commerce_system/pages/searchPage.dart';
import 'package:e_commerce_system/pages/search_result.dart';
import 'package:e_commerce_system/pages/shop_cart_page.dart';
import 'package:e_commerce_system/pages/showAlertDialog.dart';
import 'package:e_commerce_system/pages/testpage.dart';
import 'package:e_commerce_system/pages/wishListPage.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:e_commerce_system/pages/footprintPage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:e_commerce_system/network.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Home Page',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      routes:{
        "SearchPage":(context)=>SearchPage(),
        "searchResultPage":(context)=>SearchResultPage(),
        "productPage":(context)=>ProductPage(),
        "payPage":(context)=>PayPage(),
        "LoginView":(context)=>LoginState(),
        "WishListPage":(context)=>WishListPage(),
        "getFootprintPage":(context)=>FootprintPage(),
        "getCommentPage":(context)=>CommentPage(),
      } ,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

  List<Widget> pageList;

  Widget myPage;

  //类别数目
  var pageTabs=20;

  bool isGettingA=false;

  NetWork netWork=new NetWork();

  //储存上方广告位url
  List<Image> adImageList;
  List<String> adIdList;

  //记录网络是否错误
  bool networkError=false;

  //扫描结果
  String scanResult = "";

  String tempPath;//临时文件路径
  String appDocPath;//文件路径

  String userName;
  String userID;
  String password;

  bool isLogin=false;

  @override
  void initState() {

    //异步调用函数，获取文建路径与临时文件路径以及登陆信息
    //_initUserData();

    super.initState();

    //在此处把5个页面推入pageList
    pageList=[

      //mainPage
      new MainPage(),

      //sortPage
      new NewRoute(),

      //MessagePage
      new NewRoute(),

      //shopCartPage
      new ShoppingCartPage(),

      //myPage
      new MyPage(),

    ];

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: pageList[Share.downTabIndex],
      bottomNavigationBar:  BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon:Icon(Icons.home,size: 20,), title:Text("首页")),
          BottomNavigationBarItem(icon:Icon(Icons.list,size: 20,), title:Text("分类")),
          BottomNavigationBarItem(icon:Icon(Icons.message,size: 20,), title:Text("消息")),
          BottomNavigationBarItem(icon:Icon(Icons.shopping_cart,size: 20,), title:Text("购物车")),
          BottomNavigationBarItem(icon:Icon(Icons.person,size: 20,), title:Text("我的主页")
          ),
        ],
        type: BottomNavigationBarType.fixed,
          //默认选中首页
        currentIndex: Share.downTabIndex,
        onTap: _onItemTap,
      ),
    );
  }

  void _onItemTap(int index) {
    if(mounted){
      setState(() {
        Share.downTabIndex=index;
      });
    }
  }

}