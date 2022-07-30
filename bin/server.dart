import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';
import 'helper/helper.dart';
import 'services/services.dart';

void main(List<String> args) async {
  final secret = '25BBD370-975D-4D45-8F5A-B3FA92155CCA';
  final ip = '192.168.43.39';
  final port = int.parse(Platform.environment['PORT'] ?? '8082');
  final app = Router();
  app.mount('/users/', AuthServices(secret).router);
  app.mount('/childrens/', ChildrenServices().router);
  app.mount('/mothers/', MotherServices().router);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);
  withHotreload((() => serve(handler, ip, port)));
}
