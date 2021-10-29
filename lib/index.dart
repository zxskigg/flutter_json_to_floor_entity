import 'dart:convert';
import 'dart:io';

import 'package:json_to_floor_entity/core/model_template.dart';
import 'package:path/path.dart' as path;

import './core/json_model.dart';
import 'core/dao_template.dart';
import 'core/database_template.dart';

class JsonModelRunner {
  String srcDir = './jsons';
  String distDir = './lib/models';
  String daoDir = './lib/dao';
  String? onlyFile = './lib/models';
  List<FileSystemEntity> list = [];

  JsonModelRunner({
    required String source,
    required String output,
    String? onlyFile,
  })   : srcDir = source,
        distDir = output,
        daoDir = output + '/../dao',
        onlyFile = onlyFile;

  void setup() {
    if (srcDir.endsWith('/')) srcDir = srcDir.substring(0, srcDir.length - 1);
    if (distDir.endsWith('/')) distDir = distDir.substring(0, distDir.length - 1);
    if (daoDir.endsWith('/')) daoDir = daoDir.substring(0, daoDir.length - 1);
  }

  bool run({command}) {
    // run
    // get all json files ./jsons
    list = onlyFile == null ? getAllJsonFiles() : [File(path.join(srcDir, onlyFile))];
    if (!generateModelsDirectory()) return false;
    if (!generateDAODirectory()) return false;
    if (!iterateJsonFile()) return false;
    if (!iterateJsonToDAO()) return false;

    return true;
  }

  void cleanup() async {
    // wrapup cleanup
  }

  // all json files
  List<FileSystemEntity> getAllJsonFiles() {
    var src = Directory(srcDir);
    return src.listSync(recursive: true);
  }

  bool generateModelsDirectory() {
    if (list.isEmpty) return false;
    if (!Directory(distDir).existsSync()) {
      Directory(distDir).createSync(recursive: true);
    }
    return true;
  }

  bool generateDAODirectory() {
    if (list.isEmpty) return false;
    if (!Directory(daoDir).existsSync()) {
      Directory(daoDir).createSync(recursive: true);
    }
    return true;
  }

  // iterate json files model
  bool iterateJsonFile() {
    var error = StringBuffer();

    var indexFile = '';
    list.forEach((f) {
      if (FileSystemEntity.isFileSync(f.path)) {
        var fileExtension = '.json';
        if (f.path.endsWith(fileExtension)) {
          var file = File(f.path);
          var dartPath = f.path.replaceFirst(srcDir, distDir).replaceFirst(
                fileExtension,
                '.model.dart',
                f.path.length - fileExtension.length - 1,
              );
          List basenameString = path.basename(f.path).split('.');
          String fileName = basenameString.first;
          Map<String, dynamic> jsonMap = json.decode(file.readAsStringSync());

          var relative = dartPath.replaceFirst(distDir + path.separator, '').replaceAll(path.separator, '/');

          var jsonModel = JsonModel.fromMap(fileName, jsonMap, relativePath: relative);
          if (!generateFileFromJson(dartPath, jsonModel, fileName)) {
            error.write('cant write $dartPath');
          }

          print('generated: $relative');
          indexFile += "export '$relative';\n";
        }
      }
    });
    if (indexFile.isNotEmpty) {
      File(path.join(distDir, 'index.dart')).writeAsStringSync(indexFile);
    }
    return indexFile.isNotEmpty;
  }

  // generate models from the json file
  bool generateFileFromJson(outputPath, JsonModel jsonModel, name) {
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(
          ModelTemplates.fromJsonModel(jsonModel),
        );
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }


  // iterate json files to dao
  bool iterateJsonToDAO() {
    var error = StringBuffer();
    var daoList = <String>[];
    var indexFile = '';
    list.forEach((f) {
      if (FileSystemEntity.isFileSync(f.path)) {
        var fileExtension = '.json';
        if (f.path.endsWith(fileExtension)) {
          var file = File(f.path);
          var dartPath = f.path.replaceFirst(srcDir, daoDir).replaceFirst(
            fileExtension,
            '.dao.dart',
            f.path.length - fileExtension.length - 1,
          );
          List basenameString = path.basename(f.path).split('.');
          String fileName = basenameString.first;
          Map<String, dynamic> jsonMap = json.decode(file.readAsStringSync());

          var relative = dartPath.replaceFirst(daoDir + path.separator, '').replaceAll(path.separator, '/');

          var jsonModel = JsonModel.fromMap(fileName, jsonMap, relativePath: relative);
          if (!generateFileFromJsonToDAO(dartPath, jsonModel, relative)) {
            error.write('cant write $dartPath');
          }

          daoList.add(fileName);
          indexFile += "export '$relative';\n";
        }
      }
    });
    if (indexFile.isNotEmpty) {
      File(path.join(daoDir, 'index.dart')).writeAsStringSync(indexFile);
    }
    if (!generateFileFromJsonToDatabase(daoDir, daoList)) {
      error.write('cant write $daoDir/database.dart');
    }
    return indexFile.isNotEmpty;
  }

  // generate dao from the json file
  bool generateFileFromJsonToDAO(outputPath, JsonModel jsonModel, relative) {
    try {
      var exists = File(outputPath).existsSync();
      if(!exists) {
        File(outputPath)
          ..createSync(recursive: true)
          ..writeAsStringSync(
            DAOTemplates.fromJsonModel(jsonModel),
          );
        print('generated: $relative');
      }

    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  // generate models from the json file
  bool generateFileFromJsonToDatabase(outputPath, List<String> daoList) {
    outputPath = outputPath + '/database.dart';
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(
          DatabaseTemplates.fromStringList(daoList),
        );
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }



}
