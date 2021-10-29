import 'package:json_to_floor_entity/core/json_model.dart';

typedef JsonModelConverter = String Function(JsonModel data, [bool isNested]);

class DAOTemplates {
  static JsonModelConverter fromJsonModel = (data, [isNested = false]) => DAOTemplates.defaultTemplate(
        isNested: isNested,
        constructor: data.constructor,
        imports: data.imports,
        fileName: data.fileName,
        className: data.className,
        extendsClass: data.extendsClass,
        mixinClass: data.mixinClass,
        equalsDeclarations: data.equalsDeclarations,
        hashDeclarations: data.hashDeclarations,
        declaration: data.declaration,
        copyWith: data.copyWith,
        cloneFunction: data.cloneFunction,
        jsonFunctions: data.jsonFunctions,
        enums: data.enums,
        enumConverters: data.enumConverters,
        nestedClasses: data.nestedClasses,
      );

  static String defaultTemplate({
    required bool isNested,
    required String constructor,
    required String imports,
    required String fileName,
    required String className,
    required String mixinClass,
    required String equalsDeclarations,
    required String hashDeclarations,
    required String declaration,
    required String copyWith,
    required String cloneFunction,
    required String jsonFunctions,
    String? enums,
    String? enumConverters,
    String? nestedClasses,
    String? extendsClass,
  }) {
    var template = '';

    if (!isNested) {
      template += '''
import 'package:floor/floor.dart';
$imports

''';
    }

    template += '''
@dao
abstract class ${className}Dao${extendsClass != null ? ' extends $extendsClass ' : ''}${mixinClass.isNotEmpty ? ' with $mixinClass' : ''} {

  @Query('SELECT * FROM $className')
  Future<List<$className>> findAll();

  @Query('SELECT * FROM $className WHERE id = :id')
  Future<$className?> findById(int id);

  @insert
  Future<void> add($className entity);
  
  @insert
  Future<void> addList(List<$className> entities);

  @update
  Future<void> edit($className entity);

  @update
  Future<void> editList(List<$className> entities);

  @delete
  Future<void> remove($className entity);

  @delete
  Future<void> removeList(List<$className> entities);

''';

    template += '}\n';

    return template;
  }

}
