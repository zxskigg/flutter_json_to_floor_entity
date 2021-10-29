
Command line tool for generating Dart Floor(provides a neat SQLite) entities/models from Json file.

_inspired by [json_to_model v2.3.1](https://github.com/fadhilx/json_to_model)._

_based of the [json_to_model v2.3.1](https://pub.dev/packages/json_to_model)_

## Contents

  - [Features](#features)
  - [Installation](#installation)
  - [What does this library do](#what-does-this-library-do)
    - [Get started](#get-started)
    - [Examples](#examples)
  - [Usage](#usage)


## Features

| Feature                   | Status   |
| :----                     |     ---: |
| Null safety               |       ✅ |
| toJson/fromJson           |       ✅ |
| @entity classes           |       ✅ |
| copyWith generation       |       ✅ |
| clone and deepclone       |       ✅ |
| nested json classes       |       ✅ |
| alter tables and field    |       ❌ |
| INTEGER(int) support      |       ✅ |
| REAL(num) support         |       ✅ |
| TEXT(String) support      |       ✅ |
| BLOB(Uint8List) support   |       ✅ |


## Installation

on `pubspec.yaml`

```yaml
dev_dependencies:
  json_to_floor_model: last version
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option.

## What does this library do

Command line tool to convert `.json` files into immutable `.dart` models.

### Get started

The command will run through your json files and find possible type, variable name, import uri, decorator and class name, and will write it into the templates.

Create/copy `.json` files into `./jsons/`(default) on root of your project, and run `flutter pub run json_to_model`.

### Examples

**Input**
Consider this files named product.json and employee.json

product.json
```json
{
  "id": "123",
  "caseId?": "123",
  "startDate?": "2020-08-08",
  "endDate?": "2020-10-10",
  "placementDescription?": "Description string"
}
```

eployee.json
```json
{
  "id": "123",
  "displayName?": "Jan Jansen",
  "@ignore products?": "$[]product"
}
```

**Output**
This will generate this product.dart and employee.dart

product.dart

```dart
import 'package:floor/floor.dart';

@entity
class Product {

  const Product({
    required this.id,
    
    this.caseId,
    
    this.startDate,
    
    this.endDate,
    
    this.placementDescription,
  });

  @primaryKey
  final int id;
  final String? caseId;
  final String? startDate;
  final String? endDate;
  final String? placementDescription;

  factory Product.fromJson(Map<String,dynamic> json) => Product(
    id: json['id'] as String,
    caseId: json['caseId'] != null ? json['caseId'] as String : null,
    startDate: json['startDate'] != null ? json['startDate'] as String : null,
    endDate: json['endDate'] != null ? json['endDate'] as String : null,
    placementDescription: json['placementDescription'] != null ? json['placementDescription'] as String : null
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'caseId': caseId,
    'startDate': startDate,
    'endDate': endDate,
    'placementDescription': placementDescription
  };

  Product clone() => Product(
    id: id,
    caseId: caseId,
    startDate: startDate,
    endDate: endDate,
    placementDescription: placementDescription
  );


  Product copyWith({
    int? id,
    String? caseId,
    String? startDate,
    String? endDate,
    String? placementDescription
  }) => Product(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    placementDescription: placementDescription ?? this.placementDescription,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Product && id == other.id && caseId == other.caseId && startDate == other.startDate && endDate == other.endDate && placementDescription == other.placementDescription;

  @override
  int get hashCode => id.hashCode ^ caseId.hashCode ^ startDate.hashCode ^ endDate.hashCode ^ placementDescription.hashCode;
}

```

eployee.dart
```dart
import 'package:floor/floor.dart';
import 'product.dart';

@entity
class Employee {

  const Employee({
    required this.id,
    this.displayName,
    this.products,
  });

  @primaryKey
  final int id;
  final String? displayName;
  final List<Product>? products;

  factory Employee.fromJson(Map<String,dynamic> json) => Employee(
    id: json['id'] as String,
    displayName: json['displayName'] != null ? json['displayName'] as String : null
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName
  };

  Employee clone() => Employee(
    id: id,
    displayName: displayName,
    products: products?.map((e) => e.clone()).toList()
  );


  Employee copyWith({
    int? id,
    String? displayName,
    List<Product>? products
  }) => Employee(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    products: products ?? this.products,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Employee && id == other.id
    && displayName == other.displayName
    && products == other.products;

  @override
  int get hashCode => id.hashCode ^
    displayName.hashCode ^
    products.hashCode;
}
```

### Create a DAO (Data Access Object)  
This component is responsible for managing access to the underlying SQLite database.
Auto create a dao like this:
```
import 'package:floor/floor.dart';
@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person?> findPersonById(int id);

  @insert
  Future<void> insertPerson(Person person);
}
```
These files will not be deleted or updated after they are created.


###Create the Database
It has to be an abstract class which extends FloorDatabase.
Auto create a dao like this:
```
// database.dart
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/person_dao.dart';
import 'entity/person.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}
```


## Getting started

1. Create a directory `jsons`(default) at root of your project
2. Put all or Create json files inside `jsons` directory
3. run  
   `pub run json_to_floor_model`  
   or  
   `pub run json_to_floor_model -s assets/api_jsons -o lib/models`  
   or  
   `flutter pub run json_to_floor_model -s assets/api_jsons -o lib/models`  
   in flutter project
4. run  
    `flutter packages pub run build_runner build`
   

## Usage
you can also use it for dart model.

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

| Description | Expression | Input (Example) | Output(declaration) | Output(import) |
| :- | - | - | - | - |
| declare type depends on the json value | {`...`:`any type`} | `{"id": 1, "message":"hello world"}`, | `int id;`<br>`String message;` |  |
| import model and asign type | {`...`:`"$value"`} | `{"auth":"$user"}` | `User auth;` | `import 'user.dart'` |
| import from path | {`...`:`"$../pathto/value"`} | `{"price":"$../product/price"}` | `Price price;` | `import '../product/price.dart'` |
| asign list of type and import (can also be recursive) | {`...`:`"$[]value"`} | `{"addreses":"$[]address"}` | `List<Address> addreses;` | `import 'address.dart'` |
| import other library(input value can be array) | {`"@import"`:`...`} | `{"@import":"package:otherlibrary/otherlibrary.dart"}` | | `import 'package:otherlibrary/otherlibrary.dart'` |
| Datetime type | {`...`:`"@datetime"`} | `{"createdAt": "@datetime:2020-02-15T15:47:51.742Z"}` | `DateTime createdAt;` | |
| Enum type | {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin,app_user,normal"}` | `enum UserTypeEnum { Admin, AppUser, Normal }` |
| Enum type with values  {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin(0),app_user(1),normal(2)"}`                            | `enum UserTypeEnum { Admin, AppUser, Normal }`| |
