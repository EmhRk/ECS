import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopPage extends StatefulWidget {
  ShopPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ShopPageState createState() => _ShopPageState();
  }

  class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin{

  var pageTabs=5;
  var _currentIndex=1;

  //controller
  ScrollController _scrollController;

  TextEditingController _textEditingController;

  List<Widget> _bodyData;

  int _page = 0; //选中下标
  //此处定义一个存放GridView数据的变量

  @override
  void initState() {
  super.initState();

  _scrollController=ScrollController();
  _textEditingController=TextEditingController();

  _bodyData=[Text('hi'), Text('hi'), Text('hi'), Text('hi'), Text('hi'), Text('hi')];

  _scrollController.addListener(() {
  if (_scrollController.position.pixels ==
  _scrollController.position.maxScrollExtent) {
  print('滑动到了最底部${_scrollController.position.pixels}');

  getMoreData();
  }
  });

  }

  Widget build(BuildContext context) {

  return Scaffold(
  /*appBar: SearchAppBarWidget(
  //focusNode: _focusNode,
  controller: _textEditingController,
  elevation: 2.0,

  leading: IconButton(
  icon: Icon(Icons.arrow_back ),
  ),
  inputFormatters: [
  LengthLimitingTextInputFormatter(50),
  ],
  onEditingComplete: () => _checkInput()
  ),*/
  body: Column(
  children: <Widget>[
  Expanded(
  child:RefreshIndicator(
  onRefresh: _onRefresh,
  child: ListView(
  controller:_scrollController,
  children:_bodyData,
  ),
  )
  )
  ]
  ),
  bottomNavigationBar: BottomNavigationBar( // 底部导航
  onTap: _onItemTapped,
  currentIndex: _currentIndex,
  items: <BottomNavigationBarItem>[
  BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
  BottomNavigationBarItem(icon: Icon(Icons.business), title: Text('全部宝贝')),
  BottomNavigationBarItem(icon: Icon(Icons.school), title: Text('店铺详情')),
  ],
  fixedColor: Colors.blue,
  ),
  );
  }

  void _onItemTapped(int index) {
    if(mounted){
      setState(() {
        _currentIndex=index;
      });
    }
  }

  _checkInput() {

  }

  Future <Null> _onRefresh() async {

    print('下拉刷新开始,page = $_page');

    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _bodyData.add(Text('???'));
      });
    });
  }

  void getMoreData() {}
}