import 'package:json_annotation/json_annotation.dart';

enum OrderStatus {
  @JsonValue('swaggerGeneratedUnknown')
  swaggerGeneratedUnknown,
  @JsonValue('placed')
  placed,
  @JsonValue('approved')
  approved,
  @JsonValue('delivered')
  delivered
}

const $OrderStatusMap = {
  OrderStatus.placed: 'placed',
  OrderStatus.approved: 'approved',
  OrderStatus.delivered: 'delivered',
  OrderStatus.swaggerGeneratedUnknown: ''
};

enum OrderWithDashStatus {
  @JsonValue('swaggerGeneratedUnknown')
  swaggerGeneratedUnknown,
  @JsonValue('placed')
  placed,
  @JsonValue('approved')
  approved,
  @JsonValue('delivered')
  delivered
}

const $OrderWithDashStatusMap = {
  OrderWithDashStatus.placed: 'placed',
  OrderWithDashStatus.approved: 'approved',
  OrderWithDashStatus.delivered: 'delivered',
  OrderWithDashStatus.swaggerGeneratedUnknown: ''
};

enum PetStatus {
  @JsonValue('swaggerGeneratedUnknown')
  swaggerGeneratedUnknown,
  @JsonValue('available')
  available,
  @JsonValue('pending')
  pending,
  @JsonValue('sold')
  sold
}

const $PetStatusMap = {
  PetStatus.available: 'available',
  PetStatus.pending: 'pending',
  PetStatus.sold: 'sold',
  PetStatus.swaggerGeneratedUnknown: ''
};

enum PetFindByStatus$Get$Status {
  @JsonValue('swaggerGeneratedUnknown')
  swaggerGeneratedUnknown,
  @JsonValue('available')
  available,
  @JsonValue('pending')
  pending,
  @JsonValue('sold')
  sold
}

const $PetFindByStatus$Get$StatusMap = {
  PetFindByStatus$Get$Status.available: 'available',
  PetFindByStatus$Get$Status.pending: 'pending',
  PetFindByStatus$Get$Status.sold: 'sold',
  PetFindByStatus$Get$Status.swaggerGeneratedUnknown: ''
};

enum PetFindByStatus$Get$Color {
  @JsonValue('swaggerGeneratedUnknown')
  swaggerGeneratedUnknown,
  @JsonValue('red')
  red,
  @JsonValue('green')
  green,
  @JsonValue('yellow')
  yellow
}

const $PetFindByStatus$Get$ColorMap = {
  PetFindByStatus$Get$Color.red: 'red',
  PetFindByStatus$Get$Color.green: 'green',
  PetFindByStatus$Get$Color.yellow: 'yellow',
  PetFindByStatus$Get$Color.swaggerGeneratedUnknown: ''
};
