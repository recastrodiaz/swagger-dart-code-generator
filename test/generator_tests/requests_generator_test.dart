import 'dart:convert';

import 'package:swagger_dart_code_generator/src/code_generators/swagger_requests_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v2/swagger_models_generator_v2.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';
import 'package:test/test.dart';

import '../code_examples.dart';

void main() {
  final generator = SwaggerRequestsGenerator();
  final modelsGenerator = SwaggerModelsGeneratorV2();
  const fileName = 'order_service';
  const className = 'OrderSerice';

  group('Tests for parameters', () {
    test('Should ignore headers if option is true', () {
      var tt = jsonDecode(aaa) as Map<String, dynamic>;

      final root = SwaggerRoot.fromJson(tt);

      final result2 = modelsGenerator.generate(aaa, 'fileName', GeneratorOptions(inputFolder: '', outputFolder: ''));

      final result = generator.generate(
          code: aaa,
          className: className,
          fileName: fileName,
          options: GeneratorOptions(
            ignoreHeaders: true,
            inputFolder: '',
            outputFolder: '',
          ));

      final isContainHeader = result.contains('@Header');

      expect(isContainHeader, equals(false));
    });
  });
}
