import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_schema.dart';

part 'swagger_components.g.dart';

@JsonSerializable()
class SwaggerComponents {
  SwaggerComponents({
    required this.parameters,
    required this.schemas,
  });

  @JsonKey(name: 'parameters', defaultValue: [])
  List<SwaggerRequestParameter> parameters;

  @JsonKey(name: 'schemas', defaultValue: {})
  Map<String, SwaggerSchema> schemas;

  Map<String, dynamic> toJson() => _$SwaggerComponentsToJson(this);

  factory SwaggerComponents.fromJson(Map<String, dynamic> json) =>
      _$SwaggerComponentsFromJson(json);
}
