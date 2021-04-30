import 'package:swagger_dart_code_generator/src/code_generators/v3/swagger_requests_generator_v3.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/parameter_item.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_parameter_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_items.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_response.dart';
import 'package:test/test.dart';

import '../code_examples.dart';

void main() {
  final generator = SwaggerRequestsGeneratorV3();
  const fileName = 'order_service';
  const className = 'OrderSerice';

  group('Tests for getDefaultParameter', () {
    test('Should use parameter -> schema -> enumValues', () {
      final parameter = SwaggerRequestParameter(
          isRequired: true,
          inParameter: 'query',
          name: 'number',
          schema: SwaggerParameterSchema(enumValues: ['one', 'two']));

      final result = generator.getDefaultParameter(parameter, '/path', 'get');

      expect(result,
          equals('@Query(\'number\') @required enums.PathGetNumber? number'));
    });

    test('Should use parameter -> items -> enumValues', () {
      final parameter = SwaggerRequestParameter(
          isRequired: true,
          inParameter: 'query',
          name: 'number',
          items: SwaggerRequestItems(enumValues: ['one', 'two']));

      final result = generator.getDefaultParameter(parameter, '/path', 'get');

      expect(
          result,
          equals(
              '@Query(\'number\') @required List<enums.PathGetNumber>? number'));
    });
  });

  group('Tests for additional methids', () {
    test('Should transform "parametersGET1" to "parametersGet1"', () {
      const str = 'parametersGET1';
      final result = generator.abbreviationToCamelCase(str);

      expect(result, equals('parametersGet1'));
    });

    test('Should get parameter summary', () {
      const name = 'orderId';
      const description = 'Id of the order';
      final result = generator.createSummaryParameters(name, description,
          'query', GeneratorOptions(inputFolder: '', outputFolder: ''));

      expect(result, contains('///@param orderId Id of the order'));
    });

    test('Should get parameter type name', () {
      final result = generator.getParameterTypeName('array', 'integer');

      expect(result, contains('List<int>'));
    });

    test('Should get validate name', () {
      const name = 'x-application';
      final result = generator.validateParameterName(name);

      expect(result, contains('xApplication'));
    });

    test('Should add \$ if name is key word', () {
      const name = 'null';
      final result = generator.validateParameterName(name);

      expect(result, contains('\$null'));
    });

    test('Should create chopper client', () {
      const name = 'OrderService';
      const host = 'some.host';
      const path = '/path';
      final result = generator.getChopperClientContent(name, host, path,
          GeneratorOptions(inputFolder: '', outputFolder: ''), true);

      expect(result, contains('static OrderService create'));
      expect(result, contains('services: [_\$OrderService()],'));
    });
  });

  group('Tests for parameters', () {
    test('Should ignore headers if option is true', () {
      final result = generator.generate(
          aaa,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: true,
            inputFolder: '',
            outputFolder: '',
          ));

      final isContainHeader = result.contains('@Header');

      expect(isContainHeader, equals(false));
    });

    test('Should generate response from ref for Dynamic types', () {
      final result = generator.generate(
          request_with_ref_response,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: true,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('Response<Object>'));
    });

    test('Should accept requestBody enum', () {
      final result = generator.generate(
          request_with_enum_request_body,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: true,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('@Body() @required String? body'));
    });

    test('Should generate method name from path if such option is true', () {
      final result = generator.generate(
          request_with_header,
          className,
          fileName,
          GeneratorOptions(
            usePathForRequestNames: true,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('v2OrderSummariesGet'));
    });

    test('Should NOT ignore headers if option is true', () {
      final result = generator.generate(
          request_with_header,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      final isContainHeader = result.contains('@Header');

      expect(isContainHeader, equals(true));
    });

    test(
        'Should generate List<String> for query parameters type array and items.type string',
        () {
      final result = generator.generate(
          request_with_array_string,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('List<String>? applications'));
    });

    test(
        'Should generate List<String> for query parameters type array and items.type string',
        () {
      final result = generator.generate(
          request_with_array_item_summary,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('Future<chopper.Response<List<ItemSummary>>>'));
    });
  });

  group('Tests for getReturnTypeName', () {
    test(
        'Should generate List<String> for return type parameters type array and items.type string',
        () {
      final result = generator.generate(
          request_with_list_string_return_type,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('Future<chopper.Response<List<String>>>'));
    });

    test('Should generate MyObject if ref is #definitions/MyObject', () {
      final result = generator.generate(
          request_with_object_ref_response,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('Future<chopper.Response<MyObject>>'));
    });

    test(
        'Should generate List<TestItem> for return type parameters type array and items.type string',
        () {
      final result = generator.generate(
          request_with_list_test_item_return_type,
          className,
          fileName,
          GeneratorOptions(
            ignoreHeaders: false,
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result, contains('Future<chopper.Response<List<TestItem>>>'));
    });

    test(
        'Should generate List<OverriddenType> for return type parameters type array and items.type string',
        () {
      final result = generator.generate(
          request_with_list_test_item_return_type,
          className,
          fileName,
          GeneratorOptions(
              ignoreHeaders: false,
              inputFolder: '',
              outputFolder: '',
              responseOverrideValueMap: <ResponseOverrideValueMap>[
                ResponseOverrideValueMap(
                    method: 'get',
                    url: '/model/items',
                    overriddenValue: 'List<OverriddenType>')
              ]));

      expect(
          result, contains('Future<chopper.Response<List<OverriddenType>>>'));
    });

    test('Should generate return type by originalRef', () {
      final result = generator.generate(
          request_with_original_ref_return_type,
          className,
          fileName,
          GeneratorOptions(
              ignoreHeaders: false, inputFolder: '', outputFolder: ''));

      expect(result, contains('Future<chopper.Response<TestItem>>'));
    });

    test(
        'Should generate return type by content -> first -> responseType originalRef',
        () {
      final result = generator.generate(
          request_with_content_first_response_type,
          className,
          fileName,
          GeneratorOptions(
              ignoreHeaders: false, inputFolder: '', outputFolder: ''));

      expect(result, contains('Future<chopper.Response<String>>'));
    });

    test('Should generate return type by content -> first -> responseType ref',
        () {
      final result = generator.generate(
          request_with_content_first_response_ref,
          className,
          fileName,
          GeneratorOptions(
              ignoreHeaders: false, inputFolder: '', outputFolder: ''));

      expect(result,
          contains('Future<chopper.Response<TestType>> getModelItems();'));
    });
  });

  group('Tests for getBodyParameter', () {
    test('Should return MyObject from schema->ref', () {
      final parameter = SwaggerRequestParameter(
          inParameter: 'body',
          name: 'myName',
          isRequired: true,
          schema: SwaggerParameterSchema(ref: '#definitions/MyObject'));
      final result = generator.getBodyParameter(parameter, 'path', 'type', []);

      expect(result, equals('@Body() @required MyObject? myName'));
    });
  });

  group('Tests for getEnumParameter', () {
    test('Should generate enum parameter from items -> enum values', () {
      final result = generator.getEnumParameter('path', 'get', 'myParameter', [
        SwaggerRequestParameter(
            type: 'array',
            items: SwaggerRequestItems(enumValues: ['one', 'two']))
      ]);

      expect(result, equals('enums.\$PathGetMyParameterMap[myParameter]'));
    });

    test('Should generate enum parameter from item -> enum values', () {
      final result = generator.getEnumParameter('path', 'get', 'myParameter', [
        SwaggerRequestParameter(
          item: ParameterItem(enumValues: ['one', 'two']),
          type: 'array',
        )
      ]);

      expect(result, equals('enums.\$PathGetMyParameterMap[myParameter]'));
    });

    test('Should generate enum parameter from schema -> enum values', () {
      final result = generator.getEnumParameter('path', 'get', 'myParameter', [
        SwaggerRequestParameter(
          schema: SwaggerParameterSchema(enumValues: ['one', 'two']),
          type: 'array',
        )
      ]);

      expect(result, equals('enums.\$PathGetMyParameterMap[myParameter]'));
    });

    test('Should', () {
      final result = generator.getEnumParameter('path', 'get', 'myParameter', [
        SwaggerRequestParameter(
          name: 'myParameter',
          schema: SwaggerParameterSchema(
            enumValues: ['one', 'two'],
          ),
          type: 'array',
        )
      ]);

      expect(
          result,
          equals(
              'myParameter!.map((element) {enums.\$PathGetMyParameterMap[element];}).toList()'));
    });
  });

  group('Tests for models from responses', () {
    test('Should generate correct response type name', () {
      final result = generator.generate(
          request_with_return_type_injected,
          'MyService',
          'my_service',
          GeneratorOptions(
            inputFolder: '',
            outputFolder: '',
          ));

      expect(result,
          contains('Future<chopper.Response<ModelItemsGet\$Response>>'));
    });
  });
}
