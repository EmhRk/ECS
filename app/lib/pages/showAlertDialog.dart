import 'package:flutter/material.dart';

void dataTimeOutDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("提示"),
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text("用户信息过期，请重新登陆。"),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {Navigator.of(context).pushNamed("LoginView");},
              child: new Text("登陆"),
            ),
            new FlatButton(
              onPressed: (){Navigator.of(context).pop();},
              child: new Text("取消"),
            ),
          ],
        );
      });
}

void orderSucceed(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text("支付成功。"),
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

void orderFailed(BuildContext context,String text) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text(text),
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

void pswErr(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text("登陆失败,密码错误。"),
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

void userNotExist(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text("用户不存在。"),
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

void registerFailed(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          content: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Text("用户名已注册。"),
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