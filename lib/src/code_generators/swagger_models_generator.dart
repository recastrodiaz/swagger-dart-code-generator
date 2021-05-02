import 'package:swagger_dart_code_generator/src/code_generators/constants.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_requests_generator.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:recase/recase.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v2/swagger_enums_generator_v2.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';
import 'package:swagger_dart_code_generator/src/exception_words.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_path.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';

abstract class SwaggerModelsGenerator {
  String generate(String dartCode, String fileName, GeneratorOptions options);
  String generateResponses(
      String dartCode, String fileName, GeneratorOptions options);

  String generateRequestBodies(
      String dartCode, String fileName, GeneratorOptions options);

  bool _shouldGenerateModel(SwaggerSchema schema) {
    if (schema.enumValue.isNotEmpty ||
        kBasicTypes.contains(schema.type.toLowerCase()) ||
        schema.items?.type == kEnum ||
        schema.ref.isNotEmpty) {
      return false;
    }

    return true;
  }

  String _generateModelClassContent({
    required String className,
    required SwaggerSchema schema,
    required Map<String, SwaggerSchema> schemas,
    required GeneratorOptions options,
  }) {
    if (_shouldGenerateModel(schema)) {
      return '';
    }

    return _generateModelClassString(
      className: className,
      options: options,
      schema: schema,
      schemas: schemas,
    );
  }

  Map<String, SwaggerSchema> _getClassesFromResponses(
      {required Map<String, SwaggerPath> paths}) {
    final results = <String, SwaggerSchema>{};

    if (paths.isEmpty) {
      return results;
    }

    paths.forEach((path, pathValue) {
      pathValue.requests.forEach((requestType, requestValue) {
        if (requestType == kRequestTypeOptions) {
          return;
        }

        final neededResponse = SwaggerRequestsGenerator.getSuccessedResponse(
            responses: requestValue.responses);

        if (neededResponse?.schema?.type == kObject &&
            neededResponse?.schema?.properties.isNotEmpty == true) {
          final modelKey =
              getResponseModelTypeName(path: path, requestType: requestType);
          results[modelKey] = neededResponse!.schema!;
        }
      });
    });

    return results;
  }

  static String getResponseModelTypeName({
    required String path,
    required String requestType,
  }) {
    final pathText = path.split('/').map((e) => e.pascalCase).join();
    final requestText = requestType.pascalCase;

    return '$pathText$requestText\$$kResponse';
  }

  String generateBase({
    required SwaggerRoot root,
    required String fileName,
    required GeneratorOptions options,
    required Map<String, SwaggerSchema> classes,
  }) {
    final generatedEnumFromJsonToJson =
        genetateEnumFromJsonToJsonMethods([], options.enumsCaseSensitive);

    final classesFromResponses = _getClassesFromResponses(paths: root.paths);

    classes.addAll(classesFromResponses);

    if (classes.isEmpty) {
      return '';
    }

    final generatedClasses = classes.keys.map((String className) {
      if (classes['enum'] != null) {
        return '';
      }

      return _generateModelClassContent(
        schema: classes[className]!,
        className: className,
        schemas: classes,
        options: options,
      );
    }).join('\n');

    var results = '$generatedClasses\n$generatedEnumFromJsonToJson';

    return results;
  }

  static String getValidatedClassName(String className) {
    if (className.isEmpty) {
      return className;
    }

    final isEnum = className.startsWith('enums.');

    if (isEnum) {
      className = className.substring(6);
    }

    final result = className.pascalCase
        .split('-')
        .map((String str) => str.capitalize)
        .join();

    if (kKeyClasses.contains(result)) {
      return '$result\$';
    }

    if (isEnum) {
      return 'enums.$result';
    }

    return result;
  }

  String getParameterTypeName(
      String className, String parameterName, Map<String, dynamic> parameter,
      [String? refNameParameter]) {
    if (refNameParameter != null) {
      return refNameParameter.pascalCase;
    }

    if (parameter.isEmpty) {
      return 'Object';
    }

    if (parameter['\$ref'] != null) {
      return parameter['\$ref'].toString().split('/').last.pascalCase;
    }

    switch (parameter['type'] as String?) {
      case 'integer':
      case 'int':
        return 'int';
      case 'boolean':
        return 'bool';
      case 'string':
        if (parameter['format'] == 'date-time' ||
            parameter['format'] == 'date') {
          return 'DateTime';
        } else if (parameter['enum'] != null) {
          return 'enums.${SwaggerModelsGenerator.getValidatedClassName(SwaggerEnumsGeneratorV2().generateEnumName(className, parameterName))}';
        }
        return 'String';
      case 'number':
        return 'double';
      case 'object':
        return 'Object';
      case 'array':
        final items = parameter['items'] as Map<String, dynamic>? ?? {};
        return getParameterTypeName(className, parameterName, items);
      default:
        if (parameter['oneOf'] != null) {
          return 'Object';
        }
        return 'undefinedType';
    }
  }

  static String generateFieldName(String jsonKey) {
    final forbiddenCharacters = <String>['#'];
    jsonKey = jsonKey.camelCase;

    forbiddenCharacters.forEach((String element) {
      if (jsonKey.startsWith(element)) {
        jsonKey = '\$forbiddenFieldName';
      }
    });

    if (jsonKey.startsWith(RegExp('[0-9]')) ||
        exceptionWords.contains(jsonKey)) {
      jsonKey = '\$' + jsonKey;
    }
    return jsonKey;
  }

  static String generateRequestEnumName(
      String path, String requestType, String parameterName) {
    if (path == '/') {
      path = '\$';
    }

    path = path.split('{').map((e) => e.capitalize).join();
    path = path.split('}').map((e) => e.capitalize).join();

    final correctedPath = generateFieldName(path);

    final result =
        '${correctedPath.capitalize}${requestType.capitalize}${parameterName.capitalize}';

    return SwaggerModelsGenerator.getValidatedClassName(result);
  }

  static String generateRequestName(String path, String requestType) {
    if (path == '/') {
      path = '\$';
    }

    path = path.split('{').map((e) => e.capitalize).join();
    path = path.split('}').map((e) => e.capitalize).join();
    path = path.split(',').map((e) => e.capitalize).join();

    final correctedPath = generateFieldName(path);

    return '${correctedPath.capitalize}${requestType.capitalize}'.camelCase;
  }

  String generateDefaultValueFromMap(DefaultValueMap map) {
    switch (map.typeName) {
      case 'int':
      case 'double':
      case 'bool':
        return map.defaultValue;
      default:
        return "'${map.defaultValue}'";
    }
  }

  String generateIncludeIfNullString(GeneratorOptions options) {
    if (options.includeIfNull == null || !options.includeIfNull!.enabled) {
      return '';
    }

    return ', includeIfNull: ${options.includeIfNull!.value}';
  }

  String generatePropertyContentByDefault(
      Map<String, dynamic> propertyEntryMap,
      String propertyName,
      List<String> allEnumNames,
      List<String> allEnumListNames,
      GeneratorOptions options) {
    var typeName =
        getValidatedClassName(propertyEntryMap['originalRef'].toString());

    if (typeName.isEmpty) {
      typeName = 'dynamic';
    }

    final unknownEnumValue = generateUnknownEnumValue(
        allEnumNames, allEnumListNames, typeName.toString(), false);

    final dateToJsonValue = generateToJsonForDate(propertyEntryMap);

    final includeIfNullString = generateIncludeIfNullString(options);

    final jsonKeyContent =
        "@JsonKey(name: '$propertyName'$includeIfNullString$dateToJsonValue$unknownEnumValue)\n";
    return '\t$jsonKeyContent\tfinal $typeName? ${SwaggerModelsGenerator.generateFieldName(propertyName)};';
  }

  String generateUnknownEnumValue(List<String> allEnumNames,
      List<String> allEnumListNames, String typeName, bool isList) {
    typeName = getValidatedClassName(typeName);

    if (allEnumListNames.contains(typeName)) {
      isList = true;
    }

    if (allEnumNames.contains(typeName)) {
      if (!isList) {
        final enumNameCamelCase = typeName.replaceAll('enums.', '').camelCase;
        return ', toJson: ${enumNameCamelCase}ToJson, fromJson: ${enumNameCamelCase}FromJson';
      } else {
        final enumNameCamelCase = typeName.replaceAll('enums.', '').camelCase;
        return ', toJson: ${enumNameCamelCase}ListToJson, fromJson: ${enumNameCamelCase}ListFromJson';
      }
    }

    return '';
  }

  String generateToJsonForDate(Map<String, dynamic> map) {
    final type = map['type']?.toString().toLowerCase();
    final format = map['format']?.toString().toLowerCase();

    final isDate = type == 'string' && format == 'date';

    if (isDate) {
      return ', toJson: _dateToJson';
    }

    return '';
  }

  String generatePropertyContentBySchema(
      Map<String, dynamic> propertyEntryMap,
      String propertyName,
      String propertyKey,
      String className,
      List<String> allEnumNames,
      List<String> allEnumListNames,
      GeneratorOptions options,
      Map<String, String> basicTypesMap) {
    final propertySchema = propertyEntryMap['schema'] as Map<String, dynamic>;
    final parameterName = propertySchema['\$ref'].toString().split('/').last;

    String typeName;
    if (basicTypesMap.containsKey(parameterName)) {
      typeName = basicTypesMap[parameterName]!;
    } else {
      typeName = getValidatedClassName(getParameterTypeName(
          className, propertyName, propertyEntryMap, parameterName));
    }

    final includeIfNullString = generateIncludeIfNullString(options);

    final allEnumsNamesWithoutPrefix =
        allEnumNames.map((e) => e.replaceFirst('enums.', '')).toList();

    if (allEnumsNamesWithoutPrefix.contains(typeName)) {
      typeName = 'enums.$typeName';
    }

    final unknownEnumValue = generateUnknownEnumValue(
        allEnumNames, allEnumListNames, typeName, false);

    final dateToJsonValue = generateToJsonForDate(propertyEntryMap);

    final jsonKeyContent =
        "@JsonKey(name: '$propertyKey'$includeIfNullString$unknownEnumValue$dateToJsonValue)\n";

    return '\t$jsonKeyContent\tfinal $typeName? ${SwaggerModelsGenerator.generateFieldName(propertyName)};';
  }

  String generatePropertyContentByRef(
      Map<String, dynamic> propertyEntryMap,
      String propertyName,
      String propertyKey,
      String className,
      List<String> allEnumNames,
      List<String> allEnumListNames,
      GeneratorOptions options,
      Map<String, String> basicTypesMap) {
    final parameterName = propertyEntryMap['\$ref'].toString().split('/').last;
    String typeName;
    if (basicTypesMap.containsKey(parameterName)) {
      typeName = basicTypesMap[parameterName]!;
    } else {
      typeName = getValidatedClassName(getParameterTypeName(
          className, propertyName, propertyEntryMap, parameterName));
    }

    final allEnumsNamesWithoutPrefix =
        allEnumNames.map((e) => e.replaceFirst('enums.', '')).toList();

    if (allEnumsNamesWithoutPrefix.contains(typeName)) {
      typeName = 'enums.$typeName';
    }

    final unknownEnumValue = generateUnknownEnumValue(
        allEnumNames, allEnumListNames, typeName, false);

    if (allEnumListNames.contains(typeName)) {
      typeName = 'List<$typeName>';
    }

    final includeIfNullString = generateIncludeIfNullString(options);

    final jsonKeyContent =
        "@JsonKey(name: '$propertyKey'$includeIfNullString$unknownEnumValue)\n";

    return '\t$jsonKeyContent\tfinal $typeName? ${SwaggerModelsGenerator.generateFieldName(propertyName)};';
  }

  String generateEnumPropertyContent(
    String key,
    String className,
    List<String> allEnumNames,
    List<String> allEnumListNames,
    GeneratorOptions options,
  ) {
    final enumName = SwaggerModelsGenerator.getValidatedClassName(
        SwaggerEnumsGeneratorV2().generateEnumName(className, key));

    allEnumNames.add(enumName);

    final unknownEnumValue = generateUnknownEnumValue(
            allEnumNames, allEnumListNames, enumName, false)
        .substring(2);

    final includeIfNullString = generateIncludeIfNullString(options);

    return '''
  @JsonKey($unknownEnumValue$includeIfNullString)
  final ${className.capitalize + key.capitalize}? ${SwaggerModelsGenerator.generateFieldName(key)};''';
  }

  String generateListPropertyContent(
      String propertyName,
      String propertyKey,
      String className,
      Map<String, dynamic> propertyEntryMap,
      bool useDefaultNullForLists,
      List<String> allEnumNames,
      List<String> allEnumListNames,
      GeneratorOptions options,
      Map<String, String> basicTypesMap) {
    final items = propertyEntryMap['items'];

    var typeName = '';
    if (items != null) {
      typeName = getValidatedClassName(items['originalRef'] as String? ?? '');

      if (typeName.isEmpty) {
        final ref = items['\$ref'] as String?;
        typeName = ref?.split('/').last ?? 'dynamic';

        if (basicTypesMap.containsKey(typeName)) {
          typeName = basicTypesMap[typeName]!;
        } else if (typeName != 'dynamic') {
          typeName = typeName.pascalCase;
        }
      }

      if (allEnumNames.contains('enums.$typeName')) {
        typeName = 'enums.$typeName';
      }
    }

    if (typeName.isEmpty) {
      typeName = getParameterTypeName(
          className, propertyName, items as Map<String, dynamic>? ?? {});
    }

    final unknownEnumValue = generateUnknownEnumValue(
        allEnumNames, allEnumListNames, typeName, true);

    final includeIfNullString = generateIncludeIfNullString(options);

    String jsonKeyContent;
    if (unknownEnumValue.isEmpty) {
      jsonKeyContent =
          "@JsonKey(name: '$propertyKey'$includeIfNullString${useDefaultNullForLists ? '' : ', defaultValue: <$typeName>[]'})\n";
    } else {
      jsonKeyContent =
          "@JsonKey(name: '$propertyKey'$includeIfNullString$unknownEnumValue)\n";
    }

    return '$jsonKeyContent  final List<$typeName>? ${SwaggerModelsGenerator.generateFieldName(propertyName)};';
  }

  String generateGeneralPropertyContent(
      String propertyName,
      String propertyKey,
      String className,
      List<DefaultValueMap> defaultValues,
      Map<String, dynamic> val,
      List<String> allEnumNames,
      List<String> allEnumListNames,
      GeneratorOptions options) {
    final includeIfNullString = generateIncludeIfNullString(options);

    var jsonKeyContent = "@JsonKey(name: '$propertyKey'$includeIfNullString";

    var typeName = getParameterTypeName(className, propertyName, val);

    final allEnumsNamesWithoutPrefix =
        allEnumNames.map((e) => e.replaceFirst('enums.', '')).toList();

    if (allEnumsNamesWithoutPrefix.contains(typeName)) {
      typeName = 'enums.$typeName';
    }

    final unknownEnumValue = generateUnknownEnumValue(
        allEnumNames, allEnumListNames, typeName, false);

    final dateToJsonValue = generateToJsonForDate(val);

    jsonKeyContent += unknownEnumValue;
    jsonKeyContent += dateToJsonValue;

    if ((val['type'] == 'bool' || val['type'] == 'boolean') &&
        val['default'] != null) {
      jsonKeyContent += ', defaultValue: ${val['default']})\n';
    } else if (defaultValues
        .any((DefaultValueMap element) => element.typeName == typeName)) {
      final defaultValue = defaultValues.firstWhere(
          (DefaultValueMap element) => element.typeName == typeName);
      jsonKeyContent +=
          ', defaultValue: ${generateDefaultValueFromMap(defaultValue)})\n';
    } else {
      jsonKeyContent += ')\n';
    }

    return '''  $jsonKeyContent  final $typeName? ${SwaggerModelsGenerator.generateFieldName(propertyName)};''';
  }

  String generatePropertyContentByType(
      Map<String, dynamic> propertyEntryMap,
      String propertyName,
      String propertyKey,
      String className,
      List<DefaultValueMap> defaultValues,
      bool useDefaultNullForLists,
      List<String> allEnumsNames,
      List<String> allEnumListNames,
      GeneratorOptions options,
      Map<String, String> basicTypesMap) {
    switch (propertyEntryMap['type'] as String) {
      case 'array':
        return generateListPropertyContent(
          propertyName,
          propertyKey,
          className,
          propertyEntryMap,
          useDefaultNullForLists,
          allEnumsNames,
          allEnumListNames,
          options,
          basicTypesMap,
        );
      case 'enum':
        return generateEnumPropertyContent(
          propertyName,
          className,
          allEnumsNames,
          allEnumListNames,
          options,
        );
      default:
        return generateGeneralPropertyContent(
          propertyName,
          propertyKey,
          className,
          defaultValues,
          propertyEntryMap,
          allEnumsNames,
          allEnumListNames,
          options,
        );
    }
  }

  String _generatePropertiesContent({
    required Map<String, SwaggerSchema> properties,
    required Map<String, SwaggerSchema> schemas,
    required String className,
    required GeneratorOptions options,
  }) {
    if (properties.isEmpty) {
      return '';
    }

    final results = <String>[];

    for (var i = 0; i < properties.keys.length; i++) {
      var propertyName = properties.keys.elementAt(i);
      final propertyEntryMap =
          properties[propertyName] as Map<String, dynamic>;
      final propertyKey = propertyName;

      exceptionWords.forEach((String exceptionWord) {
        if (propertyName == exceptionWord) {
          propertyName = '\$' + propertyName;
        }
      });

      final basicTypesMap = _generateBasicTypesMapFromSchemas(schemas: schemas);

      if (propertyEntryMap.containsKey('type')) {
        results.add(generatePropertyContentByType(
            propertyEntryMap,
            propertyName,
            propertyKey,
            className,
            defaultValues,
            useDefaultNullForLists,
            allEnumNames,
            allEnumListNames,
            options,
            basicTypesMap));
      } else if (propertyEntryMap['\$ref'] != null) {
        results.add(generatePropertyContentByRef(
            propertyEntryMap,
            propertyName,
            propertyKey,
            className,
            allEnumNames,
            allEnumListNames,
            options,
            basicTypesMap));
      } else if (propertyEntryMap['schema'] != null) {
        results.add(generatePropertyContentBySchema(
            propertyEntryMap,
            propertyName,
            propertyKey,
            className,
            allEnumNames,
            allEnumListNames,
            options,
            basicTypesMap));
      } else {
        results.add(generatePropertyContentByDefault(propertyEntryMap,
            propertyName, allEnumNames, allEnumListNames, options));
      }
    }

    return results.join('\n');
  }

  static Map<String, String> _generateBasicTypesMapFromSchemas({
    required Map<String, SwaggerSchema> schemas,
  }) {
    final result = <String, String>{};
    if (schemas.isEmpty) {
      return result;
    }

    schemas.forEach((key, value) {
      if (kBasicTypes.contains(value.type.toLowerCase()) &&
          value.enumValue.isNotEmpty) {
        result[key] = _mapBasicTypeToDartType(value.type, value.format);
      }
    });

    return result;
  }

  static String _mapBasicTypeToDartType(String basicType, String format) {
    if (basicType.toLowerCase() == 'string' &&
        (format == 'date-time' || format == 'datetime')) {
      return 'DateTime';
    }
    switch (basicType.toLowerCase()) {
      case 'string':
        return 'String';
      case 'int':
      case 'integer':
        return 'int';
      case 'double':
      case 'number':
      case 'float':
        return 'double';
      case 'bool':
      case 'boolean':
        return 'bool';
      default:
        return '';
    }
  }

  String genetateEnumFromJsonToJsonMethods(
      List<String> enumNames, bool enumsCaseSensitive) {
    return enumNames
        .map((e) => generateEnumFromJsonToJson(e, enumsCaseSensitive))
        .join('\n');
  }

  String generateEnumFromJsonToJson(String enumName, bool enumsCaseSensitive) {
    final neededName = SwaggerModelsGenerator.getValidatedClassName(
        enumName.replaceFirst('enums.', ''));

    final toLowerCaseString = !enumsCaseSensitive ? '.toLowerCase()' : '';

    return '''
String? ${neededName.camelCase}ToJson(enums.$neededName? ${neededName.camelCase}) {
  return enums.\$${neededName}Map[${neededName.camelCase}];
}

enums.$neededName ${neededName.camelCase}FromJson(String? ${neededName.camelCase}) {

  if(${neededName.camelCase} == null)
  {
    return enums.$neededName.swaggerGeneratedUnknown;
  }

  return enums.\$${neededName}Map.entries
      .firstWhere((element) => element.value$toLowerCaseString == ${neededName.camelCase}$toLowerCaseString,
      orElse: () => const MapEntry(enums.$neededName.swaggerGeneratedUnknown, ''))
      .key;
}

List<String> ${neededName.camelCase}ListToJson(
    List<enums.$neededName>? ${neededName.camelCase}) {

  if(${neededName.camelCase} == null)
  {
    return [];
  }

  return ${neededName.camelCase}
      .map((e) => enums.\$${neededName}Map[e]!)
      .toList();
}

List<enums.$neededName> ${neededName.camelCase}ListFromJson(
    List? ${neededName.camelCase}) {

  if(${neededName.camelCase} == null)
  {
    return [];
  }

  return ${neededName.camelCase}
      .map((e) => ${neededName.camelCase}FromJson(e.toString()))
      .toList();
}
    ''';
  }

  String _generateConstructorPropertiesContent({
    required String className,
    required Map<String, SwaggerSchema> properties,
    required GeneratorOptions options,
  }) {
    if (properties.isEmpty) {
      return '';
    }

    var results = '';

    properties.forEach((key, property) {
      final fieldName = SwaggerModelsGenerator.generateFieldName(key);
      results += '\t\trequired this.$fieldName,\n';
    });

    return '{\n$results\n\t}';
  }

  String _generateModelClassString({
    required String className,
    required SwaggerSchema schema,
    required Map<String, SwaggerSchema> schemas,
    required GeneratorOptions options,
  }) {
    final properties = schema.properties;

    final generatedConstructorProperties =
        _generateConstructorPropertiesContent(
      className: className,
      properties: properties,
      options: options,
    );

    final generatedProperties = generatePropertiesContent(
      properties,
      schemas,
      className,
      defaultValues,
      useDefaultNullForLists,
      options,
    );

    final validatedClassName = getValidatedClassName(className);

    final copyWithMethod =
        generateCopyWithContent(generatedProperties, validatedClassName);

    final generatedClass = '''
@JsonSerializable(explicitToJson: true)
class $validatedClassName $extendsString{
\t$validatedClassName($generatedConstructorProperties);\n
\tfactory $validatedClassName.fromJson(Map<String, dynamic> json) => _\$${validatedClassName}FromJson(json);\n
$generatedProperties
\tstatic const fromJsonFactory = _\$${validatedClassName}FromJson;
\tstatic const toJsonFactory = _\$${validatedClassName}ToJson;
\tMap<String, dynamic> toJson() => _\$${validatedClassName}ToJson(this);
}
$copyWithMethod
''';

    return generatedClass;
  }

  String generateCopyWithContent(
      String generatedProperties, String validatedClassName) {
    final splittedProperties = generatedProperties
        .split(';')
        .where((element) => element.isNotEmpty)
        .map((e) => e.substring(e.indexOf('final ') + 6))
        .map((e) {
      final items = e.split(' ');
      if (!items.first.endsWith('?')) {
        items[0] += '?';
      }

      return items[0] + ' ' + items[1];
    }).toList();

    if (splittedProperties.isEmpty) {
      return '';
    }

    final spittedPropertiesJoined = splittedProperties.join(', ');

    final splittedPropertiesNamesContent = splittedProperties
        .map((e) => e.substring(e.indexOf(' ') + 1))
        .map((e) => '$e: $e ?? this.$e')
        .join(',\n');

    return 'extension \$${validatedClassName}Extension on $validatedClassName { $validatedClassName copyWith({$spittedPropertiesJoined}) { return $validatedClassName($splittedPropertiesNamesContent);}}';
  }
}
