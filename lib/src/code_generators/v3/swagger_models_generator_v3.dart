import 'dart:convert';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';

class SwaggerModelsGeneratorV3 extends SwaggerModelsGenerator {
  @override
  String generate(String dartCode, String fileName, GeneratorOptions options) {
    final map = jsonDecode(dartCode) as Map<String, dynamic>;

    final root = SwaggerRoot.fromJson(map);

    final schemas = root.components!.schemas;

    return generateBase(
        root: root, fileName: fileName, options: options, classes: schemas);
  }

  @override
  Map<String, dynamic> getModelProperties(Map<String, dynamic> modelMap) {
    if (!modelMap.containsKey('allOf')) {
      return modelMap['properties'] as Map<String, dynamic>? ?? {};
    }

    final allOf = modelMap['allOf'] as List<dynamic>;

    final newModelMap = allOf.firstWhere(
      (m) => (m as Map<String, dynamic>).containsKey('properties'),
      orElse: () => null,
    );

    if (newModelMap == null) {
      return {};
    }

    final currentProperties = newModelMap['properties'] as Map<String, dynamic>;

    return currentProperties;
  }

  @override
  String getExtendsString(Map<String, dynamic> map) {
    if (map.containsKey('allOf')) {
      final allOf = map['allOf'] as List<dynamic>;
      final refItem = allOf
          .firstWhere((m) => (m as Map<String, dynamic>).containsKey('\$ref'));

      final ref = refItem['\$ref'].toString().split('/').last;

      final className = SwaggerModelsGenerator.getValidatedClassName(ref);

      return 'extends $className';
    }

    return '';
  }
}
