import 'package:e_commerce_system/network.dart';
import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommentPage extends StatefulWidget {
  CommentPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CommentPage createState() => _CommentPage();
}

class _CommentPage extends State<CommentPage> with SingleTickerProviderStateMixin {

  List<Widget> _body;

  List<TextEditingController> _enterComments=[];
  List<String> _proId=[];

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _init(context);

    _scrollController = ScrollController();

    _body = [
      SizedBox(
        height: 120.0, //设置高度
        child: Card(
          child: Text("暂无未评论"),
        ),
      )
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("待评论"),
      ),
      body: ListView(
        children: _body,
        controller: _scrollController,
      ),
      persistentFooterButtons:<Widget>[
        MaterialButton(
          onPressed: _handleSubmit,
          color: Colors.deepOrange,
          textColor: Colors.white,
          child: Text("提交"),
        )
      ],
    );
  }

  void _init(BuildContext context) async {
    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getMyPage"],
          body: {
            'type': 'getCommentPage',
            'userID': UserData.userID,
          });
      if (response != null) {
        var ans = response.body.split("&");

        if (ans.length == 0) {
          return;
        }

        setState(() {
          _body = [];

          //name#id#url
          for (int i = 0; i < ans.length; i++) {
            _proId.add(ans[i].split("#")[1]);
            TextEditingController textEditingController = new TextEditingController();
            _enterComments.add(textEditingController);
            _body.add(
                SizedBox(
                  height: 300,
                  width: 500,
                  child: Row(
                    children: <Widget>[
                      Image(
                        image: NetworkImage(ans[i].split("#")[2]),
                      ),
                      Column(
                        children: <Widget>[
                          Text(ans[i].split("#")[0]),
                          Container(
                            child: loginUserEditInput(textEditingController),
                          )
                        ],
                      )
                    ],
                  ),
                )
            );
          }
        });
      }
    }
    catch (e) {
      print(e.toString());
    }
    finally {
      client.close();
    }
  }

  Widget loginUserEditInput(TextEditingController textEditingController){
    return new Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: new Stack(
        alignment: Alignment(1.0, 1.0),
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    controller: textEditingController,
                    decoration: new InputDecoration(
                        hintText: "请输入评价"
                    ),
                  )
              ),
            ],
          ),
          new IconButton(icon: new Icon(Icons.clear), onPressed: (){
            textEditingController.clear();
          })
        ],
      ) ,
    );
  }

  _handleSubmit() async {
    String comment="";
    for(int i=0;i<_enterComments.length;i++){
      if(_enterComments[i].text.length==0){
        showDialog(
            context: context,
            builder: (context){
              return new AlertDialog(
                title: new Text("信息"),
                content: new Text("评论不能为空"),
                actions: <Widget>[
                  new FlatButton(child: new Text("确定"),onPressed: (){
                    Navigator.of(context).pop();
                  }),
                ],
              );
            }
        );
        return;
      }
      comment=comment+_proId[i]+"#"+_enterComments[i].text+"&";
    }
    comment=comment.substring(1,comment.length-1);

    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["Comment"],
          body:{
            'type':'handleComment',
            'userID': UserData.userID,
            'comment':comment,
          });
      if(response!=null) {
        showDialog(
            context: context,
            builder: (context){
              return new AlertDialog(
                title: new Text("信息"),
                content: new Text("评论成功"),
                actions: <Widget>[
                  new FlatButton(child: new Text("确定"),onPressed: (){
                    Navigator.of(context).pop();
                  }),
                ],
              );
            }
        );
        _init(context);
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