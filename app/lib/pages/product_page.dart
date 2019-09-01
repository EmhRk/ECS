import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  ProductPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with SingleTickerProviderStateMixin{

  var pageTabs=2;

  //防止build过度
  bool state=false;

  //选中商品类型
  String type;

  //tab 页码
  int bodyPage=0;

  //商品可选类型
  List<String> _typeList;

  String proID;
  String locationFrom;

  Text proName;
  Text proPrice;

  //是否在愿望清单中
  Icon _isWishList;
  bool _isWishListState=false;

  //controller

  List<bool> _pageState=[false,false,false,false];

  List<Widget> _proBelowPage;

  List<Widget> _proRecPage;

  //上方可动图片
  List<Image> images;

  PageController _pageController;

  //此处定义一个存放GridView数据的变量

  @override
  void initState() {
    super.initState();

    proName=Text("");
    proPrice=Text("");
    _typeList=[""];

    _isWishList=Icon(Icons.star_border,color:Colors.orange);

    images=[Image(
        image:AssetImage('images/avatar.png')
    )];

    _proBelowPage=[Card()];

    _proRecPage=[Card(),Card()];

    _pageController=PageController();

  }

  Widget build(BuildContext context) {

    if(state==false){
      //构建商品页
      var args=ModalRoute.of(context).settings.arguments;

      proID=args.toString().split("&")[0];
      locationFrom=args.toString().split("&")[1];

      _buildProductPage();

      state=true;
    }

    return Scaffold(
      body:NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool boxIsScrolled){
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                  icon:Icon(Icons.arrow_back),
                onPressed: (){Navigator.of(context).pop();},
              ),
              //actions: <Widget>[Icon(Icons.menu)],
              pinned: false,
              floating: true,
              forceElevated: boxIsScrolled,
              expandedHeight: 200,
              flexibleSpace: Container(
                  child:PageView.builder(
                    itemBuilder: ((context,index){
                      return images[index];
                    }),
                    itemCount: images.length,
                    scrollDirection: Axis.horizontal,
                    reverse: false,
                    controller: _pageController,
                    physics: PageScrollPhysics(parent: BouncingScrollPhysics()),
                  )
              ),
            ),
          ];
          },
        body:Column(
          children:<Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 7),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    height: 38.0,
                    child:proPrice,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 7),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    height: 38.0,
                    child:proName,
                  ),
                ],
              ),
            ),
            Card(
              child: Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 7),
                color: Colors.white,
                height: 38.0,
                child: DropdownButton<String>(
                  value:type,
                  onChanged: (String newType){
                    setState(() {
                      type=newType;
                    });
                  },
                  items: _typeList.map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                        value:value,
                        child:Text(
                          value,
                          style: new TextStyle(
                              color: Colors.black87,
                              fontSize: 12
                          ),
                        )
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                // 设置滚动方向
                scrollDirection: Axis.vertical,
                child: Column(
                         children: _proBelowPage,
                       ),
              ),
            ),
          ],
        ),
      ),
        persistentFooterButtons:<Widget>[
          IconButton(icon: _isWishList,onPressed: _toWishList,),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),),
            minWidth: 0,
            color: Colors.orange,
            textColor: Colors.white,
            child: Row(
              children: <Widget>[
                Text('加入愿望清单'),
              ],
            ),
            onPressed: _toWishList,
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),),
            minWidth: 0,
            color: Colors.deepOrange,
            textColor: Colors.white,
            child: Row(
              children: <Widget>[
                new Text('加入购物车'),
                new Icon(Icons.shopping_cart,color: Colors.white,)
              ],
            ),
            onPressed: _toShopCart,
          ),
        ]
    );
  }

  Future _buildProductPage() async {
    //向服务器请求商品主页面
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getProductPage"],
          body: {
            'type': "getProductPage#$locationFrom",
            'index':"0",
            'userID': UserData.userID,
            'productID': proID,
          });
      if (response.body.length!=0) {
        var ans=response.body.split("&");
        var pics=ans[0].split("#");
        var nameAndPrice=ans[1];
        var setList=ans[2].split("@");
        var details=ans[3].split("#");
        var wish=ans[4];

        if(wish=="1"){
          _isWishList=Icon(Icons.star,color: Colors.orange,);
          _isWishListState=true;
        }

        //填充上方可动图片
        images=[];
        for(int i=0;i<pics.length;i++){
          images.add(
              Image(
                  image:NetworkImage(
                    pics[i],
                  )
              )
          );
        }

        //填充商品名与价格
        proPrice=Text(
            nameAndPrice.split("#")[1],
            style: new TextStyle(
                color: Colors.deepOrange,
                fontSize: 25
            ),
        );
        proName=Text(
            nameAndPrice.split("#")[0],
            style: new TextStyle(
                color: Colors.black87,
                fontSize: 15
            ),
        );

        //填充类别
        type=setList[0];
        _typeList=setList;

        //填充下方详情页
        _proBelowPage=[];
        for(int i=0;i<details.length;i++){
          _proBelowPage.add(Image(
                image:NetworkImage(details[i])
          ));
        }

        _pageState[0]=true;
        _pageState[1]=true;
      }

      //填充相似商品推薦

      _getTabPage();

      setState(() {});
    }
    catch (e) {
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  Future _getTabPage() async {
    //向服务器请求其他Tab页面
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getProductPage"],
          body: {
            'type': "getOtherPage#null",
            'index': "2",
            'userID': UserData.userID,
            'productID': proID,
          });
      if (response.body.length!=0) {
        var pageData=response.body;
        print(pageData);
        //do something
        _proRecPage=[];
        var recommends=pageData.split("@");
        for(int i=0;i<recommends.length;i++){
          _proRecPage.add(
              GestureDetector(
                onTap: (){_onClickOpenProPage(recommends[i].split("#")[0],context);},
                child: SizedBox(
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                      child: Container(
                          width: 170,
                          height: 280,
                          child:Column(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: NetworkImage(
                                    recommends[i].split("#")[3],
                                  ),
                                ),
                                //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 7),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  recommends[i].split("#")[1],
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
                                  recommends[i].split("#")[2],
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
        }//add image

        _proBelowPage.add(Text("相似商品"));

        for(int i=0;i<_proRecPage.length;){
          _proBelowPage.add(
            Row(
              children: <Widget>[
                _proRecPage[i],
                _proRecPage[i+1],
              ],
            )
          );
          i+=2;
        }

        setState(() {});
        // to var images
      }
    }
    catch (e) {
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  void _onClickOpenProPage(String proId,BuildContext context) {
    Navigator.of(context).pushNamed("productPage", arguments: proId+"&product");
  }

  Future _toWishList() async {

    if(UserData.userID=="-1"){
      Navigator.of(context).pushNamed("LoginView");
    }

    //把商品添加到愿望清单
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["addActions"],
          body: {
            'type':'WL',
            'state': _isWishListState.toString(),
            'userID': UserData.userID,
            'productID': proID,
          });
      if (response.body.length!=0) {
        if(_isWishListState==false){
          _isWishListState=true;
          _isWishList=Icon(Icons.star,color:Colors.orange);
        }
        else{
          _isWishListState=false;
          _isWishList=Icon(Icons.star_border,color:Colors.orange);
        }
      }
      setState(() {});
    }
    catch (e) {
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  Future _toShopCart() async {

    if(UserData.userID=="-1"){
      Navigator.of(context).pushNamed("LoginView");
    }

    if(type==""){
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              content: new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    Text("请选择类型"),
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
      return;
    }

    //把商品添加到购物车
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["addActions"],
          body: {
            'type':'SC',
            'state': type,
            'userID': UserData.userID,
            'productID': proID,
          });
      if (response.body.length!=0) {
        showDialog(
            context: context,
            builder: (context) {
              return new AlertDialog(
                content: new SingleChildScrollView(
                  child: new Column(
                    children: <Widget>[
                      Text("添加成功"),
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
      setState(() {});
    }
    catch (e) {
      print(e.toString());
    }
    finally {
      client.close();
    }
  }
}