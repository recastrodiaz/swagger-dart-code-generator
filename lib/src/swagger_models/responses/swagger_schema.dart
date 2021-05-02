import 'package:json_annotation/json_annotation.dart';

part 'swagger_schema.g.dart';

@JsonSerializable()
class SwaggerSchema {
  SwaggerSchema({
    required this.type,
    required this.originalRef,
    required this.enumValue,
    required this.properties,
    required this.items,
    required this.ref,
    required this.defaultValue,
    required this.format,
  });

  @JsonKey(name: 'type', defaultValue: '')
  String type;

  @JsonKey(name: 'format', defaultValue: '')
  String format;

  @JsonKey(name: 'default', defaultValue: '')
  String defaultValue;

  @JsonKey(name: 'originalRef', defaultValue: '')
  String originalRef;

  @JsonKey(name: '\$ref', defaultValue: '')
  String ref;

  @JsonKey(name: 'enum', defaultValue: [])
  List<String> enumValue;

  @JsonKey(name: 'items')
  SwaggerSchema? items;

  @JsonKey(name: 'properties', defaultValue: {})
  Map<String, SwaggerSchema> properties;

  factory SwaggerSchema.fromJson(Map<String, dynamic> json) =>
      _$SwaggerSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSchemaToJson(this);
}
