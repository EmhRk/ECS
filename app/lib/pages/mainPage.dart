import 'dart:io';

import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/pages/searchPage.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> with SingleTickerProviderStateMixin{

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

  bool isLogin=false;

  //controller
  ScrollController _scrollController;//下方推荐页滑动控制器
  PageController _pageController;//上方首页推薦页滑动控制器
  TabController _tabController;//类别的Tab页面控制器

  //下方推荐页
  List<String> _gridViewDataId;
  List<Widget> _gridViewData;

  int _tabPage = 0; //上方Tab页面选中的Tab页,0位为首页

  bool isLoading = false;//是否正在请求新数据
  bool showMore = false;//是否显示底部加载中提示
  bool offState = false;//是否显示进入页面时的圆形进度条

  @override
  void initState() {

    super.initState();

    _gridViewData=[
      SizedBox(
        height: 360.0,  //设置高度
        child: Card(),
      ),
      SizedBox(
        height: 360.0,  //设置高度
        child: Card(),
      ),
    ];

    //初始化控制器
    _tabController=TabController(length: pageTabs, vsync: this);
    _scrollController=ScrollController();
    _pageController=PageController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部${_scrollController.position.pixels}');

        getMoreData();

      }
    });

    _gridViewDataId=[""];

    //初始化上方广告位两个List

    adImageList=[
      Image(
          image:AssetImage('images/avatar.png')
      )
    ];

    _initUserData();

    //获取首次进入首页
    //获取上方活动推送页活动,获取下方推薦商品信息
    //_getMainPage();

  }

  @override
  void dispose() {
    super.dispose();

    //关闭控制器
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();

    //
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
          leading: IconButton(
            icon: Icon(Icons.crop_free),
            //onPressed: scan,
          ),
          title: Text(""),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search,color: Colors.white,),
              onPressed: (){
                //Navigator.of(context).pushNamed("SearchPage");
                Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: SearchPage()));
                },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              //onPressed: ,
            )
          ],
      ),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context,bool boxIsScrolled){
            return <Widget>[
              SliverAppBar(
                pinned: false,
                floating: true,
                forceElevated: boxIsScrolled,
                expandedHeight: 200,
                flexibleSpace: Container(
                    child:PageView.builder(
                      itemBuilder: ((context,index){
                        return GestureDetector(
                            onTap: (){_onClickAd(index.toString(),context);},
                            child:adImageList[index]
                        );
                      }),
                      itemCount: adImageList.length,
                      scrollDirection: Axis.horizontal,
                      reverse: false,
                      controller: _pageController,
                      physics: PageScrollPhysics(parent: BouncingScrollPhysics()),
                    )
                ),
              )
            ];
          },
          body: Column(
              children: <Widget>[
                Row(
                    children:<Widget>[
                      Container(
                          color: Colors.white,
                          height: 38.0,
                          width: 300,
                          child: TabBar(
                            labelColor: Colors.deepOrange,
                            indicatorColor: Colors.deepOrangeAccent,
                            unselectedLabelColor: Colors.deepOrangeAccent,
                            isScrollable: true,
                            controller: _tabController,//需要实现下面页面的reload
                            onTap: (index){
                              if (mounted){
                                if(_tabPage!=index){
                                  print("Tab!");
                                  _tabPage=index;
                                  _getMainPage();
                                }
                              }
                            },
                            // pageTabs=5
                            tabs:<Widget>[
                              Tab(
                                text: "首页",
                              ),
                              Tab(
                                text: "数码",
                              ),
                              Tab(
                                text: "手机",
                              ),
                              Tab(
                                text: "男装",
                              ),
                              Tab(
                                text: "运动",
                              ),
                              Tab(
                                text: "生鲜",
                              ),
                              Tab(
                                text: "食品",
                              ),
                              Tab(
                                text: "母婴",
                              ),
                              Tab(
                                text: "女装",
                              ),
                              Tab(
                                text: "鞋靴",
                              ),
                              Tab(
                                text: "箱包",
                              ),
                              Tab(
                                text: "百货",
                              ),
                              Tab(
                                text: "家装",
                              ),
                              Tab(
                                text: "电器",
                              ),
                              Tab(
                                text: "内衣",
                              ),
                              Tab(
                                text: "饰品",
                              ),
                              Tab(
                                text: "美妆",
                              ),
                              Tab(
                                text: "洗护",
                              ),
                              Tab(
                                text: "车品",
                              ),
                              Tab(
                                text: "保健",
                              ),
                            ],
                          )),
                      Container(
                        width: 55,
                        height: 30,
                        child: Material(
                          color: Colors.deepOrange,
                          child: OutlineButton(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                            //minWidth: 0,
                            child: new Text(
                              "分类",
                              style: new TextStyle(
                                  color: Colors.white,
                                fontSize: 11.5,
                              ),
                            ),
                            onPressed: (){
                              setState(() {
                                Share.downTabIndex=1;
                              });},
                          ),
                        ),
                      )
                    ]
                ),
                Expanded(
                    child:RefreshIndicator(
                      onRefresh: _onRefresh,
                      child:GridView.builder(
                          controller: _scrollController,
                          itemCount: _gridViewData.length,
                          //SliverGridDelegateWithFixedCrossAxisCount 构建一个横轴固定数量Widget
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            //横轴元素个数
                              crossAxisCount: 2,
                              //纵轴间距
                              mainAxisSpacing: 20.0,
                              //横轴间距
                              crossAxisSpacing: 10.0,
                              //子组件宽高长度比例
                              childAspectRatio: 0.78
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            //Widget Function(BuildContext context, int index)
                            return _gridViewData[index];
                          })
                    )
                )
              ]
          )
      ),
    );
  }

  _getMainPage() async {

    //获取上方广告位
    print("userid:"+UserData.userID);
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getPage"],
          body:{
            'type':'getMainPage',
            'tabID':_tabPage.toString(),
            'userID': UserData.userID,
            'currentItemIndex':'0',
          });
      if(response.body.length!=0){
        setState(() {
          adImageList=[];
          adIdList=[];

          _gridViewData.clear();
          _gridViewDataId.clear();

          var result=response.body;
          print(result);
          List<String> results=result.split("&");
          var headAdd=results[0];
          var recommendAdd=results[1];

          //headAdd
          var headAdds=headAdd.split("@");
          for(int i=0;i<headAdds.length;i++){
            adIdList.add(headAdds[i].split("#")[0]);
            adImageList.add(Image(
              image:NetworkImage(
                headAdds[i].split("#")[1],
              ),
            ));
          }

          //add recommend page
          var recommendAdds=recommendAdd.split("@");
          for(int i=0;i<recommendAdds.length;i++){
            _gridViewDataId.add(recommendAdds[i].split("#")[0]);
            _gridViewData.add(
                GestureDetector(
                  onTap: (){_onClickOpenProPage(recommendAdds[i].split("#")[0],context);},
                  child: SizedBox(
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                        child: Container(
                            width: 200,
                            height: 600,
                            child:Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image(
                                    image: NetworkImage(
                                      recommendAdds[i].split("#")[3],
                                    ),
                                  ),
                                  //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    recommendAdds[i].split("#")[1],
                                    style: new TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    recommendAdds[i].split("#")[2],
                                    style: new TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 17
                                    ),
                                  ),
                                )
                              ],
                            )
                        )
                    ),
                  ),
                )
            );
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

  void getMoreData() async {

    print('上拉刷新开始');

    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getPage"],
          body: {
            'type': 'getMorePage',
            'tabID':_tabPage.toString(),
            'userID': UserData.userID,
            'currentItemIndex': _gridViewData.length.toString(),
          });
      if (response.body.length!=0){
        print(response.body);
        setState(() {
          var recommendAdd=response.body;
          var recommendAdds=recommendAdd.split("@");
          for(int i=0;i<recommendAdds.length;i++){
            _gridViewDataId.add(recommendAdds[i].split("#")[0]);
            _gridViewData.add(
                GestureDetector(
                  onTap: (){_onClickOpenProPage(recommendAdds[i].split("#")[0],context);},
                  child: SizedBox(
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                        child: Container(
                            width: 200,
                            height: 600,
                            child:Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image(
                                    image: NetworkImage(
                                      recommendAdds[i].split("#")[3],
                                    ),
                                  ),
                                  //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    recommendAdds[i].split("#")[1],
                                    style: new TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    recommendAdds[i].split("#")[2],
                                    style: new TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 17
                                    ),
                                  ),
                                )
                              ],
                            )
                        )
                    ),
                  ),
                )
            );
          }
        });
      }
    }
    catch (e){
      print(e.toString());
    }
    finally{
      client.close();
    }
  }


  _onClickOpenProPage(String proId,BuildContext context) {
    print("OnClickRecommend! "+proId);
    Navigator.of(context).pushNamed("productPage", arguments: proId+"&mainpage");
  }

  Future <Null> _onRefresh() async {

    print('下拉刷新开始');
    //also refresh the upper ads
    _getMainPage();
    setState((){});
  }

  _onClickAd(String id,BuildContext context) {
    print("OnClickAd! "+id);
  }

  //获取文件路径与临时文件路径
  _initUserData() async{
    //获取文件路径与临时文件路径
    Directory tempDir = await getTemporaryDirectory();
    tempPath = tempDir.path;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;

    //获取用户信息
    //获取ID，名称与密码
    try{
      //从文件中获取用户信息
      File fileAccount=new File('$appDocPath/account.data');
      String accountReader=await fileAccount.readAsString();
      List<String> account=accountReader.split("&");
      String userID=account[0];
      if(userID=="-1"){
        return;
      }
      String userName=account[1];
      String password=account[2];

      //用户信息验证
      var response= await http.post(NetWork.addressList['login'], body:  {'type':"login",'userName': userName, 'password':password});
      var result=response.body.split("&");

      if (result[0]=='T'){
        UserData.isLogin=true;
        UserData.userID=userID;
        UserData.userName=userName;
        print('signsucceed');
        _getMainPage();
      }
      else{
        //dataTimeOutDialog(context);
        print('DataTimeOutCalled');
        Navigator.of(context).pushNamed("LoginView");
      }
    }on FileSystemException{
      print('Error:Data File Not Found');
    }
  }
}