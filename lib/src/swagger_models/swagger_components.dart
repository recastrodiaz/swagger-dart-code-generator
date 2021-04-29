import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_components.g.dart';

@JsonSerializable()
class SwaggerComponents {
  SwaggerComponents({this.parameters = const []});

@JsonKey(name: 'parameters', defaultValue: [])
  List<SwaggerRequestParameter> parameters;

  
Map<String, dynamic> toJson() => _$SwaggerComponentsToJson(this);

  factory SwaggerComponents.fromJson(Map<String, dynamic> json) =>
      _$SwaggerComponentsFromJson(json);
  
}
