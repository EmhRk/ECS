import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShoppingCartPage extends StatefulWidget {
  ShoppingCartPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _ShopCartPageState createState() => _ShopCartPageState();

}

class ProDetailsInView{
  bool isSelected;
  String proName;
  String imageUrl;
  String proID;
  String proType;
  String proNum;
  String eachPrice;
  List<String> types;
}

class _ShopCartPageState extends State<ShoppingCartPage> with SingleTickerProviderStateMixin{

  List<ProDetailsInView> proDetailsInViews;

  double _totalPrice=0.0;

  String oldType;

  List<String> upperText=["管理","完成"];
  var _index=0;//判断下单还是删除

  List<String> finalText=["结算","删除"];
  List<Color> totalColor=[Colors.deepOrange,Colors.white];
  List<Color> totalColor1=[Colors.black87,Colors.white];

  var pageTabs=5;

  bool b=false;

  //controller
  ScrollController _scrollController;

  List<Widget> _productsInSC;

  int _page = 0; //选中下标
  //此处定义一个存放GridView数据的变量

  @override
  void initState() {
    super.initState();

    proDetailsInViews=[];

    _scrollController=ScrollController();

    _getShopCartProduct();

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
      appBar: AppBar(
        title: Text("购物车"),
        actions: <Widget>[
          MaterialButton(
              child: Text(upperText[_index],style: TextStyle(color: Colors.white),),
              onPressed: (){setState(() {
                _index=(_index+1)%2;
              });}
          )
        ],
      ),
      body:Scaffold(
          body: RefreshIndicator(
              onRefresh: _onRefresh,
              child:ListView.builder(
                controller:_scrollController,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(5.0),
                reverse: true,
                itemExtent: 180.0,
                shrinkWrap: true,
                itemCount: proDetailsInViews.length,
                cacheExtent: 30.0,
                physics: new AlwaysScrollableScrollPhysics(),
                itemBuilder:_getShops,
              )
          ),
          persistentFooterButtons:<Widget>[
            Container(
              margin: EdgeInsets.only(right: 7),
              child: Row(
                children: <Widget>[
                  Text('合计:￥',style: new TextStyle(color:totalColor1[_index],fontSize: 15)),
                  Text(_totalPrice.toString(),style: new TextStyle(color:totalColor[_index],fontSize: 15)),
                ],
              ),
            ),
            MaterialButton(
              onPressed: _handlePayOrDelete,
              color: Colors.deepOrange,
              textColor: Colors.white,
              child: Text(finalText[_index]),
            )
          ]
      ),
    );
  }

  Future <Null> _onRefresh() async {

    print('下拉刷新开始,page = $_page');

    if(UserData.isLogin==true) {
      _getShopCartProduct();
    }
  }

  void getMoreData() async {
    if(UserData.userID=="-1"){
      return;
    }
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getShopCartPage"],
          body:{
            'type':'getShopCartPage',
            'userID': UserData.userID,
            'currentItemIndex':_productsInSC.length.toString(),
          });
      if(response!=null) {
        var products=response.body.split("&");
        //name#prices#typeselected@types#number#id#image
        for(int i=0;i<products.length;i++){

          ProDetailsInView proDetailsInView=new ProDetailsInView();

          proDetailsInView.isSelected=false;
          proDetailsInView.imageUrl=products[i].split("#")[5];
          proDetailsInView.proID=products[i].split("#")[4];
          proDetailsInView.proNum=products[i].split("#")[3];
          proDetailsInView.eachPrice=products[i].split("#")[1];
          proDetailsInView.proName=products[i].split("#")[0];

          var temp=products[i].split("#")[2].split("@");
          proDetailsInView.proType=temp[0];

          List<String> types=[];

          for(int j=1;j<temp.length;j++){
            types.add(temp[j]);
          }

          proDetailsInView.types=types;

          proDetailsInViews.add(proDetailsInView);
        }
        setState(() {});
      }
    }
    catch (e){
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  _getShopCartProduct() async {
    if(UserData.userID=="-1"){
      return;
    }
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getShopCartPage"],
          body:{
            'type':'getShopCartPage',
            'userID': UserData.userID,
            'currentItemIndex':'0',
          });
      if(response.body.length!=0) {
        setState(() {

          var products=response.body.split("&");

          print(response.body);

          proDetailsInViews=[];
          //name#prices#typeselected@types(@)#number#id#image
          for(int i=0;i<products.length;i++){

            ProDetailsInView proDetailsInView=new ProDetailsInView();

            proDetailsInView.isSelected=false;
            proDetailsInView.imageUrl=products[i].split("#")[5];
            proDetailsInView.proID=products[i].split("#")[4];
            proDetailsInView.proNum=products[i].split("#")[3];
            proDetailsInView.eachPrice=products[i].split("#")[1];
            proDetailsInView.proName=products[i].split("#")[0];

            var temp=products[i].split("#")[2].split("@");
            proDetailsInView.proType=temp[0];

            List<String> types=[];

            for(int j=1;j<temp.length;j++){
              types.add(temp[j]);
            }

            proDetailsInView.types=types;

            proDetailsInViews.add(proDetailsInView);
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

  _onClickOpenProPage(String proId,BuildContext context) {
    print("OnClickRecommend! "+proId);
    Navigator.of(context).pushNamed("productPage", arguments: proId+"&shopcartpage");
  }

  Future _handlePayOrDelete() async {
    if(UserData.userID=="-1"){
      return;
    }

    if(_index==0){ //结算
      if(_totalPrice<=0.0){
        return;
      }

      List<int> orderList=[];

      String order="";
      for(int i=0;i<proDetailsInViews.length;i++){
        if(proDetailsInViews[i].isSelected==true){

          order=order+proDetailsInViews[i].proID+"#"+proDetailsInViews[i].proName+"#"
              +proDetailsInViews[i].proNum+"#" +proDetailsInViews[i].proType+"#"
              +proDetailsInViews[i].eachPrice+"#"+proDetailsInViews[i].imageUrl+"&";
          orderList.add(i);

        }
      }

      order=order.substring(0,order.length-1);

      print(order);

      var result=await Navigator.of(context).pushNamed("payPage", arguments: order);
      if(result.toString()=="T"){
        _index=1;
        _handlePayOrDelete();
        _index=0;
        setState(() {
        });
      }
    }
    else if(_index==1) { //删除
      String order="";

      List<int> orderList=[];

      for(int i=0;i<proDetailsInViews.length;i++){
        if(proDetailsInViews[i].isSelected==false){
          order=order+proDetailsInViews[i].proID+"#"+proDetailsInViews[i].proNum+"#"+proDetailsInViews[i].proType+"&";
          orderList.add(i);
        }
      }

      if(order.length>0){
        order=order.substring(0,order.length-1);
      }

      var client = new http.Client();
      try{
        var response = await client.post(NetWork.addressList["getShopCartPage"],
            body:{
              'type':'editShopCart',
              'userID': UserData.userID,
              'deleteTarget':order,
            });
        if(response.body.length!=0) {
          for(int i=orderList.length-1;i>=0;i--){
            proDetailsInViews.removeAt(orderList[i]);
            _productsInSC.removeAt(orderList[i]);
          }
          setState(() {
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

  Widget _getShops(BuildContext context,int index){
    if(proDetailsInViews.length==0){
      return Card(
        child: Text("暂无商品信息"),
      );
    }
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
        child: Column(
          children: <Widget>[
            Row(
              //mainAxisAlignment:MainAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    activeColor: Colors.deepOrange,
                    value: proDetailsInViews[index].isSelected,
                    onChanged: (bool bol){
                      setState(() {
                        proDetailsInViews[index].isSelected=!proDetailsInViews[index].isSelected;
                        if(proDetailsInViews[index].isSelected==true){
                          _totalPrice+=double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length))*int.parse(proDetailsInViews[index].proNum);
                        }
                        else{
                          _totalPrice-=double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length))*int.parse(proDetailsInViews[index].proNum);
                        }
                      });
                    },
                  ),
                  SizedBox(
                      height: 115,
                      child:GestureDetector(
                          onTap: (){_onClickOpenProPage(proDetailsInViews[index].proID,context);},//id for tap
                          child:Image(
                              image: NetworkImage(
                                proDetailsInViews[index].imageUrl,//picture
                              )
                          )
                      )
                  ),
                  //name&types
                  Container(
                    //alignment: Alignment.centerLeft,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Container(
                          padding:EdgeInsets.only(left: 20),
                          //margin: EdgeInsets.only(left: 20,top: 10),
                          //alignment: Alignment.bottomLeft,
                          child: Text(proDetailsInViews[index].proName,softWrap:true,style: TextStyle(color: Colors.black87,fontSize: 16),),//name,
                        ),
                        Container(
                          padding:EdgeInsets.only(left: 20),
                          //margin: EdgeInsets.only(left: 20),
                          child: DropdownButton<String>(
                            value:proDetailsInViews[index].proType,
                            onChanged: (String newType) async {
                              var client = new http.Client();
                              try {
                                var response = await client.post(NetWork.addressList["addActions"],
                                    body: {
                                      'type':'changeTypeFromSC',
                                      'state': newType+"#"+proDetailsInViews[index].proType,
                                      'userID': UserData.userID,
                                      'productID': proDetailsInViews[index].proID,
                                    });
                                if (response != null) {
                                  //change price...
                                  //I give up....
                                }
                              }
                              catch (e) {
                                print(e.toString());
                              }
                              finally {
                                client.close();
                              }
                              setState(() {
                                proDetailsInViews[index].proType=newType;
                              });
                            },
                            items: proDetailsInViews[index].types.map<DropdownMenuItem<String>>((String value){
                              return DropdownMenuItem<String>(
                                  value:value,
                                  child:Text(value,style: TextStyle(color: Colors.grey,fontSize: 12),)
                              );
                            }).toList(),
                          ),//type
                        ),
                      ],
                    ),
                  ),
                ]
            ),
            Container(
              padding:EdgeInsets.only(left: 200.0-7*(double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length))*double.parse(proDetailsInViews[index].proNum)).toString().length,bottom: 5),
              //margin: EdgeInsets.only(left: 20),
              //alignment: Alignment.bottomRight,
              child: Row(
                //mainAxisSize:MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "￥"+(double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length))*int.parse(proDetailsInViews[index].proNum)).toString(),//totalPrice
                    style: TextStyle(color: Colors.deepOrange,fontSize: 17),
                  ),//price
                  Row(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(),
                        child: IconButton(
                          icon:Icon(Icons.remove_circle_outline,size: 20,color: Colors.grey,),
                          onPressed: (){
                            print("-!");
                            setState(() {
                              if(proDetailsInViews[index].proNum=="1"){
                                return;
                              }
                              proDetailsInViews[index].proNum=
                                  (int.parse(proDetailsInViews[index].proNum)-1).toString();
                              if(proDetailsInViews[index].isSelected==true){
                                _totalPrice-=double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length));
                              }
                            });
                          },
                        ),
                      ),
                      Text(proDetailsInViews[index].proNum,style: TextStyle(color: Colors.grey,),),//number
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(),
                        child: IconButton(
                          icon:Icon(Icons.add_circle_outline,size: 20,color: Colors.grey,),
                          onPressed: (){
                            print("+!");
                            setState(() {
                              proDetailsInViews[index].proNum=
                                  (int.parse(proDetailsInViews[index].proNum)+1).toString();
                              if(proDetailsInViews[index].isSelected==true){
                                _totalPrice+=double.parse(proDetailsInViews[index].eachPrice.substring(2,proDetailsInViews[index].eachPrice.length));
                              }
                            });
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}