import 'dart:convert';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';

class SwaggerModelsGeneratorV2 extends SwaggerModelsGenerator {
  @override
  String generate(String dartCode, String fileName, GeneratorOptions options) {

    final map = jsonDecode(dartCode) as Map<String, dynamic>;
    final root = SwaggerRoot.fromJson(map);
    
    return generateBase(root: root, fileName: fileName, options: options, classes: root.definitions);
  }

  @override
  String generateResponses(
      String dartCode, String fileName, GeneratorOptions options) {
    return '';
  }

  @override
  String generateRequestBodies(
      String dartCode, String fileName, GeneratorOptions options) {
    return '';
  }
}
