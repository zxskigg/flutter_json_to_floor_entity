import 'package:json_to_floor_entity/utils/extensions.dart';

class DatabaseTemplates {
  static List<String> classNameList = [];
  static String fromStringList(List<String> daoList, {String? cipher='false'}) {
    var template = '''
import 'dart:async';
import 'package:floor/floor.dart';
''';
if(null == cipher || 'false' == cipher){
template += '''
import 'package:sqflite/sqflite.dart' as sqflite;
''';
}else{
template += '''
import 'package:sqflite_sqlcipher/sqflite.dart' as sqflite;
''';
}

for(var dao in daoList){
classNameList.add(dao.toTitleCase());
}

    template += '''
import 'index.dart';
import '../models/index.dart';

part 'database.g.dart'; 

@Database(version: 1, entities: $classNameList)
abstract class AppDatabase extends FloorDatabase {
''';

for(var dao in daoList){
  var className = dao.toTitleCase();
template += '''
  ${className}Dao get ${dao}Dao;
''';
}


template += '''
}\n
''';

    return template;
  }

}
