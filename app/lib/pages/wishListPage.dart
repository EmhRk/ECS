import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WishListPage extends StatefulWidget {
  WishListPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WishListPage createState() => _WishListPage();
}

class _WishListPage extends State<WishListPage> with SingleTickerProviderStateMixin {

  List<Widget> _body;

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _init(context);

    _scrollController = ScrollController();

    _body = [
      SizedBox(
        height: 100 ,//设置高度
        child: Container(
          alignment: Alignment.center,
          child: Text("愿望清单中暂无商品。",style: TextStyle(color: Colors.grey),),
        ),
      )
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("愿望清单"),
      ),
      body: ListView(
        children: _body,
        controller: _scrollController,
      ),
    );
  }

  void _init(BuildContext context) async {
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getMyPage"],
          body:{
            'type':'getWishList',
            'userID': UserData.userID,
          });
      if(response.body.length!=0) {
        print(response.body);
        _body=[];
        var ans=response.body.split("&");
        //name#id#price#url
        for(int i =0;i<ans.length;i++){
          _body.add(
              GestureDetector(
                onTap: (){Navigator.of(context).pushNamed("productPage",arguments: ans[i].split("#")[1]+"&wishlistpage");},
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
                              image: NetworkImage(ans[i].split("#")[3]),
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
                              Text(ans[i].split("#")[0],style: TextStyle(fontSize: 15),softWrap: true),
                              Text("￥"+ans[i].split("#")[2],style: TextStyle(color: Colors.deepOrange,fontSize: 20)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              )
          );
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
}