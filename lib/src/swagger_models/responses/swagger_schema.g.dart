// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSchema _$SwaggerSchemaFromJson(Map<String, dynamic> json) {
  return SwaggerSchema(
    type: json['type'] as String? ?? '',
    originalRef: json['originalRef'] as String? ?? '',
    enumValue:
        (json['enum'] as List<dynamic>?)?.map((e) => e as String).toList() ??
            [],
    properties: (json['properties'] as Map<String, dynamic>?)?.map(
          (k, e) =>
              MapEntry(k, SwaggerSchema.fromJson(e as Map<String, dynamic>)),
        ) ??
        {},
    items: json['items'] == null
        ? null
        : SwaggerSchema.fromJson(json['items'] as Map<String, dynamic>),
    ref: json[r'$ref'] as String? ?? '',
    defaultValue: json['default'] as String? ?? '',
    format: json['format'] as String? ?? '',
  );
}

Map<String, dynamic> _$SwaggerSchemaToJson(SwaggerSchema instance) =>
    <String, dynamic>{
      'type': instance.type,
      'format': instance.format,
      'default': instance.defaultValue,
      'originalRef': instance.originalRef,
      r'$ref': instance.ref,
      'enum': instance.enumValue,
      'items': instance.items,
      'properties': instance.properties,
    };
