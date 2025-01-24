import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/recovery_form_model.dart';

class RecoveryFormRepository {
  DBHelper dbHelper = DBHelper();
  Future<List<RecoveryFormModel>> getRecoveryForm() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(recoveryFormTableName, columns: [
      'recovery_id',
      'shop_name',
      'current_balance',
      'cash_recovery',
      'net_balance',
      'recovery_date',
      'recovery_time'
    ]);
    List<RecoveryFormModel> recoveryform = [];
    for (int i = 0; i < maps.length; i++) {
      recoveryform.add(RecoveryFormModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Recovery form Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return recoveryform;
  }

  Future<int> add(RecoveryFormModel recoveryformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        recoveryFormTableName, recoveryformModel.toMap());
  }

  Future<int> update(RecoveryFormModel recoveryformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        recoveryFormTableName, recoveryformModel.toMap(),
        where: 'recovery_id = ?', whereArgs: [recoveryformModel.recovery_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(recoveryFormTableName, where: 'recovery_id = ?', whereArgs: [id]);
  }
}
