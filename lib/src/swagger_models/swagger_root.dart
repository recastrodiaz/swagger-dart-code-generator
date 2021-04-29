import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/requests/swagger_request_parameter.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_components.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_info.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_path.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_tag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_root.g.dart';

@JsonSerializable()
class SwaggerRoot {
  SwaggerRoot(
      {this.basePath = '',
      this.components,
      this.info,
      this.host = '',
      this.paths = const {},
      this.tags = const [],
      this.schemes = const [],
      this.parameters = const []});

  @JsonKey(name: 'info')
  SwaggerInfo? info;

  @JsonKey(name: 'host', defaultValue: '')
  String host;

  @JsonKey(name: 'basePath', defaultValue: '')
  String basePath;

  @JsonKey(name: 'tags', defaultValue: [])
  List<SwaggerTag> tags;

  @JsonKey(name: 'schemes', defaultValue: [])
  List<String> schemes;

  @JsonKey(name: 'paths', defaultValue: {}, fromJson: _mapPaths)
  Map<String, SwaggerPath> paths;

  @JsonKey(name: 'parameters', defaultValue: [])
  List<SwaggerRequestParameter> parameters;

  @JsonKey(name: 'components')
  SwaggerComponents? components;

  Map<String, dynamic> toJson() => _$SwaggerRootToJson(this);

  factory SwaggerRoot.fromJson(Map<String, dynamic> json) =>
      _$SwaggerRootFromJson(json);
}

Map<String, SwaggerPath> _mapPaths(Map<String, dynamic> paths) {
  return paths.map((path, pathValue) {
    final value = pathValue as Map<String, dynamic>;
    final parameters = value['parameters'] as Map<String, dynamic>?;
    value.removeWhere((key, value) => key == 'parameters');

    return MapEntry(
      path,
      SwaggerPath(
        parameters: parameters?.map((key, parameter) => MapEntry(
                key,
                SwaggerRequestParameter.fromJson(
                    parameter as Map<String, dynamic>))) ??
            {},
        requests: value.map(
          (key, request) => MapEntry(
            key,
            SwaggerRequest.fromJson(request as Map<String, dynamic>),
          ),
        ),
      ),
    );
  });
}
