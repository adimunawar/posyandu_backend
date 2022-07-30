import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/database.dart';
import '../helper/helper.dart';

class AuthServices {
  String? secret;
  // TokenService? tokenService;
  AuthServices(
    this.secret,
  );
  Router get router {
    final router = Router();
    router.post('/register', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = json.decode(payload);
      final email = userInfo['email'];
      final name = userInfo['name'];
      final phone = userInfo['phone'];
      final password = userInfo['password'];

      // Ensure email and password fields are present
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response(HttpStatus.badRequest,
            body: 'Please provide your email and password');
      }

      // Ensure user is unique
      final user = await db.getOne(table: 'users', where: {'email': email});
      if (user.isNotEmpty) {
        return Response(HttpStatus.badRequest,
            body: jsonEncode(responseFormater(
                message: "user already exists", status: false, data: [])),
            headers: responseHeaders);
      }
      try {
        // Create user
        final salt = generateSalt();
        final hashedPassword = hashPassword(password, salt);
        final creatUser = await db.insert(table: 'users', insertData: {
          'name': name ?? "",
          'email': email ?? "",
          'phone': phone ?? "",
          'password': hashedPassword,
          'salt': salt,
        });
        if (creatUser > 0) {
          final userData =
              await db.getOne(table: 'users', where: {'email': email});
          return Response.ok(
              jsonEncode(responseFormater(
                  message: 'Registrasi berhasil',
                  status: true,
                  data: [
                    {
                      "token": "12345",
                      "name": userData['name'],
                      "email": userData['email'],
                      "phone": userData['phone']
                    }
                  ])),
              headers: responseHeaders);
        } else {
          Response.notFound(
              jsonEncode(responseFormater(
                  message: 'Registrasi gagal', status: false, data: [])),
              headers: responseHeaders);
        }
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode(responseFormater(
            message: 'There was a problem logging you in. Please try again.',
            status: false,
          )),
          headers: responseHeaders,
        );
      }
    });

    //route for login
    router.post('/login', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = json.decode(payload);
      final email = userInfo['email'];
      final password = userInfo['password'];
      // Ensure email and password fields are present
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response(HttpStatus.badRequest,
            body: jsonEncode(responseFormater(
                message: 'email tidak boleh kosong', status: false)));
      }

      //cek sudah terdaftar apa belum
      final user = await db.getOne(table: 'users', where: {'email': email});
      if (user.isEmpty) {
        return Response.forbidden(jsonEncode(
            responseFormater(message: 'Email belum terdaftar', status: false)));
      }
      final hashedPassword = hashPassword(password, user['salt']);
      if (hashedPassword != user['password']) {
        return Response.forbidden(jsonEncode(responseFormater(
            message: 'password yang anda masukan salah', status: false)));
      }
      // Generate JWT and send with response
      // final userId = (user['_id'] as ObjectId).toHexString();
      final totalBalita =
          await db.count(table: 'childrens', where: {'id_staf': user['id']});
      final totalIbu =
          await db.count(table: 'tb_ibu', where: {'id_staf': user['id']});
      try {
        return Response.ok(
            jsonEncode(responseFormater(
                message: 'Login berhasil',
                status: true,
                data: {
                  "id": user['id'],
                  "name": user['name'],
                  "phone": user['phone'],
                  "alamat": user['alamat'],
                  "role": user['role'],
                  "is_active": user['status'],
                  "data_kader": {
                    "total_balita": totalBalita,
                    "total_ibu": totalIbu,
                  }
                })),
            headers: responseHeaders);
        // final tokenPair = await tokenService.createTokenPair(userId);
        // return Response.ok(json.encode(tokenPair.toJson()), headers: {
        //   HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        // });
      } catch (e) {
        return Response.internalServerError(
          // body: 'There was a problem logging you in. Please try again.',
          body: jsonEncode(responseFormater(
            message: 'There was a problem logging you in. Please try again.',
            status: false,
          )),
          headers: responseHeaders,
        );
      }
    });

    //get detail user
    router.get('/detail/<id>', (Request req, String id) async {
      int idUser = int.parse(id);
      final userData = await db.getOne(table: 'users', where: {'id': idUser});
      final totalBalita =
          await db.count(table: 'childrens', where: {'id_staf': idUser});
      final totalIbu =
          await db.count(table: 'tb_ibu', where: {'id_staf': idUser});
      if (userData.isNotEmpty) {
        return Response.ok(
            jsonEncode(
                responseFormater(message: 'berhasil', status: true, data: {
              "id": userData['id'],
              "name": userData['name'],
              "phone": userData['phone'],
              "alamat": userData['alamat'],
              "role": userData['role'],
              "is_active": userData['status'],
              "data_kader": {
                "total_balita": totalBalita,
                "total_ibu": totalIbu,
              }
            })),
            headers: responseHeaders);
      } else {
        return Response.ok(
            jsonEncode(
                responseFormater(message: 'Gagal', status: false, data: [])),
            headers: responseHeaders);
      }
    });

    return router;
  }
}
