import 'dart:convert';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
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

abstract class SwaggerRequestsGenerator {
  static const String defaultBodyParameter = 'Object';
  static const String requestTypeOptions = 'options';
  static final List<String> successResponseCodes = [
    '200',
    '201',
  ];
  static final List<String> successDescriptions = [
    'Success',
    'OK',
    'default response'
  ];

  final _kBasicTypesMap = const <String, String>{
    'integer': 'int',
    'int': 'int',
    'boolean': 'bool',
    'bool': 'bool',
    'string': 'String',
    'file': 'List<String>',
    'number': 'num',
    'object': 'Object',
  };

  static const _kObject = 'object';
  static const _kHeader = 'header';
  static const _kArray = 'array';

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

  String getFileContent(
    SwaggerRoot swaggerRoot,
    String dartCode,
    String className,
    String fileName,
    GeneratorOptions options,
    bool hasModels,
    List<String> allEnumNames,
    List<String> dynamicResponses,
    Map<String, String> basicTypesMap,
  ) {
    final classContent =
        getRequestClassContent(swaggerRoot.host, className, fileName, options);
    final chopperClientContent = getChopperClientContent(
        className, swaggerRoot.host, swaggerRoot.basePath, options, hasModels);
    final allMethodsContent = getAllMethodsContent(
      swaggerRoot,
      dartCode,
      options,
      allEnumNames,
      dynamicResponses,
      basicTypesMap,
    );
    final result = generateFileContent(
        classContent, chopperClientContent, 'allMethodsContent');

    return result;
  }

  static List<String> getAllDynamicResponses(String dartCode) {
    final dynamic map = jsonDecode(dartCode);

    final components = map['components'] as Map<String, dynamic>?;
    final responses = components == null
        ? null
        : components['responses'] as Map<String, dynamic>?;

    if (responses == null) {
      return [];
    }

    var results = <String>[];

    responses.keys.forEach((key) {
      final response = responses[key] as Map<String, dynamic>?;

      final content = response == null
          ? null
          : response['content'] as Map<String, dynamic>?;

      if (content != null && content.entries.length > 1) {
        results.add(key.capitalize);
      }
    });

    return results;
  }

  List<Method> getAllMethodsContent(
    SwaggerRoot swaggerRoot,
    GeneratorOptions options,
    List<String> allEnumNames,
    List<String> dynamicResponses,
    Map<String, String> basicTypesMap,
  ) {
    final methods = <Method>[];

    swaggerRoot.paths.forEach((String path, SwaggerPath swaggerPath) {
      swaggerPath.requests
          .forEach((String requestType, SwaggerRequest swaggerRequest) {
        if (requestType.toLowerCase() == requestTypeOptions) {
          return;
        }

        final hasFormData = swaggerRequest.parameters.any(
            (SwaggerRequestParameter swaggerRequestParameter) =>
                swaggerRequestParameter.inParameter == 'formData');

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
            swaggerRequest.responses.values.toList(),
            path,
            requestType,
            options.responseOverrideValueMap,
            dynamicResponses,
            basicTypesMap);

        final method = _generateRequestMethod();

        // final generatedMethod = getMethodContent(
        //     summary: swaggerRequest.summary,
        //     typeRequest: requestType,
        //     methodName: methodName,
        //     parametersContent: allParametersContent,
        //     parametersComments: parameterCommentsForMethod,
        //     requestPath: path,
        //     hasFormData: hasFormData,
        //     returnType: returnTypeName,
        //     hasEnums: true,
        //     enumInBodyName: enumInBodyName?.name ?? '',
        //     ignoreHeaders: options.ignoreHeaders,
        //     allEnumNames: allEnumNames,
        //     parameters: swaggerRequest.parameters);

        methods.add(Method((m) => m
          ..requiredParameters.addAll(parameters)
          ..name = methodName
          ..returns = Reference(returnTypeName)));
      });
    });

    return methods;
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
    if (inParameter == _kHeader && options.ignoreHeaders) {
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

  String generatePublicMethod(
      String methodName,
      String returnTypeString,
      String parametersPart,
      String requestType,
      String requestPath,
      bool ignoreHeaders,
      List<SwaggerRequestParameter> parameters,
      List<String> allEnumNames) {
    final filteredParameters = parameters
        .where((parameter) =>
            ignoreHeaders ? parameter.inParameter != _kHeader : true)
        .toList();

    final enumParametersNames = parameters
        .where((parameter) => (parameter.items?.enumValues.isNotEmpty == true ||
            parameter.item?.enumValues.isNotEmpty == true ||
            parameter.schema?.enumValues.isNotEmpty == true ||
            allEnumNames.contains(
                'enums.${parameter.ref.isNotEmpty ? parameter.ref.split("/").last.pascalCase : ""}')))
        .map((e) => e.name)
        .toList();

    final newParametersPart = parametersPart
        .replaceAll(RegExp(r'@\w+\(\)'), '')
        .replaceAll(RegExp(r"@\w+\(\'\w+\'\)"), '')
        .trim();

    final result =
        '''\tFuture<Response$returnTypeString> ${abbreviationToCamelCase(methodName.camelCase)}($newParametersPart){
          return _${methodName.camelCase}(${filteredParameters.map((e) => "${validateParameterName(e.name)} : ${enumParametersNames.contains(e.name) ? getEnumParameter(requestPath, requestType, e.name, filteredParameters, e.ref) : validateParameterName(e.name)}").join(', ')});
          }'''
            .replaceAll('@required', '');

    return result;
  }

  String getEnumParameter(String requestPath, String requestType,
      String parameterName, List<SwaggerRequestParameter> parameters,
      [String ref = '']) {
    final enumListParametersNames = parameters
        .where((parameter) =>
            parameter.type == _kArray &&
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

  String getMethodContent({
    required String summary,
    required String typeRequest,
    required String methodName,
    required String parametersContent,
    required String parametersComments,
    required String requestPath,
    required bool hasFormData,
    required String returnType,
    required bool hasEnums,
    required String enumInBodyName,
    required bool ignoreHeaders,
    required List<SwaggerRequestParameter> parameters,
    required List<String> allEnumNames,
  }) {
    var typeReq = typeRequest.capitalize + "(path: '$requestPath')";
    if (hasFormData) {
      typeReq +=
          '\n  @FactoryConverter(request: FormUrlEncodedConverter.requestFactory)';
    }

    if (returnType.isNotEmpty && returnType != 'num') {
      returnType = returnType.pascalCase;
    }

    final returnTypeString = returnType.isNotEmpty ? '<$returnType>' : '';
    var parametersPart =
        parametersContent.isEmpty ? '' : '{$parametersContent}';

    if (summary.isNotEmpty) {
      summary = summary.replaceAll(RegExp(r'\n|\r|\t'), ' ');
    }

    methodName = abbreviationToCamelCase(methodName.camelCase);
    var publicMethod = '';

    if (hasEnums) {
      publicMethod = generatePublicMethod(
              methodName,
              returnTypeString,
              parametersPart,
              typeRequest,
              requestPath,
              ignoreHeaders,
              parameters,
              allEnumNames)
          .trim();

      allEnumNames.forEach((element) {
        parametersPart = parametersPart.replaceFirst('$element? ', 'String? ');
        parametersPart = parametersPart.replaceFirst('$element>?', 'String?>?');
      });

      parametersPart = parametersPart
          .replaceAll('enums.', '')
          .replaceAll('List<enums.', 'List<');

      methodName = '_$methodName';
    }

    final generatedMethod = """
\t///$summary  ${parametersComments.isNotEmpty ? """\n$parametersComments""" : ''}
\t$publicMethod

\t@$typeReq
\tFuture<chopper.Response$returnTypeString> $methodName($parametersPart);
""";

    return generatedMethod;
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
      case _kObject:
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

      if (parameter.type == _kArray) {
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

  String getParameterContent(
      {required SwaggerRequestParameter parameter,
      required bool ignoreHeaders,
      required String requestType,
      required String path,
      required List<String> allEnumNames,
      required bool useRequiredAttribute}) {
    final parameterType = validateParameterType(parameter.name);
    switch (parameter.inParameter) {
      case 'body':
        return getBodyParameter(parameter, path, requestType, allEnumNames);
      case 'formData':
        final isEnum = parameter.schema?.enumValues.isNotEmpty ?? false;

        return "@Field('${parameter.name}') ${parameter.isRequired ? "@required" : ""} ${isEnum ? 'enums.$parameterType?' : getParameterTypeName(parameter.type)}? ${validateParameterName(parameter.name)}";
      case 'header':
        final needRequiredAttribute =
            parameter.isRequired && useRequiredAttribute;
        return ignoreHeaders
            ? ''
            : "@${parameter.inParameter.capitalize}('${parameter.name}') ${needRequiredAttribute ? "required" : ""} String? ${validateParameterName(parameter.name)}";
      case 'cookie':
        return '';
      default:
        return getDefaultParameter(parameter, path, requestType);
    }
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

  String getRequestClassContent(String host, String className, String fileName,
      GeneratorOptions options) {
    final classWithoutChopper = '''
@ChopperApi()
abstract class $className extends ChopperService''';

    return classWithoutChopper;
  }

  Expression _getParameterAnnotation(SwaggerRequestParameter parameter) {
    String annotation;
    switch (parameter.inParameter) {
      case 'body':
        annotation = 'Body';
        break;
      case 'formData':
        annotation = 'Field';
        break;
      case _kHeader:
        annotation = 'Header';
        break;
      default:
        annotation = parameter.inParameter.pascalCase;
    }

    return refer(annotation).call([literalString(parameter.name)]);
  }

  String _getParameterTypeFromRef(String ref) {
    return ref.split('/').last.pascalCase;
  }

  String _getEnumParameterTypeName(
      {required String parameterName,
      required String path,
      required String requestType}) {
    return 'enums.${path.split('/').map((e) => e.pascalCase).join()}\$${requestType.pascalCase}\$${parameterName.pascalCase}';
  }

  String _getParameterTypeName(
      {required SwaggerRequestParameter parameter,
      required String path,
      required String requestType}) {
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
    return _kBasicTypesMap[name] ?? name.pascalCase;
  }

  List<Parameter> _getAllParameters({
    required List<SwaggerRequestParameter> listParameters,
    required bool ignoreHeaders,
    required String path,
    required String requestType,
  }) {
    final result = listParameters
        .where((swaggerParameter) =>
            ignoreHeaders ? swaggerParameter.inParameter != _kHeader : true)
        .where((swaggerParameter) => swaggerParameter.inParameter.isNotEmpty)
        .map(
          (swaggerParameter) => Parameter(
            (p) => p
              ..name = swaggerParameter.name
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

    final animal = Class((c) => c
      ..methods.add(Method((m) => m
        ..requiredParameters.addAll(result)
        ..name = 'someMethod'))
      ..name = 'ClassName');

    final tt = animal.accept(DartEmitter()).toString();

    return result;

    //return listParameters;
    // .map((SwaggerRequestParameter parameter) => getParameterContent(
    //       parameter: parameter,
    //       ignoreHeaders: ignoreHeaders,
    //       path: path,
    //       allEnumNames: allEnumNames,
    //       requestType: requestType,
    //       useRequiredAttribute: useRequiredAttribute,
    //     ))
    // .where((String element) => element.isNotEmpty)
    // .join(', ');
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

  SwaggerResponse getSuccessedResponse(List<SwaggerResponse> responses) {
    return responses.firstWhere(
      (SwaggerResponse response) =>
          successDescriptions.contains(response.description) ||
          successResponseCodes.contains(response.code),
    );
  }

  String getResponseModelName(String url, String methodName) {
    final urlString = url.split('/').map((e) => e.pascalCase).join();
    final methodNamePart = methodName.pascalCase;

    return '$urlString$methodNamePart\$Response';
  }

  String? _getReturnTypeFromType(SwaggerResponse swaggerResponse) {
    final responseType = swaggerResponse.schema?.type ?? '';
    if (responseType.isEmpty) {
      return null;
    }

    if (responseType == _kArray) {
      final itemsOriginalRef = swaggerResponse.schema?.items?.originalRef;
      final itemsType = swaggerResponse.schema?.items?.type;
      final arrayType = itemsOriginalRef ?? itemsType ?? _kObject;
      final mappedArrayType = _kBasicTypesMap[arrayType] ?? arrayType;

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
        return _kBasicTypesMap[type] ?? type;
      }

      final responseType = swaggerResponse.content.first.responseType;

      if (responseType.isNotEmpty) {
        if (responseType == _kArray) {
          final originalRef = swaggerResponse.schema?.items?.originalRef ?? '';

          if (originalRef.isNotEmpty) {
            return 'List<${_kBasicTypesMap[originalRef]}>';
          }

          final ref = swaggerResponse.content.firstOrNull?.items?.ref ?? '';
          if (ref.isNotEmpty) {
            return 'List<${_kBasicTypesMap[ref]}>';
          }
        }

        return _kBasicTypesMap[responseType] ?? responseType;
      }
    }
  }

  String _getReturnTypeName({
    required List<SwaggerResponse> responses,
    required Map<String, ResponseOverrideValueMap> overridenResponses,
    required String path,
    required String methodName,
  }) {
    if (overridenResponses.containsKey(path)) {
      return overridenResponses[path]!.overriddenValue;
    }

    final neededResponse = getSuccessedResponse(responses);

    if (neededResponse.schema?.type == _kObject &&
        neededResponse.schema?.properties.isNotEmpty == true) {
      return getResponseModelName(path, methodName);
    }

    var type = _getReturnTypeFromType(neededResponse);
    if (type != null) {
      return type;
    }

    type = _getReturnTypeFromSchema(neededResponse);
    if (type != null) {
      return type;
    }

    type = _getReturnTypeFromOriginalRef(neededResponse);
    if (type != null) {
      return type;
    }

    type = _getReturnTypeFromContent(neededResponse);
    if (type != null) {
      return type;
    }

    return '';
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
