import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/database.dart';
import '../helper/helper.dart';

class MotherServices {
  Router get router {
    final router = Router();

    //store new child
    router.post('/store', (Request req) async {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final nama = data['nama'];
      final tglLahir = data['tgl_lahir'];
      final namaSuami = data['nama_suami'];
      final alamat = data['alamat'];
      final goldar = data['gol_darah'];
      final idStaf = data['id_staf'];
      final posyandu = data['posyandu'];
      try {
        // Create user

        var creatUser = await db.insert(table: 'tb_ibu', insertData: {
          'nama': nama ?? "",
          'tgl_lahir': tglLahir ?? "",
          'nama_suami': namaSuami ?? "",
          'alamat': alamat ?? "",
          'gol_darah': goldar,
          'id_staf': idStaf,
          'posyandu': posyandu,
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
      var datas = await db.getAll(table: 'tb_ibu');
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
      final nama = data['nama'];
      final tglLahir = data['tgl_lahir'];
      final namaSuami = data['nama_suami'];
      final alamat = data['alamat'];
      final goldar = data['gol_darah'];
      final posyandu = data['posyandu'];
      final idStaf = data['id_staf'];
      try {
        await db.update(table: 'tb_ibu', updateData: {
          'nama': nama ?? "",
          'tgl_lahir': tglLahir ?? "",
          'nama_suami': namaSuami ?? "",
          'alamat': alamat ?? "",
          'gol_darah': goldar,
          'posyandu': posyandu,
          'id_staf': idStaf,
        }, where: {
          'id': id ?? 0,
        });
        final data = await db.getOne(table: 'tb_ibu', where: {'id': id});
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
      var deleted = await db.delete(table: 'tb_ibu', where: {'id': uId});
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

    //get mother by id staf
    router.get('/getByStaf/<id>', (Request req, String id) async {
      int idStaf = int.parse(id);
      final childrenData =
          await db.getAll(table: 'tb_ibu', where: {'id_staf': idStaf});

      return Response.ok(
          jsonEncode(responseFormater(
              message: 'berhasil', status: true, data: childrenData)),
          headers: responseHeaders);
    });
    return router;
  }
}
