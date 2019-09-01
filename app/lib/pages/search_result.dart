import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/pages/searchPage.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  //

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}


class ProInView{
  String proUrl;
  String proName;
  String proId;
  String proPrice;
}

class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin{

  String query;

  //产品list
  List<ProInView> proInViews;

  int count=1;
  double per=3.0;

  //优先方案
  String plan;

  bool firstIn=true;

  //搜索联想
  List<Widget> association;

  //controller
  ScrollController _scrollController;

  //此处定义一个存放GridView数据的变量

  @override
  void initState() {
    super.initState();

    plan="综合";

    proInViews=[];

    _scrollController=new ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部${_scrollController.position.pixels}');

        getMoreData();
      }
    });

  }

  @override
  dispose(){
    super.dispose();
    _scrollController.dispose();
  }

  Widget build(BuildContext context) {

    if(firstIn){
      //获取搜索的目标词语
      var args=ModalRoute.of(context).settings.arguments;

      query=args.toString();

      _getSearchResult();

      firstIn=false;
    }

    return Scaffold(
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){Navigator.pop(context);},
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
            icon: Icon(Icons.list),
            onPressed: (){
              if(count==1){
                count=2;
                per=0.78;
              }else if(count==2){
                count=1;
                per=3.0;
              }
              setState(() {
              });
            },
            //onPressed: ,
          )
        ],
      ),
      body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20,top: 5),
              color: new Color(0xfff4f5f6),
              height: 38.0,
              child:
              Row(
                children: <Widget>[
                  DropdownButton<String>(
                    value:plan,
                    onChanged: (String newPlan){
                      setState(() {
                        plan=newPlan;
                        _getSearchResult();
                      });
                    },
                    items: <String>[
                      "综合",
                      "价格升序",
                      "价格降序",
                      "销量"
                    ].map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                          value:value,
                          child:Text(value,style: TextStyle(color: Colors.grey),)
                      );
                    }).toList(),
                  ),
                ],
              )
            ),
            Expanded(
                child:RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                      controller: _scrollController,
                      itemCount: proInViews.length,
                      //SliverGridDelegateWithFixedCrossAxisCount 构建一个横轴固定数量Widget
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //横轴元素个数
                          crossAxisCount: count,
                          //纵轴间距
                          mainAxisSpacing: 10.0,
                          //横轴间距
                          crossAxisSpacing: 5.0,
                          //子组件宽高长度比例
                          childAspectRatio:per
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        //Widget Function(BuildContext context, int index)
                        return getProduct(index);
                      })
                )
            )
          ]
      ),
    );
  }

  Future <Null> _onRefresh() async {

    print('下拉刷新开始');

    _getSearchResult();

  }

  getMoreData() async {
    print("get more data");
    //向服务器请求搜索结果
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getSearchResult"],
          body: {
            'type': "getMoreSearchResult#$plan",
            'userID': UserData.userID,
            'query': query,
            'currentIndex': proInViews.length.toString(),
          });
      if (response.body.length != 0) {
        print(response.body);
        var ans = response.body.split("@");
        for (int i = 0; i < ans.length; i++) {

          ProInView proInView=new ProInView();

          proInView.proId=ans[i].split("#")[0];
          proInView.proName=ans[i].split("#")[1];
          proInView.proPrice=ans[i].split("#")[2];
          proInView.proUrl=ans[i].split("#")[3];

          proInViews.add(proInView);
        }
      }
      setState(() {
      });
    }
    catch (e){
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  Future _getSearchResult() async {
    //向服务器请求搜索结果
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getSearchResult"],
          body: {
            'type': "getSearchResult#$plan",
            'userID': UserData.userID,
            'query': query,
            "currentIndex":"0"
          });
      if (response.body.length!=0)

        print(response.body);

        proInViews=[];
        var ans = response.body.split("@");
        for (int i = 0; i < ans.length; i++) {

          ProInView proInView=new ProInView();

          proInView.proId=ans[i].split("#")[0];
          proInView.proName=ans[i].split("#")[1];
          proInView.proPrice=ans[i].split("#")[2];
          proInView.proUrl=ans[i].split("#")[3];

          proInViews.add(proInView);

        }
        setState(() {
        });
    }
    catch (e){
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  void _onClickOpenProPage(String proId,BuildContext context) {
    Navigator.of(context).pushNamed("productPage", arguments: proId+"&search");
  }

  Widget getProduct(int index){

    if(proInViews.length==0){
      return new SizedBox(
        child: Card(
          child: Text("暂无商品"),
        ),
      );
    }

    if(count==1){
      return new GestureDetector(
          onTap: (){_onClickOpenProPage(proInViews[index].proId, context);},
          child:Container(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize:MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding:EdgeInsets.only(left: 5),
                    child: SizedBox(
                      child: Image(
                        image: NetworkImage(proInViews[index].proUrl),
                      ),
                      height: 120,
                    ),
                  ),
                  Container(
                    padding:EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(proInViews[index].proName,style: TextStyle(fontSize: 15),softWrap: true),
                        Text(proInViews[index].proPrice,style: TextStyle(color: Colors.deepOrange,fontSize: 20)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
      );
    }else if(count==2) {
      return new GestureDetector(
        onTap: () {
          _onClickOpenProPage(proInViews[index].proId, context);
        },
        child: SizedBox(
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),),
              child: Container(
                  width: 200,
                  height: 600,
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(
                            proInViews[index].proUrl,
                          ),
                        ),
                        //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 7),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          proInViews[index].proName,
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
                          proInViews[index].proPrice,
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
      );
    }else{
      return new SizedBox(
          child: Card(
            child: Text("错误！"),
          ),
      );
    }
  }
}