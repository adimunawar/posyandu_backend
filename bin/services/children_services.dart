import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/database.dart';
import '../helper/helper.dart';
import 'package:intl/intl.dart';

class ChildrenServices {
  Router get router {
    final router = Router();

    //store new child
    router.post('/store', (Request req) async {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final childName = data['child_name'];
      final birthDate = data['birth_date'];
      final weight = data['weight'];
      final height = data['height'];
      final gender = data['gender'];
      final category = data['category'];
      final idStaf = data['id_staf'];
      final motherName = data['mother_name'];
      final birthPlace = data['birth_place'];
      final helper = data['helper'];
      try {
        print({
          'child_name': childName ?? "",
          'birth_date': birthDate ?? "",
          'weight': weight ?? 0,
          'height': height ?? 0,
          'gender': gender ?? "",
          'category': category ?? "",
          'id_staf': idStaf ?? 0,
          'mother_name': motherName ?? "",
        });
        // Create user

        var creatUser = await db.insert(table: 'childrens', insertData: {
          'child_name': childName ?? "",
          'birth_date': birthDate ?? "",
          'weight': weight ?? 0,
          'height': height ?? 0,
          'gender': gender ?? "",
          'category': category ?? "",
          'id_staf': idStaf ?? 0,
          'mother_name': motherName ?? "",
          'birth_place': birthPlace ?? "",
          "helper": helper ?? "",
          'created_at': DateTime.now().toIso8601String(),
        });
        if (creatUser > 0) {
          // final userData =
          //     await db.getOne(table: 'users', where: {'email': email});
          return Response.ok(
              jsonEncode(responseFormater(
                  message: 'data berhasil disimpan', status: true, data: [])),
              headers: responseHeaders);
        } else {
          Response.ok(
              jsonEncode(responseFormater(
                  message: 'Data gagal disimpan', status: false, data: [])),
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

    //get all children
    router.get('/all', (Request req) async {
      var datas = await db.getAll(table: 'childrens');
      return Response.ok(
          jsonEncode(
              responseFormater(message: 'berhasil', status: true, data: datas)),
          headers: responseHeaders);
    });

    //update
    router.put('/update', (Request req) async {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final id = data['id'];
      final childName = data['child_name'];
      final birthDate = data['birth_date'];
      final weight = data['weight'];
      final height = data['height'];
      final gender = data['gender'];
      final category = data['category'];
      final idStaf = data['id_staf'];
      final motherName = data['mother_name'];
      final birthPlace = data['birth_place'];
      final helper = data['helper'];
      try {
        await db.update(table: 'childrens', updateData: {
          'child_name': childName ?? "",
          'birth_date': birthDate ?? "",
          'weight': weight ?? 0,
          'height': height ?? 0,
          'gender': gender ?? "",
          'category': category ?? "",
          'id_staf': idStaf ?? "",
          'mother_name': motherName ?? "",
          'birth_place': birthPlace ?? "",
          'helper': helper ?? ""
        }, where: {
          'id': id,
        });
        final data = await db.getOne(table: 'childrens', where: {'id': id});
        return Response.ok(
            jsonEncode(responseFormater(
                message: 'data berhasil diperbaharui',
                status: true,
                data: data)),
            headers: responseHeaders);
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
    //delete

    router.delete('/delete/<id>', (Request req, String id) async {
      int uId = int.parse(id);
      var deleted = await db.delete(table: 'childrens', where: {'id': uId});
      print(deleted);
      if (deleted > 0) {
        return Response.ok(
            jsonEncode(responseFormater(
              message: 'data berhasil dihapus',
              status: true,
            )),
            headers: responseHeaders);
      } else {
        return Response.ok(
            jsonEncode(responseFormater(
                message: 'data gagal dihapus', status: false, data: [])),
            headers: responseHeaders);
      }
    });

    //get children by id staf
    router.get('/getByStaf/<id>', (Request req, String id) async {
      int idStaf = int.parse(id);
      final childrenData =
          await db.getAll(table: 'childrens', where: {'id_staf': idStaf});

      return Response.ok(
          jsonEncode(responseFormater(
              message: 'berhasil', status: true, data: childrenData)),
          headers: responseHeaders);
    });
    return router;
  }
}
