// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_swagger.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'] as int? ?? 36,
    petId: json['petId'] as int? ?? 36,
    quantity: json['quantity'] as int? ?? 36,
    shipDateTime: json['shipDateTime'] == null
        ? null
        : DateTime.parse(json['shipDateTime'] as String),
    shipDate: json['shipDate'] == null
        ? null
        : DateTime.parse(json['shipDate'] as String),
    status: _$enumDecodeNullable(_$OrderStatusEnumMap, json['status']),
    complete: json['complete'] as bool? ?? false,
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('petId', instance.petId);
  writeNotNull('quantity', instance.quantity);
  writeNotNull('shipDateTime', instance.shipDateTime?.toIso8601String());
  writeNotNull('shipDate', _dateToJson(instance.shipDate));
  writeNotNull('status', _$OrderStatusEnumMap[instance.status]);
  writeNotNull('complete', instance.complete);
  return val;
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$OrderStatusEnumMap = {
  OrderStatus.swaggerGeneratedUnknown: 'swaggerGeneratedUnknown',
  OrderStatus.placed: 'placed',
  OrderStatus.approved: 'approved',
  OrderStatus.delivered: 'delivered',
};

OrderWithDash _$OrderWithDashFromJson(Map<String, dynamic> json) {
  return OrderWithDash(
    id: json['id'] as int? ?? 36,
    petId: json['petId'] as int? ?? 36,
    quantity: json['quantity'] as int? ?? 36,
    shipDate: json['shipDate'] == null
        ? null
        : DateTime.parse(json['shipDate'] as String),
    status: _$enumDecodeNullable(_$OrderWithDashStatusEnumMap, json['status']),
    complete: json['complete'] as bool? ?? false,
  );
}

Map<String, dynamic> _$OrderWithDashToJson(OrderWithDash instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('petId', instance.petId);
  writeNotNull('quantity', instance.quantity);
  writeNotNull('shipDate', instance.shipDate?.toIso8601String());
  writeNotNull('status', _$OrderWithDashStatusEnumMap[instance.status]);
  writeNotNull('complete', instance.complete);
  return val;
}

const _$OrderWithDashStatusEnumMap = {
  OrderWithDashStatus.swaggerGeneratedUnknown: 'swaggerGeneratedUnknown',
  OrderWithDashStatus.placed: 'placed',
  OrderWithDashStatus.approved: 'approved',
  OrderWithDashStatus.delivered: 'delivered',
};

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] as int? ?? 36,
    name: json['name'] as String? ?? '',
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  return val;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int? ?? 36,
    username: json['username'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    password: json['password'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    userStatus: json['userStatus'] as int? ?? 36,
  );
}

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('username', instance.username);
  writeNotNull('firstName', instance.firstName);
  writeNotNull('lastName', instance.lastName);
  writeNotNull('email', instance.email);
  writeNotNull('password', instance.password);
  writeNotNull('phone', instance.phone);
  writeNotNull('userStatus', instance.userStatus);
  return val;
}

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag(
    id: json['id'] as int? ?? 36,
    name: json['name'] as String? ?? '',
  );
}

Map<String, dynamic> _$TagToJson(Tag instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  return val;
}

Pet _$PetFromJson(Map<String, dynamic> json) {
  return Pet(
    id: json['id'] as int? ?? 36,
    category: json['category'] == null
        ? null
        : Category.fromJson(json['category'] as Map<String, dynamic>),
    name: json['name'] as String? ?? '',
    photoUrls: (json['photoUrls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    status: _$enumDecodeNullable(_$PetStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$PetToJson(Pet instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('category', instance.category?.toJson());
  writeNotNull('name', instance.name);
  writeNotNull('photoUrls', instance.photoUrls);
  writeNotNull('tags', instance.tags?.map((e) => e.toJson()).toList());
  writeNotNull('status', _$PetStatusEnumMap[instance.status]);
  return val;
}

const _$PetStatusEnumMap = {
  PetStatus.swaggerGeneratedUnknown: 'swaggerGeneratedUnknown',
  PetStatus.available: 'available',
  PetStatus.pending: 'pending',
  PetStatus.sold: 'sold',
};

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) {
  return ApiResponse(
    code: json['code'] as int? ?? 36,
    type: json['type'] as String? ?? '',
    message: json['message'] as String? ?? '',
  );
}

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('code', instance.code);
  writeNotNull('type', instance.type);
  writeNotNull('message', instance.message);
  return val;
}

PetPost$Response _$PetPost$ResponseFromJson(Map<String, dynamic> json) {
  return PetPost$Response(
    id: json['id'] as int? ?? 36,
    petId: json['petId'] as int? ?? 36,
  );
}

Map<String, dynamic> _$PetPost$ResponseToJson(PetPost$Response instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('petId', instance.petId);
  return val;
}
