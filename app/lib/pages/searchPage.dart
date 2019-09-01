import 'package:e_commerce_system/userData.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_system/network.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {

  TextEditingController textEditingController=new TextEditingController();

  String query="";

  List<Widget> associations;

  int counter=0;//计算联想按钮的数量

  @override
  void initState() {
    super.initState();

    associations=[
      MaterialButton(
        onPressed: (){},
        elevation: 0,
        minWidth: 0,
        color: Colors.white,
        child: Text("暂无推荐",style: new TextStyle(color: Colors.grey)),
      ),
    ];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingSearchBar(
        trailing: IconButton(
            icon:Icon(Icons.search),
            onPressed: (){
              if (query!=""){
                print(query);
                Navigator.of(context).pushNamed("searchResultPage",arguments: query);
              }
            }
        ),
        leading: IconButton(
            icon:Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context);}
        ),
        onChanged: (String newQuery) {query=newQuery;_getAssociation(query);},
        onTap: () {print("tab!");},
        children: associations,
        decoration: InputDecoration.collapsed(
          hintText: "请输入关键字",
        ),
      ),
    );
  }

  _getAssociation(String query) async {
    print(query.length);
    if(query==""){
      setState(() {
        associations=[
          MaterialButton(
            elevation: 0,
            minWidth: 0,
            color: Colors.white,
            child: Text("暂无推薦",style: new TextStyle(color: Colors.grey),),
            onPressed: (){},
          ),];
      });
      return;
    }

    //向服务器请求提示
    //从服务器中获取搜索联想

    var client = new http.Client();
    try {
      var response = await client.post(NetWork.addressList["getSearchAssociation"],
          body:{
            'type':'getSearchAssociation',
            'userID': UserData.userID,
            'query':query,
          });
      if(response.body.length!=0) {

        setState(() {
          associations=[];
          counter=0;
          print(response.body);
          var ans = response.body.split("&");

          List<Widget> list1=[];
          List<Widget> list2=[];
          List<Widget> list3=[];

          double plus=20.0;

          for (int i = 0; i < ans.length; i++) {
            if(counter<4){  //4 items
              list1.add(
                  Container(
                    padding: EdgeInsets.only(left: 10,top: 10),
                    width: (ans[i].length+1.5)*plus,
                    height: 40,
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                        color: Colors.white,
                        child: Text(ans[i],style: new TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              "searchResultPage", arguments: query);
                        }
                    ),
                  )
              );
            }else if(4<=counter && counter<7){  //3 items
              list2.add(
                  Container(
                    padding: EdgeInsets.only(left: 10,top: 10),
                    width: (ans[i].length+1.5)*plus,
                    height: 40,
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                        color: Colors.white,
                        child: Text(ans[i],style: new TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              "searchResultPage", arguments: query);
                        }
                    ),
                  )
              );
            }else{  //3 items
              list3.add(
                  Container(
                    padding: EdgeInsets.only(left: 10,top: 10),
                    width: (ans[i].length+1.5)*plus,
                    height: 40,
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                        color: Colors.white,
                        child: Text(ans[i],style: new TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              "searchResultPage", arguments: query);
                        }
                    ),
                  )
              );
            }
            counter++;
          }
          if(list1.length!=0&&list2.length!=0&&list3.length!=0){
            associations.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list1,
              ),
            );
            associations.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list2,
              ),
            );
            associations.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: list3,
                )
            );
          }else if(list1.length!=0&&list2.length!=0){
            associations.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: list1,
                ),
            );
            associations.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list2,
              ),
            );
          }else if(list1.length!=0){
            associations.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list1,
              ),
            );
          }else{
            associations=[
              MaterialButton(
                elevation: 0,
                minWidth: 0,
                color: Colors.white,
                child: Text("暂无推荐",style: new TextStyle(color: Colors.grey)),
                onPressed: (){},
              ),];
          }

        });
      }
    }
    catch (e){
      print(e.toString());
      associations=[Text("No Recommend")];
    }
    finally {
      client.close();
    }
  }
}
