import 'package:code_builder/code_builder.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_response.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_path.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';
import 'package:recase/recase.dart';
import 'package:swagger_dart_code_generator/src/exception_words.dart';
import 'package:collection/collection.dart';

import 'constants.dart';

abstract class SwaggerRequestsGenerator {
  static const String defaultBodyParameter = 'Object';
  static const String requestTypeOptions = 'options';

  String generate(
      String code, String className, String fileName, GeneratorOptions options);

  String generateFileContent(String classContent, String chopperClientContent,
      String allMethodsContent) {
    final result = '''
$classContent
{
$chopperClientContent
$allMethodsContent
}''';

    return result;
  }

  Class generateService(
    SwaggerRoot swaggerRoot,
    String dartCode,
    String className,
    String fileName,
    GeneratorOptions options,
    bool hasModels,
    List<String> allEnumNames,
    Map<String, String> basicTypesMap,
  ) {
    final allMethodsContent = _getAllMethodsContent(
      swaggerRoot: swaggerRoot,
      options: options,
      basicTypesMap: basicTypesMap,
    );

    return Class(
      (c) => c
        ..methods.addAll(allMethodsContent)
        ..extend = Reference('ChopperService')
        ..docs.addAll([
          'azazazazazazazazaza'
        ])
        ..annotations.add(refer('ChopperApi').call([]))
        ..abstract = true
        ..name = className,
    );
  }

  List<Method> _getAllMethodsContent({
    required SwaggerRoot swaggerRoot,
    required GeneratorOptions options,
    required Map<String, String> basicTypesMap,
  }) {
    final methods = <Method>[];

    swaggerRoot.paths.forEach((String path, SwaggerPath swaggerPath) {
      swaggerPath.requests
          .forEach((String requestType, SwaggerRequest swaggerRequest) {
        if (requestType.toLowerCase() == requestTypeOptions) {
          return;
        }

        final methodName = _getRequestMethodName(
            requestType: requestType,
            swaggerRequest: swaggerRequest,
            path: path,
            options: options);

        final parameters = _getAllParameters(
          listParameters: swaggerRequest.parameters,
          ignoreHeaders: options.ignoreHeaders,
          path: path,
          requestType: requestType,
        );

        final returnTypeName = _getReturnTypeName(
          responses: swaggerRequest.responses,
          path: path,
          methodName: methodName,
          overridenResponses: options.responseOverrideValueMap
              .asMap()
              .map((key, value) => MapEntry(value.url, value)),
        );

        final returns = returnTypeName.isEmpty
            ? 'Future<chopper.Response>'
            : 'Future<chopper.Response<$returnTypeName>>';

        methods.add(Method((m) => m
          ..optionalParameters.addAll(parameters)
          ..name = methodName
          ..annotations.add(_getMethodAnnotation(requestType, path))
          ..returns = Reference(returns)));
      });
    });

    return methods;
  }

  Expression _getMethodAnnotation(String requestType, String path) {
    return refer(requestType.pascalCase)
        .call([], {'path': literalString(path)});
  }

  String getParameterCommentsForMethod(
          List<SwaggerRequestParameter> listParameters,
          GeneratorOptions options) =>
      listParameters
          .map((SwaggerRequestParameter parameter) => createSummaryParameters(
              parameter.name,
              parameter.description,
              parameter.inParameter,
              options))
          .where((String element) => element.isNotEmpty)
          .join('\n');

  String createSummaryParameters(
      String parameterName,
      String parameterDescription,
      String inParameter,
      GeneratorOptions options) {
    if (inParameter == kHeader && options.ignoreHeaders) {
      return '';
    }
    if (parameterDescription.isNotEmpty) {
      parameterDescription =
          parameterDescription.replaceAll(RegExp(r'\n|\r|\t'), ' ');
    } else {
      parameterDescription = '';
    }

    final comments = '''\t///@param $parameterName $parameterDescription''';
    return comments;
  }

  String abbreviationToCamelCase(String word) {
    var isLastLetterUpper = false;
    final result = word.split('').map((String e) {
      if (e.isUpper && !isLastLetterUpper) {
        isLastLetterUpper = true;
        return e;
      }

      isLastLetterUpper = e.isUpper;
      return e.toLowerCase();
    }).join();

    return result;
  }

  String getEnumParameter(String requestPath, String requestType,
      String parameterName, List<SwaggerRequestParameter> parameters,
      [String ref = '']) {
    final enumListParametersNames = parameters
        .where((parameter) =>
            parameter.type == kArray &&
            (parameter.items?.enumValues.isNotEmpty == true ||
                parameter.item?.enumValues.isNotEmpty == true ||
                parameter.schema?.enumValues.isNotEmpty == true))
        .map((e) => e.name)
        .toList();

    final mapName = getMapName(requestPath, requestType, parameterName, ref);

    if (enumListParametersNames.contains(parameterName)) {
      return '$parameterName!.map((element) {$mapName[element];}).toList()';
    }

    return '$mapName[$parameterName]';
  }

  String validateParameterName(String parameterName) {
    if (parameterName.isEmpty) {
      return parameterName;
    }

    parameterName = parameterName.replaceAll(',', '');

    var name = <String>[];
    exceptionWords.forEach((String element) {
      if (parameterName == element) {
        final result = '\$' + parameterName;
        name.add(result);
      }
    });
    if (name.isEmpty) {
      name =
          parameterName.split('-').map((String str) => str.capitalize).toList();
      name[0] = name[0].lower;
    }

    return name.join();
  }

  String validateParameterType(String parameterName) {
    var isEnum = false;

    if (parameterName.isEmpty) {
      return 'dynamic';
    }

    if (parameterName.startsWith('enums.')) {
      isEnum = true;
      parameterName = parameterName.replaceFirst('enums.', '');
    }

    final result = parameterName
        .split('-')
        .map((String str) => str.capitalize)
        .toList()
        .join();

    if (isEnum) {
      return 'enums.$result';
    } else {
      return result;
    }
  }

  String getParameterTypeName(String parameter, [String itemsType = '']) {
    switch (parameter) {
      case 'integer':
      case 'int':
        return 'int';
      case 'boolean':
        return 'bool';
      case 'string':
        return 'String';
      case 'array':
        return 'List<${getParameterTypeName(itemsType)}>';
      case 'file':
        return 'List<int>';
      case 'number':
        return 'num';
      case kObject:
        return 'Object';
      default:
        return validateParameterType(parameter);
    }
  }

  String getBodyParameter(SwaggerRequestParameter parameter, String path,
      String requestType, List<String> allEnumNames) {
    String parameterType;
    if (parameter.type.isNotEmpty) {
      parameterType = parameter.type;
    } else if (parameter.schema?.enumValues.isNotEmpty ?? false) {
      parameterType =
          'enums.${SwaggerModelsGenerator.generateRequestEnumName(path, requestType, parameter.name)}';
    } else if (parameter.schema?.originalRef.isNotEmpty ?? false) {
      parameterType = SwaggerModelsGenerator.getValidatedClassName(
          parameter.schema!.originalRef.toString());
    } else if (parameter.ref.isNotEmpty) {
      parameterType = parameter.ref.split('/').last;
      parameterType = parameterType.split('_').map((e) => e.capitalize).join();

      if (allEnumNames.contains('enums.$parameterType')) {
        parameterType = 'enums.$parameterType';
      }

      if (parameter.type == kArray) {
        parameterType = 'List<$parameterType>';
      }
    } else if (parameter.schema?.ref.isNotEmpty ?? false) {
      parameterType = parameter.schema!.ref.split('/').last;
    } else {
      parameterType = defaultBodyParameter;
    }

    parameterType = validateParameterType(parameterType);

    return "@${parameter.inParameter.capitalize}() ${parameter.isRequired ? "@required" : ""} $parameterType? ${validateParameterName(parameter.name)}";
  }

  String getDefaultParameter(
      SwaggerRequestParameter parameter, String path, String requestType) {
    String parameterType;
    if (parameter.schema?.enumValues.isNotEmpty ?? false) {
      parameterType =
          'enums.${SwaggerModelsGenerator.generateRequestEnumName(path, requestType, parameter.name)}';
    } else if (parameter.items?.enumValues.isNotEmpty ?? false) {
      final typeName =
          'enums.${SwaggerModelsGenerator.generateRequestEnumName(path, requestType, parameter.name)}';
      parameterType = 'List<$typeName>';
    } else {
      final neededType =
          parameter.type.isNotEmpty ? parameter.type : parameter.schema!.type;

      parameterType =
          getParameterTypeName(neededType, parameter.items?.type ?? '');
    }

    return "@${parameter.inParameter.capitalize}('${parameter.name}') ${parameter.isRequired ? "@required" : ""} $parameterType? ${validateParameterName(parameter.name)}";
  }

  String getChopperClientContent(String fileName, String host, String basePath,
      GeneratorOptions options, bool hadModels) {
    final baseUrlString = options.withBaseUrl
        ? "baseUrl:  'https://$host$basePath'"
        : '/*baseUrl: YOUR_BASE_URL*/';

    final converterString =
        options.withBaseUrl && options.withConverter && hadModels
            ? 'converter: JsonSerializableConverter(),'
            : 'converter: chopper.JsonConverter(),';

    final generatedChopperClient = '''
  static $fileName create([ChopperClient? client]) {
    if(client!=null){
      return _\$$fileName(client);
    }

    final newClient = ChopperClient(
      services: [_\$$fileName()],
      $converterString
      $baseUrlString);
    return _\$$fileName(newClient);
  }

''';
    return generatedChopperClient;
  }

  Expression _getParameterAnnotation(SwaggerRequestParameter parameter) {
    switch (parameter.inParameter) {
      case 'formData':
        return refer('Field').call([]);
      case 'path':
        return refer(parameter.inParameter)
            .call([literalString(parameter.name)]);
      default:
        return refer(parameter.inParameter.pascalCase).call([]);
    }
  }

  String _getParameterTypeFromRef(String ref) {
    return ref.split('/').last.pascalCase;
  }

  String _getEnumParameterTypeName({
    required String parameterName,
    required String path,
    required String requestType,
  }) {
    final pathString = path.split('/').map((e) => e.pascalCase).join();
    return 'enums.$pathString\$${requestType.pascalCase}\$${parameterName.pascalCase}';
  }

  String _getParameterTypeName({
    required SwaggerRequestParameter parameter,
    required String path,
    required String requestType,
  }) {
    if (parameter.items?.enumValues.isNotEmpty == true ||
        parameter.schema?.enumValues.isNotEmpty == true) {
      return _getEnumParameterTypeName(
          parameterName: parameter.name, path: path, requestType: requestType);
    } else if (parameter.items?.type.isNotEmpty == true) {
      return 'List<${_mapParameterName(parameter.items!.type)}>';
    } else if (parameter.schema?.ref.isNotEmpty == true) {
      return _getParameterTypeFromRef(parameter.schema!.ref);
    }
    final neededType = parameter.type.isNotEmpty
        ? parameter.type
        : parameter.schema?.type ?? '';

    return _mapParameterName(neededType);
  }

  String _mapParameterName(String name) {
    return kBasicTypesMap[name] ?? name.pascalCase;
  }

  List<Parameter> _getAllParameters({
    required List<SwaggerRequestParameter> listParameters,
    required bool ignoreHeaders,
    required String path,
    required String requestType,
  }) {
    final result = listParameters
        .where((swaggerParameter) =>
            ignoreHeaders ? swaggerParameter.inParameter != kHeader : true)
        .where((swaggerParameter) => swaggerParameter.inParameter.isNotEmpty)
        .map(
          (swaggerParameter) => Parameter(
            (p) => p
              ..name = swaggerParameter.name
              ..named = true
              ..required = true
              ..type = Reference(_getParameterTypeName(
                parameter: swaggerParameter,
                path: path,
                requestType: requestType,
              ))
              ..named = true
              ..annotations.add(
                _getParameterAnnotation(swaggerParameter),
              ),
          ),
        )
        .toList();

    return result;
  }

  String _getRequestMethodName({
    required SwaggerRequest swaggerRequest,
    required GeneratorOptions options,
    required String path,
    required String requestType,
  }) {
    if (options.usePathForRequestNames || swaggerRequest.operationId.isEmpty) {
      return SwaggerModelsGenerator.generateRequestName(path, requestType);
    } else {
      return swaggerRequest.operationId;
    }
  }

  SwaggerResponse? getSuccessedResponse(
      Map<String, SwaggerResponse> responses) {
    return responses.entries
        .firstWhereOrNull((responseEntry) =>
            successResponseCodes.contains(responseEntry.key) ||
            successDescriptions.contains(responseEntry.value.description))
        ?.value;
  }

  String _getResponseModelName({
    required String path,
    required String methodName,
  }) {
    final urlString = path.split('/').map((e) => e.pascalCase).join();
    final methodNamePart = methodName.pascalCase;

    return '$urlString$methodNamePart\$Response';
  }

  String? _getReturnTypeFromType(SwaggerResponse swaggerResponse) {
    final responseType = swaggerResponse.schema?.type ?? '';
    if (responseType.isEmpty) {
      return null;
    }

    if (responseType == kArray) {
      final itemsOriginalRef = swaggerResponse.schema?.items?.originalRef;
      final itemsType = swaggerResponse.schema?.items?.type;
      final arrayType = itemsOriginalRef ?? itemsType ?? kObject;
      final mappedArrayType = kBasicTypesMap[arrayType] ?? arrayType;

      if (mappedArrayType.isEmpty) {
        return null;
      }

      return 'List<$mappedArrayType>';
    }

    return responseType;
  }

  String _getRef(String ref) {
    return ref.split('/').last.pascalCase;
  }

  String? _getReturnTypeFromSchema(SwaggerResponse swaggerResponse) {
    final listRef = swaggerResponse.schema?.items?.ref ?? '';

    if (listRef.isNotEmpty) {
      return 'List<${_getRef(listRef)}>';
    }

    final ref = swaggerResponse.schema?.ref ?? swaggerResponse.ref;

    if (ref.isNotEmpty) {
      return _getRef(ref);
    }
    return null;
  }

  String? _getReturnTypeFromOriginalRef(SwaggerResponse swaggerResponse) {
    if (swaggerResponse.schema?.originalRef.isNotEmpty == true) {
      return swaggerResponse.schema?.originalRef;
    }

    return null;
  }

  String? _getReturnTypeFromContent(SwaggerResponse swaggerResponse) {
    if (swaggerResponse.content.isNotEmpty) {
      final ref = swaggerResponse.content.first.ref;
      if (ref.isNotEmpty) {
        final type = _getRef(ref);
        return kBasicTypesMap[type] ?? type;
      }

      final responseType = swaggerResponse.content.first.responseType;

      if (responseType.isNotEmpty) {
        if (responseType == kArray) {
          final originalRef = swaggerResponse.schema?.items?.originalRef ?? '';

          if (originalRef.isNotEmpty) {
            return 'List<${kBasicTypesMap[originalRef]}>';
          }

          final ref = swaggerResponse.content.firstOrNull?.items?.ref ?? '';
          if (ref.isNotEmpty) {
            return 'List<${kBasicTypesMap[ref]}>';
          }
        }

        return kBasicTypesMap[responseType] ?? responseType;
      }
    }
  }

  String _getReturnTypeName({
    required Map<String, SwaggerResponse> responses,
    required Map<String, ResponseOverrideValueMap> overridenResponses,
    required String path,
    required String methodName,
  }) {
    if (overridenResponses.containsKey(path)) {
      return overridenResponses[path]!.overriddenValue;
    }

    final neededResponse = getSuccessedResponse(responses);

    if (neededResponse == null) {
      return '';
    }

    if (neededResponse.schema?.type == kObject &&
        neededResponse.schema?.properties.isNotEmpty == true) {
      return _getResponseModelName(path: path, methodName: methodName);
    }

    final type = _getReturnTypeFromType(neededResponse) ??
        _getReturnTypeFromSchema(neededResponse) ??
        _getReturnTypeFromOriginalRef(neededResponse) ??
        _getReturnTypeFromContent(neededResponse);

    return type ?? '';
  }

  String getMapName(
      String path, String requestType, String parameterName, String ref) {
    if (ref.isNotEmpty) {
      return 'enums.\$${ref.split('/').lastOrNull?.pascalCase}Map';
    }

    final enumName = SwaggerModelsGenerator.generateRequestEnumName(
        path, requestType, parameterName);

    return 'enums.\$${enumName}Map';
  }
}
