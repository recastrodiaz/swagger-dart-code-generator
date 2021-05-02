import 'package:swagger_dart_code_generator/src/code_generators/swagger_requests_generator.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/parameter_item.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_parameter_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_items.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:test/test.dart';

import '../code_examples.dart';

void main() {
  final generator = SwaggerRequestsGenerator();
  const fileName = 'order_service';
  const className = 'OrderSerice';


  group('Tests for parameters', () {
    test('Should ignore headers if option is true', () {
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
