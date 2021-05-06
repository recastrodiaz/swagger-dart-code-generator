import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/exception_words.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_path.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';

class SwaggerEnumsGenerator {
  static const String defaultEnumFieldName = 'value_';
  static const String defaultEnumValueName = 'swaggerGeneratedUnknown';

  String generate(String swagger, String fileName) {
    final sw = jsonDecode(swagger) as Map<String, dynamic>;

    final root = SwaggerRoot.fromJson(sw);

    final enumsFromRequests = generateEnumsContentFromRequests(root);

    final enumsFromResponses =
        generateEnumsFromResponses(root.components?.responses ?? {});

    final definitions = root.definitions
      ..addAll(root.components?.schemas ?? {});

    final enumsFromClasses = definitions
        .map((className, classSchema) {
          return MapEntry(
              className,
              generateEnumsFromSchema(
                  SwaggerModelsGenerator.getValidatedClassName(
                      className.pascalCase),
                  classSchema));
        })
        .values
        .where((element) => element.isNotEmpty)
        .join('\n');

    if (enumsFromClasses.isEmpty &&
        enumsFromRequests.isEmpty &&
        enumsFromResponses.isEmpty) {
      return '';
    }

    return '''
import 'package:json_annotation/json_annotation.dart';
$enumsFromClasses

$enumsFromRequests

$enumsFromResponses
''';
  }

  String generateEnumsFromResponses(Map<String, SwaggerSchema> responses) {
    if (responses.isEmpty) {
      return '';
    }

    final enumsFromResponses = responses
        .map((className, responseSchema) {
          final response = responses[className];

          if (response == null) {
            return MapEntry(className, '');
          }

          return MapEntry(
              className,
              generateEnumsFromSchema(
                  SwaggerModelsGenerator.getValidatedClassName(
                      className.pascalCase),
                  response));
        })
        .values
        .where((element) => element.isNotEmpty)
        .join('\n');

    return enumsFromResponses;
  }

  static SwaggerRequestParameter getOriginalOrOverriddenRequestParameter(
      SwaggerRequestParameter swaggerRequestParameter,
      List<SwaggerRequestParameter> definedParameters) {
    if (swaggerRequestParameter.ref.isEmpty || definedParameters.isEmpty) {
      return swaggerRequestParameter;
    }

    final parameterClassName = swaggerRequestParameter.ref.split('/').last;

    final neededParameter = definedParameters.firstWhere(
        (SwaggerRequestParameter element) =>
            element.name == parameterClassName ||
            element.key == parameterClassName,
        orElse: () => swaggerRequestParameter);

    return neededParameter;
  }

  String generateEnumsContentFromRequests(SwaggerRoot root) {
    final result = StringBuffer();
    //Link defined parameters with requests
    root.paths.forEach((path, swaggerPath) {
      swaggerPath.requests.forEach((req, swaggerRequest) {
        swaggerRequest.parameters = swaggerRequest.parameters
            .map((parameter) => getOriginalOrOverriddenRequestParameter(
                parameter, root.components?.parameters ?? []))
            .toList();
      });
    });

    root.paths.forEach((path, swaggerPath) {
      swaggerPath.requests.forEach((requestType, swaggerRequest) {
        if (swaggerRequest.parameters.isEmpty) {
          return;
        }

        for (var p = 0; p < swaggerRequest.parameters.length; p++) {
          final swaggerRequestParameter = swaggerRequest.parameters[p];

          var name = SwaggerModelsGenerator.generateRequestEnumName(
              path, requestType, swaggerRequestParameter.name);

          name = SwaggerModelsGenerator.getValidatedClassName(name);

          final enumValues = swaggerRequestParameter.schema?.enumValues ??
              swaggerRequestParameter.items?.enumValues ??
              [];

          if (enumValues.isNotEmpty) {
            final enumContent = generateEnumContent(name, enumValues);

            result.writeln(enumContent);
          }
        }
      });
    });

    return result.toString();
  }

  String generateEnumContent(String enumName, List<String> enumValues) {
    final enumValuesContent = getEnumValuesContent(enumValues);

    final enumMap = '''
\n\tconst \$${enumName}Map = {
\t${getEnumValuesMapContent(enumName, enumValues)}
      };
      ''';

    final result = """
enum $enumName{
\t@JsonValue('swaggerGeneratedUnknown')
\tswaggerGeneratedUnknown,
$enumValuesContent
}

$enumMap
 """;

    return result;
  }

  String getEnumValuesContent(List<String> enumValues) {
    final result = enumValues
        .map((String enumFieldName) =>
            "\t@JsonValue('${enumFieldName.replaceAll("\$", "\\\$")}')\n\t${getValidatedEnumFieldName(enumFieldName)}")
        .join(',\n');

    return result;
  }

  String getEnumValuesMapContent(String enumName, List<String> enumValues) {
    final neededValues = <String>[];
    neededValues.addAll(enumValues);

    final unknownEnumPart = ',\n\t$enumName.swaggerGeneratedUnknown: \'\'';

    final result = neededValues
            .map((String enumFieldName) =>
                '\t$enumName.${getValidatedEnumFieldName(enumFieldName)}: \'${enumFieldName.replaceAll('\$', '\\\$')}\'')
            .join(',\n') +
        unknownEnumPart;

    return result;
  }

  String getValidatedEnumFieldName(String name) {
    if (name.isEmpty) {
      name = 'null';
    }

    var result = name
        .replaceAll(RegExp(r'[^\w|\_|)]'), '_')
        .split('_')
        .where((element) => element.isNotEmpty)
        .map((String word) => word.toLowerCase().capitalize)
        .join();

    if (result.startsWith(RegExp('[0-9]+'))) {
      result = defaultEnumFieldName + result;
    }

    if (exceptionWords.contains(result.toLowerCase())) {
      return '\$' + result.lower;
    }

    return result.lower;
  }

  static List<String> getEnumNamesFromRequests(String swagger) {
    final enumNames = <String>[];
    final map = jsonDecode(swagger) as Map<String, dynamic>;
    final swaggerRoot = SwaggerRoot.fromJson(map);

    //Link defined parameters with requests
    swaggerRoot.paths.forEach((String key, SwaggerPath swaggerPath) {
      swaggerPath.requests.forEach((String req, SwaggerRequest swaggerRequest) {
        swaggerRequest.parameters = swaggerRequest.parameters
            .map((SwaggerRequestParameter parameter) =>
                getOriginalOrOverriddenRequestParameter(
                    parameter, swaggerRoot.components?.parameters ?? []))
            .toList();
      });
    });

    swaggerRoot.paths.forEach((String path, SwaggerPath swaggerPath) {
      swaggerPath.requests.forEach((requestType, swaggerRequest) {
        if (swaggerRequest.parameters.isEmpty) {
          return;
        }

        for (var p = 0; p < swaggerRequest.parameters.length; p++) {
          final swaggerRequestParameter = swaggerRequest.parameters[p];

          var name = SwaggerModelsGenerator.generateRequestEnumName(
              path, requestType, swaggerRequestParameter.name);

          if (enumNames.contains(name)) {
            continue;
          }

          final enumValues = swaggerRequestParameter.schema?.enumValues ??
              swaggerRequestParameter.items?.enumValues ??
              [];

          if (enumValues.isNotEmpty) {
            enumNames.add(name);
          }
        }
      });
    });

    return enumNames;
  }

  String generateEnumsContentFromModelProperties(
      String className, Map<String, SwaggerSchema> properties) {
    if (properties.isEmpty) {
      return '';
    }

    final results = <String>[];

    properties.forEach((String propertyKey, property) {
      if (property.type.isNotEmpty) {
        final result = generateEnumContentIfPossible(
            generateEnumName(className, propertyKey), property);

        if (result.isNotEmpty) {
          results.add(result);
        }
      }
    });

    return results.join('\n');
  }

  String generateEnumContentIfPossible(
    String enumName,
    SwaggerSchema schema,
  ) {
    enumName = SwaggerModelsGenerator.getValidatedClassName(enumName);

    if (schema.enumValues.isNotEmpty) {
      final enumMap = '''
\n\tconst \$${enumName}Map = {
\t${getEnumValuesMapContent(enumName, schema.enumValues)}
      };
      ''';

      return """
enum ${enumName.capitalize} {
\t@JsonValue('$defaultEnumValueName')\n  $defaultEnumValueName,
${generateEnumValuesContent(schema.enumValues)}
}

$enumMap
""";
    } else if (schema.items != null) {
      return generateEnumContentIfPossible(enumName, schema.items!);
    } else {
      return '';
    }
  }

  String generateEnumName(String className, String enumName) {
    return '${className.capitalize}${enumName.capitalize}';
  }

  String generateEnumValuesContent(List<dynamic> values) {
    return values
        .map((dynamic e) =>
            "\t@JsonValue('${e.toString().replaceAll("\$", "\\\$")}')\n  ${getValidatedEnumFieldName(e.toString())}")
        .join(',\n');
  }

  String generateEnumsFromSchema(
    String schemaName,
    SwaggerSchema schema,
  ) {
    if (schema.enumValues.isNotEmpty) {
      return generateEnumContentIfPossible(schemaName, schema);
    }

    if (schema.items?.enumValues.isNotEmpty == true) {
      return generateEnumContentIfPossible(schemaName, schema.items!);
    }
    Map<String, dynamic> properties;

    // if (map.containsKey('allOf')) {
    //   final allOf = map['allOf'] as List<dynamic>;
    //   var propertiesContainer = allOf.firstWhereOrNull(
    //         (e) => (e as Map<String, dynamic>).containsKey('properties'),
    //       ) as Map<String, dynamic>? ??
    //       {};

    //   if (propertiesContainer.isNotEmpty) {
    //     properties =
    //         propertiesContainer['properties'] as Map<String, dynamic>? ?? {};
    //   } else {
    //     properties = map['properties'] as Map<String, dynamic>? ?? {};
    //   }
    // } else {
    //   properties = map['properties'] as Map<String, dynamic>? ?? {};
    // }

    properties = schema.properties;

    if (properties.isEmpty) {
      return '';
    }

    return generateEnumsContentFromModelProperties(
        schemaName, schema.properties);
  }
}
