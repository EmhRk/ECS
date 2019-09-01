import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PayPage extends StatefulWidget {
  PayPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _PayPageState createState() => _PayPageState();
}

class ProDetailsInView{
  bool isSelected;
  String proName;
  String imageUrl;
  String proID;
  String proType;
  String proNum;
  String eachPrice;
}

class _PayPageState extends State<PayPage> with SingleTickerProviderStateMixin{

  List<String> _addresses;

  bool isFirst=true;

  String _address;

  bool waitForPay=true;

  double _totalPrice=0.0;

  List<Widget> _bodyData;

  String buttonText="确认支付";

  List<ProDetailsInView> proDetailsInViews;

  @override
  void initState() {
    super.initState();

    _addresses=["请选择收货地址"];
    _address=_addresses[0];

    proDetailsInViews=[];

    _bodyData=[];

    _getAddress();

  }

  Widget build(BuildContext context) {

    if(isFirst==true){

      isFirst=false;
      //获取下单的信息
      var args=ModalRoute.of(context).settings.arguments;

      List<String> orders=args.toString().split("&");

      for(int i=0;i<orders.length;i++){

        ProDetailsInView proDetailsInView=new ProDetailsInView();

        proDetailsInView.proID=orders[i].split("#")[0];
        proDetailsInView.proName=orders[i].split("#")[1];
        proDetailsInView.proNum=orders[i].split("#")[2];
        proDetailsInView.proType=orders[i].split("#")[3];
        proDetailsInView.eachPrice=orders[i].split("#")[4];
        proDetailsInView.imageUrl=orders[i].split("#")[5];

        _totalPrice+=double.parse(proDetailsInView.eachPrice.substring(2,proDetailsInView.eachPrice.length))*int.parse(proDetailsInView.proNum);

        proDetailsInViews.add(proDetailsInView);

        _bodyData.add(
          SizedBox(
              height: 120.0,  //设置高度
              child: Card(
                  child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize:MainAxisSize.max,
                      children: <Widget>[
                        GestureDetector(
                            onTap: (){_onClickOpenProPage(proDetailsInView.proID,context);},//id for tap
                            child:Image(
                                image: NetworkImage(
                                  proDetailsInView.imageUrl,//picture
                                )
                            )
                        ),
                        SizedBox(
                          height: 120.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(proDetailsInView.proName,style: TextStyle(fontSize: 20),),
                              ),//name
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("类型："+proDetailsInView.proType,style: TextStyle(fontSize: 15,color: Colors.grey),),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("数量："+proDetailsInView.proNum,style: TextStyle(fontSize: 15,color: Colors.grey),),
                              ), //price
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 100.0-5*(double.parse(proDetailsInView.eachPrice.substring(2,proDetailsInView.eachPrice.length))*double.parse(proDetailsInView.proNum)).toString().length,bottom: 7),
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "共"+proDetailsInView.proNum+"件,小计:"+
                            "￥"+(double.parse(proDetailsInView.eachPrice.substring(2,proDetailsInView.eachPrice.length))*double.parse(proDetailsInView.proNum)).toString(),
                            style: TextStyle(fontSize: 15,color: Colors.deepOrangeAccent),//totalPrice
                          ),
                        )
                      ]
                  )
              )
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text( "支付页"),
        leading: IconButton(
          icon:Icon(Icons.arrow_back),
          onPressed: (){Navigator.pop(context);},
        ),
      ),
      body: Column(
          children: <Widget>[
            Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              elevation: 10.0,
              margin: EdgeInsets.all(5.0),
              semanticContainer: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              child: Row(
                crossAxisAlignment:CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:EdgeInsets.only(left: 5),
                    child: Icon(Icons.home),
                  ),
                  Text("收货地址："),
                  DropdownButton<String>(
                    value:_address,
                    onChanged: (String newType) {
                      setState(() {
                        _address=newType;
                      });
                    },
                    items: _addresses.map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                          value:value,
                          child:Text(value)
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: _bodyData,
              ),
            ),
            /*Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              elevation: 0.0,
              margin: EdgeInsets.all(5.0),
              semanticContainer: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child:ListTile(
                          title: Text(_couponSelected),
                          trailing: PopupMenuButton(
                            padding: EdgeInsets.zero,
                            onSelected: _showMenuSelection,
                            itemBuilder: (BuildContext context)=><PopupMenuItem<String>>[
                              PopupMenuItem<String>(
                                value: _couponSelected,
                                child: Text("no coupon available"),
                                enabled: false,
                              ),
                              PopupMenuItem<String>(
                                value: _couponSelected,
                                child: Text("tick here one"),
                                enabled: true,
                              ),
                              PopupMenuItem<String>(
                                value: _couponSelected,
                                child: Text("tick here one"),
                                enabled: true,
                              )
                            ],
                          ),
                    ),
                  )
                ],
              ),
            ),*/
          ]
      ),
        persistentFooterButtons:<Widget>[
          Text("合计："),
          Text("￥"+_totalPrice.toString(),style: TextStyle(color: Colors.deepOrange),),
          MaterialButton(
            color: Colors.deepOrange,
            textColor: Colors.white,
            child: new Text(buttonText),
            onPressed: (){
              if(buttonText=="确认支付"){
                _payConfirm();
              }else if(buttonText=="返回"){
                Navigator.pop(context,"T");
              }

            },
          )
        ]
    );
  }

  _onClickOpenProPage(String proId,BuildContext context) {
    print("OnClickRecommend! "+proId);
    Navigator.of(context).pushNamed("productPage", arguments: proId+"&paypage");
  }

  _payConfirm() async {

    if(_address==""){
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              content: new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    Text("请选择地址"),
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

    String order="";

    //id#num#type
    for(int i=0;i<proDetailsInViews.length;i++){
      order=order+proDetailsInViews[i].proID+"#"+proDetailsInViews[i].proNum+"#" +proDetailsInViews[i].proType+"@";
    }

    order=order.substring(0,order.length-1);

    var client=new http.Client();
    try{
      var response = await client.post(NetWork.addressList["payConfirm"],
          body:{
            'type':'payConfirm',
            'userID': UserData.userID,
            'Order':order,
          });
      if(response.body.length!=0) {
        print(response.body);
        if(response.body=="Succeed"){
          showDialog(
              context: context,
              builder: (context) {
                return new AlertDialog(
                  content: new SingleChildScrollView(
                    child: new Column(
                      children: <Widget>[
                        Text("支付成功"),
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
            buttonText="返回";
          });
        }
        else if(response.body=="Failed"){
          showDialog(
              context: context,
              builder: (context) {
                return new AlertDialog(
                  content: new SingleChildScrollView(
                    child: new Column(
                      children: <Widget>[
                        Text("支付失败"),
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
          Navigator.pop(context, "F");
        }
      }
    }
    catch (e){
      print(e.toString());
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              content: new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    Text("请检查网络"),
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
    finally {
      client.close();
    }
  }

  void _getAddress() async {
    var client=new http.Client();
    try{
      var response = await client.post(NetWork.addressList["getAddress"],
          body:{
            'type':'getAddress',
            'userID': UserData.userID,
          });
      if(response.body.length!=0) {
        setState(() {
          var addressList = response.body.split("#");

          for (int i = 0; i < addressList.length; i++) {
            _addresses.add(addressList[i]);
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
}