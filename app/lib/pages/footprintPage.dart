import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FootprintPage extends StatefulWidget {
  FootprintPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FootprintPage createState() => _FootprintPage();
}

class _FootprintPage extends State<FootprintPage> with SingleTickerProviderStateMixin {

  List<Widget> _body;

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _init(context);

    _scrollController = ScrollController();

    _body = [
      SizedBox(
        height: 120.0, //设置高度
        child: Card(),
      )
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("足迹"),
      ),
      body: GridView.count(
        childAspectRatio: 0.55,
        crossAxisCount: 4,
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
            'type':'getFootprint',
            'userID': UserData.userID,
          });
      if(response.body.length!=0) {
        _body=[];
        var ans=response.body.split("&");
        //id#url
        for(int i =0;i<ans.length;i++){
          _body.add(
              GestureDetector(
                  onTap: (){Navigator.of(context).pushNamed("productPage",arguments: ans[i].split("#")[0]+"&history");},
                  child:Column(
                    children: <Widget>[
                      Image(
                        image: NetworkImage(ans[i].split("#")[1]),
                      ),
                    ],
                  ),
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