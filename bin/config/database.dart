import 'package:mysql_utils/mysql_utils.dart';

Map<String, dynamic> setting = {
  // 'host': 'db4free.net',
  // 'port': 3306,
  // 'user': 'adimunawar',
  // 'password': '12345678',
  // 'db': 'adi_db',
  'host': '127.0.0.1',
  'port': 3306,
  'user': 'root',
  'password': '12345',
  'db': 'posyandu_db',
  'maxConnections': 10,
  'secure': false,
  'prefix': '',
  'pool': true,
  'collation': 'utf8mb4_general_ci',
};
var db = MysqlUtils(
    settings: setting,
    errorLog: (error) {
      print(error);
    },
    sqlLog: (sql) {
      print(sql);
    },
    connectInit: (db1) async {
      print('whenComplete');
    });
