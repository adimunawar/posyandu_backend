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
      // final posyandu = data['posyandu'];
      try {
        // Create user

        var creatUser = await db.insert(table: 'tb_ibu', insertData: {
          'nama': nama ?? "",
          'tgl_lahir': tglLahir ?? "",
          'nama_suami': namaSuami ?? "",
          'alamat': alamat ?? "",
          'gol_darah': goldar,
          'id_staf': idStaf,
          // 'posyandu': posyandu,
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
      // final posyandu = data['posyandu'];
      final idStaf = data['id_staf'];
      try {
        await db.update(table: 'tb_ibu', updateData: {
          'nama': nama ?? "",
          'tgl_lahir': tglLahir ?? "",
          'nama_suami': namaSuami ?? "",
          'alamat': alamat ?? "",
          'gol_darah': goldar,
          // 'posyandu': posyandu,
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

    //get ibu hamil join with table ibu
    router.get('/ibuHamilByStaf/<id>', (Request req, String id) async {
      int idStaf = int.parse(id);
      try {
        var ibuHamil = await db.query(
            'SELECT * FROM tb_ibu INNER JOIN hostory_ibu ON tb_ibu.id = hostory_ibu.id_ibu WHERE tb_ibu.id_staf = $idStaf');
        return Response.ok(
            jsonEncode(responseFormater(
                message: 'berhasil', status: true, data: ibuHamil.rows)),
            headers: responseHeaders);
      } catch (e) {
        return Response.ok(
            jsonEncode(responseFormater(
                message: 'gagal mengambil data', status: false, data: [])),
            headers: responseHeaders);
      }
    });

    //method add ibu hamil
    router.post('/addIbuHamil', (Request req) async {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final idIbu = data['id_ibu'];
      final hamilKe = data['hamil_ke'];
      final umurHamil = data['umur_kehamilan'];
      final tempatPeriksa = data['tempat_periksa'];
      final haidTerkahir = data['haid_terakhir'];
      final statusEkonomi = data['status_ekonomi'];

      try {
        // Create ibu hamil

        var creatIbuHamil = await db.insert(table: 'hostory_ibu', insertData: {
          'id_ibu': idIbu,
          'hamil_ke': hamilKe,
          'umur_kehamilan': umurHamil,
          'tempat_periksa': tempatPeriksa,
          'haid_terakhir': haidTerkahir,
          'status_ekonomi': statusEkonomi,
          'created_at': DateTime.now().toIso8601String()
        });
        if (creatIbuHamil > 0) {
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

    //update ibu hamil
    router.put('/updateIbuHamil', (Request req) async {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final id = data['id'];
      final idIbu = data['id_ibu'];
      final hamilKe = data['hamil_ke'];
      final umurHamil = data['umur_kehamilan'];
      final tempatPeriksa = data['tempat_periksa'];
      final haidTerkahir = data['haid_terakhir'];
      final statusEkonomi = data['status_ekonomi'];

      try {
        // Update ibu hamil
        var updateIbuHamil = await db.update(table: 'hostory_ibu', updateData: {
          'id_ibu': idIbu,
          'hamil_ke': hamilKe,
          'umur_kehamilan': umurHamil,
          'tempat_periksa': tempatPeriksa,
          'haid_terakhir': haidTerkahir,
          'status_ekonomi': statusEkonomi,
          'created_at': DateTime.now().toIso8601String()
        }, where: {
          'id': id
        });
        if (updateIbuHamil > 0) {
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

//delete ibu hamil
    router.delete('/deleteIbuHamil/<id>', (Request req, String id) async {
      int uId = int.parse(id);
      var deleted = await db.delete(table: 'hostory_ibu', where: {'id': uId});
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

    return router;
  }
}
