import 'package:http/http.dart' as http;

//this is a class to get requests
class NetWork {

  static const String ServerIP = "http://193.112.216.152";
  //static const String ServerIP = "http://192.168.1.133";

  //服务器网址列
  static const Map<String, String> addressList = {
    'login': ServerIP + ':32769',
    'getPage': ServerIP + ':32770',
    'getSearchAssociation': ServerIP + ':32771',
    'getSearchResult': ServerIP + ':32772',
    'getProductPage': ServerIP + ':32773',
    "addActions": ServerIP + ":32774",
    "getShopCartPage": ServerIP + ":32775",
    "getAddress":ServerIP + ":32776",
    "payConfirm":ServerIP + ":32777",
    "getMyPage":ServerIP + ":32778",
    "Comment":ServerIP + ":32779",
  };

  //返回String类型，需要后续处理
  Future<String> postHttp(String string) async {
    var url = 'http://192.168.0.116:8088';
    var response = await http.post(url, body: string);
    return response.body;
  }
}