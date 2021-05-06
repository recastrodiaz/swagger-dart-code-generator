const String ref = '\$ref';
const String model_with_parameters_v3 = '''
{
 "components": {
    "schemas": {
      "SomeEnumModel" : {
        "enum" : ["one", "two"]
      },
      "trickPlayControl": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "disallowFastForward",
          "disallowPause",
          "disallowPlay",
          "disallowRewind",
          "disallowSkipForward",
          "disallowSkipBackward",
          "adRestrictionOnly"
        ]
      }
    },
      "AuthorizationDetails": {
        "type": "object",
        "properties": {
          "state": {
            "type": "string",
            "format": "uuid",
            "description": "Opaque value generated. The state will be echoed back in the token response, therefore state needs to be maintained between the request and the response.",
            "example": "00001-00002-00003-00004"
          },
          "authorizationUri": {
            "type": "string",
            "format": "uri",
            "description": "URI to follow for authorization",
            "example": "https://sso.service.some.country/oidc/authorize?response_type=code&state=00001-00002-00003-00004&nonce=54345345-345345345-345345345-435345&client_id=some-client-id&redirect_uri=https%3A%2F%2Fsome-success-uri.com%2Fen_gb%2Flogin_success"
          },
          "enumValue": {
            "type": "enum",
            "enum": ["one", "two"]
          },
          "redirectUri": {
            "type": "string",
            "format": "uri",
            "description": "Redirect URI used after successful authentication",
            "example": "https%3A%2F%2Fsome-success-uri.com%2Fen_gb%2Flogin_success"
          },
          "logoutUri": {
            "type": "string",
            "format": "uri",
            "description": "URI to follow to logout"
          },
          "validityToken": {
            "type": "string",
            "description": "The validity token will contain the payload of the generated nonce and state value.",
            "example": ""
          }
        }
      },
      "CompleteAuthorizationRequest": {
        "type": "object",
        "properties": {
          "code": {
            "type": "string",
            "description": "Code value obtained for SSO authorization service"
          },
          "state": {
            "type": "string",
            "format": "uuid",
            "description": "State value obtained previously",
            "example": "00001-00002-00003-00004"
          },
          "validityToken": {
            "type": "string",
            "description": "The validity token obtained previously",
            "example": ""
          }
        }
      },
      "TokensResponse": {
        "type": "object",
        "properties": {
          "token_type": {
            "type": "string",
            "enum": [
              "bearer"
            ]
          },
          "access_token": {
            "$ref": "#/components/schemas/SvcAccessToken"
          },
          "refresh_token": {
            "$ref": "#/components/schemas/SvcRefreshToken"
          },
          "expires_in": {
            "type": "integer",
            "description": "access token expiration in seconds"
          },
          "username": {
            "type": "string",
            "description": "username of authenticated client"
          },
          "givenName": {
            "type": "string",
            "description": "first name"
          },
          "familyName": {
            "type": "string",
            "description": "family name"
          }
        }
      },
      "RefreshAuthorizationRequest": {
        "type": "object",
        "properties": {
          "svcRefreshToken": {
            "$ref": "#/components/schemas/SvcRefreshToken"
          }
        }
      },
      "DeleteAuthorizationRequest": {
        "type": "object",
        "properties": {
          "svcRefreshToken": {
            "$ref": "#/components/schemas/SvcRefreshToken"
          }
        }
      },
      "SvcRefreshToken": {
        "type": "string",
        "description": "Valid service refresh token"
      },
      "SvcAccessToken": {
        "type": "string",
        "description": "jwt service access token used as ACCESS_TOKEN with calls to services"
      }
    }
  }
}
''';

const String model_with_parameters_v2 = '''
{
  "definitions": {
    "trickPlayControl": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "disallowFastForward",
          "disallowPause",
          "disallowPlay",
          "disallowRewind",
          "disallowSkipForward",
          "disallowSkipBackward",
          "adRestrictionOnly"
        ]
      }
    },
    "ActiveOrderAndListSummary": {
      "type": "object",
      "required": [
        "closingTime",
        "id",
        "shoppingType",
        "slotReservationHours",
        "state"
      ],
      "properties": {
        "closingTime": {
          "type": "string",
          "format": "date-time"
        },
        "deliveryDate": {
          "originalRef": "DeliveryDto",
          "\$ref": "#/definitions/DeliveryDto"
        },
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "lastSyncedDate": {
          "type": "string",
          "format": "date-time"
        },
        "enumValue": {
            "type": "enum",
            "enum": ["one", "two"]
          },
        "orderLastChangedTime": {
          "type": "string",
          "format": "date-time"
        },
        "orderedProducts": {
          "type": "array",
          "items": {
            "originalRef": "OrderedProductCard",
            "\$ref": "#/definitions/OrderedProductCard"
          }
        },
        "price": {
          "originalRef": "PriceDto",
          "\$ref": "#/definitions/PriceDto"
        },
        "shoppingListItems": {
          "type": "array",
          "items": {
            "originalRef": "Item",
            "\$ref": "#/definitions/Item"
          }
        },
        "shoppingType": {
          "type": "string",
          "enum": [
            "UNKNOWN",
            "PHYSICAL_STORE",
            "DELIVERY",
            "PICKUP_DELIVERY",
            "DELIVERY_POINT",
            "PICKUP",
            "IN_STORE_PICK",
            "SPECIALS_ONLY"
          ]
        },
        "slotReservationHours": {
          "type": "number",
          "format": "double"
        },
        "state": {
          "type": "string",
          "enum": [
            "CONFIRMED",
            "REOPENED",
            "IN_PREPARATION",
            "UNCONFIRMED",
            "DELIVERED",
            "CANCELLED",
            "PLANNED_FOR_DELIVERY",
            "OUT_FOR_DELIVERY",
            "UNKNOWN"
          ]
        }
      },
      "title": "ActiveOrderAndListSummary"
    }
  }
}
''';

const String request_with_header = '''
{
  "paths": {
    "/v2/order/summaries": {
      "get": {
        "tags": [
          "appie-order-controller-v-2"
        ],
        "summary": "Get order summaries",
        "operationId": "retrieveOrderSummariesUsingGET",
        "produces": [
          "*/*"
        ],
        "parameters": [
          {
            "name": "x-application",
            "in": "header",
            "description": "x-application",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "array",
              "items": {
                "originalRef": "OrderSummary",
                "\$ref": "#/definitions/OrderSummary"
              }
            }
          },
          "401": {
            "description": "Unauthorized"
          },
          "403": {
            "description": "Forbidden"
          },
          "404": {
            "description": "Not Found"
          }
        },
        "security": [
          {
            "apiKey": []
          }
        ],
        "deprecated": false
      }
    }
  }
}
''';

const String request_with_enum_in_parameter = '''
{
  "paths": {
    "/v3/order/{orderId}/state": {
      "put": {
        "tags": [
          "appie-order-controller-v-3"
        ],
        "summary": "Update state of an order.",
        "operationId": "changeOrderStateUsingPUT",
        "consumes": [
          "application/json"
        ],
        "produces": [
          "*/*"
        ],
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "description": "Id of the order",
            "required": false,
            "type": "integer",
            "format": "int64"
          },
          {
            "in": "body",
            "name": "orderStateRequest",
            "description": "Order state",
            "required": false,
            "schema": {
              "type": "string",
              "enum": [
                "SUBMITTED",
                "CANCELLED",
                "REOPENED",
                "RESET"
              ]
            }
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "object"
            }
          },
          "201": {
            "description": "Created"
          },
          "401": {
            "description": "Unauthorized"
          },
          "403": {
            "description": "Forbidden"
          },
          "404": {
            "description": "Not Found"
          }
        },
        "security": [
          {
            "apiKey": []
          }
        ],
        "deprecated": false
      }
    }
  }
}
''';

const String request_with_list_of_enum_in_parameter = '''
{
  "paths": {
    "/v3/order/{orderId}/state": {
      "put": {
        "tags": [
          "appie-order-controller-v-3"
        ],
        "summary": "Update state of an order.",
        "operationId": "changeOrderStateUsingPUT",
        "consumes": [
          "application/json"
        ],
        "produces": [
          "*/*"
        ],
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "description": "Id of the order",
            "required": false,
            "type": "integer",
            "format": "int64"
          },
          {
            "in": "body",
            "name": "orderStateRequest",
            "description": "Order state",
            "required": false,
            "items": {
              "type": "string",
              "enum": [
                "SUBMITTED",
                "CANCELLED",
                "REOPENED",
                "RESET"
              ]
            }
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "object"
            }
          },
          "201": {
            "description": "Created"
          },
          "401": {
            "description": "Unauthorized"
          },
          "403": {
            "description": "Forbidden"
          },
          "404": {
            "description": "Not Found"
          }
        },
        "security": [
          {
            "apiKey": []
          }
        ],
        "deprecated": false
      }
    }
  }
}
''';

const String request_with_array_string = '''
{
  "paths": {
    "/v1/{pboSortType}": {
      "get": {
        "tags": [
          "purchase-controller"
        ],
        "summary": "getPreviousPurchases",
        "operationId": "getPreviousPurchasesUsingGET",
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "applications",
            "in": "query",
            "description": "applications",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "originalRef": "PagedResponseOfProductCard",
              "\$ref": "#/definitions/PagedResponseOfProductCard"
            }
          }
        }
      }
    }
  },
  "securityDefinitions": {
    "apiKey": {
      "type": "apiKey",
      "name": "x-authorization",
      "in": "header"
    }
  }
}
''';

const String request_with_array_order_summary = '''
{
  "paths": {
    "/v2/order/summaries": {
      "get": {
        "tags": [
          "appie-order-controller-v-2"
        ],
        "summary": "Get order summaries",
        "operationId": "retrieveOrderSummariesUsingGET",
        "produces": [
          "*/*"
        ],
        "parameters": [
          {
            "name": "x-application",
            "in": "header",
            "description": "x-application",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "array",
              "items": {
                "originalRef": "OrderSummary",
                "\$ref": "#/definitions/OrderSummary"
              }
            }
          },
          "401": {
            "description": "Unauthorized"
          },
          "403": {
            "description": "Forbidden"
          },
          "404": {
            "description": "Not Found"
          }
        },
        "security": [
          {
            "apiKey": []
          }
        ],
        "deprecated": false
      }
    }
  }
}
''';

const String request_with_list_string_return_type = '''
{
  "paths": {
    "/v1/suggestions": {
      "get": {
        "tags": [
          "search-controller-v-1"
        ],
        "summary": "product-search-suggestions",
        "description": "Search suggestions",
        "operationId": "findSuggestionsUsingGET",
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "amount",
            "in": "query",
            "description": "Amount of suggestions",
            "required": true,
            "type": "integer",
            "default": 10,
            "format": "int32",
            "allowEmptyValue": false
          },
          {
            "name": "query",
            "in": "query",
            "description": "Term to find suggestions for",
            "required": true,
            "type": "string",
            "allowEmptyValue": false
          },
          {
            "name": "x-application",
            "in": "header",
            "description": "x-application",
            "required": false,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "array",
              "items": {
                "type": "string"
              }
            }
          },
          "401": {
            "description": "Unauthorized"
          },
          "403": {
            "description": "Forbidden"
          },
          "404": {
            "description": "Not Found"
          }
        },
        "security": [
          {
            "apiKey": []
          }
        ],
        "deprecated": false
      }
    }
  }
}
''';

const String schemas_responses_with_response = '''
{
  "openapi": "3.0.1",
  "info": {
    "title": "Some service",
    "version": "1.0"
  },
  "components": {
    "responses": {
      "SpaResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "required": [
                "showPageAvailable"
              ],
              "properties": {
                "id": {
                  "type": "string",
                  "description": "Some description"
                },
                "showPageAvailable": {
                  "type": "boolean",
                  "description": "Flag indicating showPage availability"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

const String schemas_responses_with_response_and_schemas = '''
{
  "openapi": "3.0.1",
  "info": {
    "title": "Some service",
    "version": "1.0"
  },
  "components": {
    "responses": {
      "SpaResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "required": [
                "showPageAvailable"
              ],
              "properties": {
                "id": {
                  "type": "string",
                  "description": "Some description"
                },
                "showPageAvailable": {
                  "type": "boolean",
                  "description": "Flag indicating showPage availability"
                }
              }
            }
          }
        }
      }
    },
    "schemas": {
      "SpaSchema": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string",
            "description": "Some description"
          },
          "showPageAvailable": {
            "type": "boolean",
            "description": "Flag indicating showPage availability"
          }
        }
      }
    }
  }
}
''';

const String enum_as_definition_v2 = '''
{
  "openapi": "2.0.1",
  "definitions": {
      "SpaResponse": {
        "description": "Success",
        "enum": [
          "one",
          "two"
        ]
    }
  }
}
''';

const String schemas_with_enums_in_properties = '''
{
  "openapi": "3.0.1",
  "info": {
    "title": "Some service",
    "version": "1.0"
  },
  "components": {
    "schemas": {
      "SpaSchema": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string",
            "description": "Some description"
          },
          "showPageAvailable": {
            "type": "boolean",
            "description": "Flag indicating showPage availability"
          },
          "successValues": {
            "items": {
              "enum": [
                "one, two"
              ]
            }
          }
        }
      }
    },
    "responses": {
      "SpaResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "enum": [
                "one",
                "two"
              ]
            }
          }
        }
      },
      "SpaEnumResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "properties": {
                "failedValued": {
                  "items": {
                    "enum": [
                      "one",
                      "two"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_return_type_injected = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "parameters": [
          {
            "name": "testName",
            "in": "query",
            "description": "test name",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "schema": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "integer",
                  "format": "int64"
                },
                "petId": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_ref_response = '''
{
  "components": {
    "schemes": {
      "MyCoolDefinition": {
        "type": "object",
        "properties": {
          "startTime": {
            "type": "string",
            "format": "date"
          },
          "endTime": {
            "type": "string",
            "format": "date"
          },
          "imageUrl": {
            "type": "string"
          }
        },
        "title": "MyCoolDefinition"
      }
    },
    "responses": {
      "SpaSingleResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "enum": [
                "one",
                "two"
              ]
            }
          }
        }
      },
      "SpaResponse": {
        "description": "Success",
        "content": {
          "application/json(1)": {
            "schema": {
              "enum": [
                "one",
                "two"
              ]
            }
          },
          "application/json(2)": {
            "schema": {
              "enum": [
                "one",
                "two"
              ]
            }
          }
        }
      }
    }
  },
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "someOperationId",
        "parameters": [
          {
            "name": "headerParameter",
            "in": "header",
            "required": true,
            "type": "string"
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "array",
                "items": {
                  "\$ref": "#/components/responses/SpaResponse"
                }
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "OK",
            "\$ref": "#/responses/SpaResponse"
          }
        }
      }
    }
  }
}
''';



const String request_with_array_item_summary = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "parameters": [
          {
            "name": "testName",
            "in": "query",
            "description": "test name",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "array",
              "items": {
                "originalRef": "ItemSummary",
                "\$ref": "#/definitions/ItemSummary"
              }
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_list_test_item_return_type = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "parameters": [
          {
            "name": "testName",
            "in": "query",
            "description": "test name",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type": "array",
              "items": {
                "originalRef": "TestItem",
                "\$ref": "#/definitions/TestItem"
              }
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_object_ref_response = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "parameters": [
          {
            "name": "testName",
            "in": "query",
            "description": "test name",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "\$ref" : "MyObject"
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_original_ref_return_type = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "originalRef": "TestItem"
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_content_first_response_type = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "responses": {
          "200": {
            "description": "OK",
            "content": {
              "applicacion/json": {
                "schema" : {
                  "type" : "String"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

const String request_with_content_first_response_ref = '''
{
  "paths": {
    "/model/items": {
      "get": {
        "summary": "Some test request",
        "operationId": "getModelItems",
        "responses": {
          "200": {
            "description": "OK",
            "schema": {
              "type" : "testType",
              "items" : {
                "\$ref" : "#definitions/TestItem"
              }
            }
          }
        }
      }
    }
  }
}
''';

const String model_with_inheritance = '''
{
  "openapi": "3.0.0",
  "components": {
    "schemas": {
      "BasicErrorModel": {
        "type": "object",
        "required": [
          "message",
          "code"
        ],
        "properties": {
          "message": {
            "type": "string"
          },
          "code": {
            "type": "integer",
            "minimum": 100,
            "maximum": 600
          }
        }
      },
      "ExtendedErrorModel": {
        "allOf": [
          {
            "\$ref": "#/components/schemas/BasicErrorModel"
          },
          {
            "type": "object",
            "required": [
              "rootCause"
            ],
            "properties": {
              "rootCause": {
                "type": "string"
              }
            }
          }
        ]
      }
    }
  }
}
''';

const String model_with_enum = '''
{
   "openapi":"3.0.0",
   "components":{
      "schemas":{
         "BasicErrorModel":{
            "enum":[
               "message",
               "code"
            ]
         }
      }
   }
}
''';

const String model_with_inheritance_3_levels = '''
{
  "openapi": "3.0.0",
  "components": {
    "schemas": {
      "BasicErrorModel": {
        "type": "object",
        "required": [
          "message",
          "code"
        ],
        "properties": {
          "message": {
            "type": "string"
          },
          "code": {
            "type": "integer",
            "minimum": 100,
            "maximum": 600
          }
        }
      },
      "ExtendedErrorModel": {
        "allOf": [
          {
            "\$ref": "#/components/schemas/BasicErrorModel"
          },
          {
            "type": "object",
            "required": [
              "rootCause"
            ],
            "properties": {
              "rootCause": {
                "type": "string"
              }
            }
          }
        ]
      },
      "ErrorModelWithBadAllof": {
        "allOf": [
          {
            "\$ref": "#/components/schemas/NotExistingError"
          },
          {
            "type": "object",
            "required": [
              "rootCause"
            ]
          }
        ]
      },
      "MostExtendedErrorModel": {
        "allOf": [
          {
            "\$ref": "#/components/schemas/ExtendedErrorModel"
          },
          {
            "type": "object",
            "required": [
              "rootCause"
            ],
            "properties": {
              "phone": {
                "type": "string"
              }
            }
          }
        ]
      }
    }
  }
}
''';

const request_with_enum = '''
{
  "paths": {
    "/pets/{petId}/items": {
      "get": {
        "summary": "Some summary",
        "tags": [
          "Bookmarks"
        ],
        "parameters": [
          {
            "name": "contentType",
            "in": "query",
            "description": "content source type",
            "type": "string",
            "schema": {
              "enum": [
              "vod",
              "replay",
              "network-recording",
              "local-recording"
            ]
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Bookmarks for given profile and content is returned.",
            "schema": {
              "\$ref": "#/definitions/Pet"
            }
          }
        }
      }
    }
  }
}
''';

const request_with_enum_request_body = '''
{
  "openapi": "3.0.1",
  "info": {
    "title": "Test service",
    "version": "0.18.0"
  },
  "paths": {
    "/v3/customers/{customerId}/status": {
      "put": {
        "description": "Test request",
        "parameters": [
          {
            "name": "customerId",
            "in": "path",
            "description": "Test desc",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "requestBody": {
          "description": "Test desc",
          "content": {
            "application/json": {
              "schema": {
                "\$ref": "#/components/schemas/CustomerStatus"
              }
            }
          },
          "required": true
        },
        "responses": {
          "204": {
            "description": "Customer Status was changed."
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "CustomerStatus": {
        "title": "Customer Status",
        "type": "string",
        "enum": [
          "active",
          "inactive",
          "deleted"
        ]
      }
    }
  }
}
''';


const aaa = '''
{
  "swagger": "2.0",
  "info": {
    "description": "This is a sample server Petstore server.  You can find out more about     Swagger at [http://swagger.io](http://swagger.io) or on [irc.freenode.net, #swagger](http://swagger.io/irc/).      For this sample, you can use the api key `special-key` to test the authorization     filters.",
    "version": "1.0.0",
    "title": "Swagger Petstore",
    "termsOfService": "http://swagger.io/terms/",
    "contact": {
      "email": "apiteam@swagger.io"
    },
    "license": {
      "name": "Apache 2.0",
      "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  },
  "host": "petstore.swagger.io",
  "basePath": "/v2",
  "tags": [
    {
      "name": "pet",
      "description": "Everything about your Pets",
      "externalDocs": {
        "description": "Find out more",
        "url": "http://swagger.io"
      }
    },
    {
      "name": "store",
      "description": "Access to Petstore orders"
    },
    {
      "name": "user",
      "description": "Operations about user",
      "externalDocs": {
        "description": "Find out more about our store",
        "url": "http://swagger.io"
      }
    }
  ],
  "schemes": [
    "https",
    "http"
  ],
  "paths": {
    "/pet": {
      "post": {
        "tags": [
          "pet"
        ],
        "summary": "Add a new pet to the store",
        "description": "",
        "operationId": "addPet",
        "consumes": [
          "application/json",
          "application/xml"
        ],
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "Pet object that needs to be added to the store",
            "required": true,
            "schema": {
              "$ref": "#/definitions/Pet"
            }
          }
        ],
        "responses": {
          "405": {
            "description": "Invalid input"
          },
          "200": {
            "schema": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "integer",
                  "format": "int64"
                },
                "petId": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            }
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      },
      "put": {
        "tags": [
          "pet"
        ],
        "summary": "Update an existing pet",
        "description": "",
        "operationId": "updatePet",
        "consumes": [
          "application/json",
          "application/xml"
        ],
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "Pet object that needs to be added to the store",
            "required": true,
            "schema": {
              "$ref": "#/definitions/Pet"
            }
          }
        ],
        "responses": {
          "400": {
            "description": "Invalid ID supplied"
          },
          "404": {
            "description": "Pet not found"
          },
          "405": {
            "description": "Validation exception"
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      }
    },
    "/pet/findByStatus": {
      "get": {
        "tags": [
          "pet"
        ],
        "summary": "Finds Pets by status",
        "description": "Multiple status values can be provided with comma separated strings",
        "operationId": "findPetsByStatus",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "status",
            "in": "query",
            "description": "Status values that need to be considered for filter",
            "required": true,
            "schema": {
              "enum": [
                "available",
                "pending",
                "sold"
              ]
            },
            "collectionFormat": "multi"
          },
          {
            "name": "color",
            "in": "query",
            "description": "Status values that need to be considered for filter",
            "required": true,
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "red",
                "green",
                "yellow"
              ],
              "default": "available"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/Pet"
              }
            }
          },
          "400": {
            "description": "Invalid status value"
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      }
    },
    "/pet/findByTags": {
      "get": {
        "tags": [
          "pet"
        ],
        "summary": "Finds Pets by tags",
        "description": "Muliple tags can be provided with comma separated strings. Use         tag1, tag2, tag3 for testing.",
        "operationId": "findPetsByTags",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "tags",
            "in": "query",
            "description": "Tags to filter by",
            "required": true,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "multi"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/Pet"
              }
            }
          },
          "400": {
            "description": "Invalid tag value"
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ],
        "deprecated": true
      }
    },
    "/pet/{petId}": {
      "get": {
        "tags": [
          "pet"
        ],
        "summary": "Find pet by ID",
        "description": "Returns a single pet",
        "operationId": "getPetById",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "petId",
            "in": "path",
            "description": "ID of pet to return",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/Pet"
            }
          },
          "400": {
            "description": "Invalid ID supplied"
          },
          "404": {
            "description": "Pet not found"
          }
        },
        "security": [
          {
            "api_key": []
          }
        ]
      },
      "post": {
        "tags": [
          "pet"
        ],
        "summary": "Updates a pet in the store with form data",
        "description": "",
        "operationId": "updatePetWithForm",
        "consumes": [
          "application/x-www-form-urlencoded"
        ],
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "petId",
            "in": "path",
            "description": "ID of pet that needs to be updated",
            "required": true,
            "type": "integer",
            "format": "int64"
          },
          {
            "name": "name",
            "in": "formData",
            "description": "Updated name of the pet",
            "required": false,
            "type": "string"
          },
          {
            "name": "status",
            "in": "formData",
            "description": "Updated status of the pet",
            "required": false,
            "type": "string"
          }
        ],
        "responses": {
          "405": {
            "description": "Invalid input"
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      },
      "delete": {
        "tags": [
          "pet"
        ],
        "summary": "Deletes a pet",
        "description": "",
        "operationId": "deletePet",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "api_key",
            "in": "header",
            "required": false,
            "type": "string"
          },
          {
            "name": "petId",
            "in": "path",
            "description": "Pet id to delete",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "400": {
            "description": "Invalid ID supplied"
          },
          "404": {
            "description": "Pet not found"
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      }
    },
    "/pet/{petId}/uploadImage": {
      "post": {
        "tags": [
          "pet"
        ],
        "summary": "uploads an image",
        "description": "",
        "operationId": "uploadFile",
        "consumes": [
          "multipart/form-data"
        ],
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "petId",
            "in": "path",
            "description": "ID of pet to update",
            "required": true,
            "type": "integer",
            "format": "int64"
          },
          {
            "name": "additionalMetadata",
            "in": "formData",
            "description": "Additional data to pass to server",
            "required": false,
            "type": "string"
          },
          {
            "name": "file",
            "in": "formData",
            "description": "file to upload",
            "required": false,
            "type": "file"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/ApiResponse"
            }
          }
        },
        "security": [
          {
            "petstore_auth": [
              "write:pets",
              "read:pets"
            ]
          }
        ]
      }
    },
    "/store/inventory": {
      "get": {
        "tags": [
          "store"
        ],
        "summary": "Returns pet inventories by status",
        "description": "Returns a map of status codes to quantities",
        "operationId": "getInventory",
        "produces": [
          "application/json"
        ],
        "parameters": [],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "type": "object",
              "additionalProperties": {
                "type": "integer",
                "format": "int32"
              }
            }
          }
        },
        "security": [
          {
            "api_key": []
          }
        ]
      }
    },
    "/store/order": {
      "post": {
        "tags": [
          "store"
        ],
        "summary": "Place an order for a pet",
        "description": "",
        "operationId": "placeOrder",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "order placed for purchasing the pet",
            "required": true,
            "schema": {
              "$ref": "#/definitions/Order"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/Order-With-Dash"
            }
          },
          "400": {
            "description": "Invalid Order"
          }
        }
      }
    },
    "/store/order/{orderId}": {
      "get": {
        "tags": [
          "store"
        ],
        "summary": "Find purchase order by ID",
        "description": "For valid response try integer IDs with value >= 1 and <= 10.         Other values will generated exceptions",
        "operationId": "getOrderById",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "description": "ID of pet that needs to be fetched",
            "required": true,
            "type": "integer",
            "maximum": 10,
            "minimum": 1,
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/Order"
            }
          },
          "400": {
            "description": "Invalid ID supplied"
          },
          "404": {
            "description": "Order not found"
          }
        }
      },
      "delete": {
        "tags": [
          "store"
        ],
        "summary": "Delete purchase order by ID",
        "description": "For valid response try integer IDs with positive integer value.         Negative or non-integer values will generate API errors",
        "operationId": "deleteOrder",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "description": "ID of the order that needs to be deleted",
            "required": true,
            "type": "integer",
            "minimum": 1,
            "format": "int64"
          }
        ],
        "responses": {
          "400": {
            "description": "Invalid ID supplied"
          },
          "404": {
            "description": "Order not found"
          }
        }
      }
    },
    "/user": {
      "post": {
        "tags": [
          "user"
        ],
        "summary": "Create user",
        "description": "This can only be done by the logged in user.",
        "operationId": "createUser",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "Created user object",
            "required": true,
            "schema": {
              "$ref": "#/definitions/User"
            }
          }
        ],
        "responses": {
          "default": {
            "description": "successful operation"
          }
        }
      }
    },
    "/user/createWithArray": {
      "post": {
        "tags": [
          "user"
        ],
        "summary": "Creates list of users with given input array",
        "description": "",
        "operationId": "createUsersWithArrayInput",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "List of user object",
            "required": true,
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/User"
              }
            }
          }
        ],
        "responses": {
          "default": {
            "description": "successful operation"
          }
        }
      }
    },
    "/user/createWithList": {
      "post": {
        "tags": [
          "user"
        ],
        "summary": "Creates list of users with given input array",
        "description": "",
        "operationId": "createUsersWithListInput",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "body",
            "description": "List of user object",
            "required": true,
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/User"
              }
            }
          }
        ],
        "responses": {
          "default": {
            "description": "successful operation"
          }
        }
      }
    },
    "/user/login": {
      "get": {
        "tags": [
          "user"
        ],
        "summary": "Logs user into the system",
        "description": "",
        "operationId": "loginUser",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "username",
            "in": "query",
            "description": "The user name for login",
            "required": true,
            "type": "string"
          },
          {
            "name": "password",
            "in": "query",
            "description": "The password for login in clear text",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "type": "string"
            },
            "headers": {
              "X-Rate-Limit": {
                "type": "integer",
                "format": "int32",
                "description": "calls per hour allowed by the user"
              },
              "X-Expires-After": {
                "type": "string",
                "format": "date-time",
                "description": "date in UTC when token expires"
              }
            }
          },
          "400": {
            "description": "Invalid username/password supplied"
          }
        }
      }
    },
    "/user/logout": {
      "get": {
        "tags": [
          "user"
        ],
        "summary": "Logs out current logged in user session",
        "description": "",
        "operationId": "logoutUser",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [],
        "responses": {
          "default": {
            "description": "successful operation"
          }
        }
      }
    },
    "/user/{username}": {
      "get": {
        "tags": [
          "user"
        ],
        "summary": "Get user by user name",
        "description": "",
        "operationId": "getUserByName",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "username",
            "in": "path",
            "description": "The name that needs to be fetched. Use user1 for testing. ",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/User"
            }
          },
          "400": {
            "description": "Invalid username supplied"
          },
          "404": {
            "description": "User not found"
          }
        }
      },
      "put": {
        "tags": [
          "user"
        ],
        "summary": "Updated user",
        "description": "This can only be done by the logged in user.",
        "operationId": "updateUser",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "username",
            "in": "path",
            "description": "name that need to be updated",
            "required": true,
            "type": "string"
          },
          {
            "in": "body",
            "name": "body",
            "description": "Updated user object",
            "required": true,
            "schema": {
              "$ref": "#/definitions/User"
            }
          }
        ],
        "responses": {
          "400": {
            "description": "Invalid user supplied"
          },
          "404": {
            "description": "User not found"
          }
        }
      },
      "delete": {
        "tags": [
          "user"
        ],
        "summary": "Delete user",
        "description": "This can only be done by the logged in user.",
        "operationId": "deleteUser",
        "produces": [
          "application/xml",
          "application/json"
        ],
        "parameters": [
          {
            "name": "username",
            "in": "path",
            "description": "The name that needs to be deleted",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "400": {
            "description": "Invalid username supplied"
          },
          "404": {
            "description": "User not found"
          }
        }
      }
    }
  },
  "securityDefinitions": {
    "petstore_auth": {
      "type": "oauth2",
      "authorizationUrl": "http://petstore.swagger.io/oauth/dialog",
      "flow": "implicit",
      "scopes": {
        "write:pets": "modify pets in your account",
        "read:pets": "read your pets"
      }
    },
    "api_key": {
      "type": "apiKey",
      "name": "api_key",
      "in": "header"
    }
  },
  "components": {
    "responses": {
      "SpaResponse": {
        "description": "Success",
        "content": {
          "application/json": {
            "schema": {
              "required": [
                "showPageAvailable"
              ],
              "properties": {
                "id": {
                  "type": "string",
                  "description": "Crid show (VOD)"
                },
                "showPageAvailable": {
                  "type": "boolean",
                  "description": "Flag indicating showPage availability"
                }
              }
            }
          }
        }
      }
    }
  },
  "definitions": {
    "Order": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "petId": {
          "type": "integer",
          "format": "int64"
        },
        "quantity": {
          "type": "integer",
          "format": "int32"
        },
        "shipDateTime": {
          "type": "string",
          "format": "date-time"
        },
        "shipDate": {
          "type": "string",
          "format": "date"
        },
        "status": {
          "type": "string",
          "description": "Order Status",
          "enum": [
            "placed",
            "approved",
            "delivered"
          ]
        },
        "complete": {
          "type": "boolean",
          "default": false
        }
      },
      "xml": {
        "name": "Order"
      }
    },
    "Order-With-Dash": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "petId": {
          "type": "integer",
          "format": "int64"
        },
        "quantity": {
          "type": "integer",
          "format": "int32"
        },
        "shipDate": {
          "type": "string",
          "format": "date-time"
        },
        "status": {
          "type": "string",
          "description": "Order Status",
          "enum": [
            "placed",
            "approved",
            "delivered"
          ]
        },
        "complete": {
          "type": "boolean",
          "default": false
        }
      },
      "xml": {
        "name": "Order"
      }
    },
    "Category": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "name": {
          "type": "string"
        }
      },
      "xml": {
        "name": "Category"
      }
    },
    "User": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "username": {
          "type": "string"
        },
        "firstName": {
          "type": "string"
        },
        "lastName": {
          "type": "string"
        },
        "email": {
          "type": "string"
        },
        "password": {
          "type": "string"
        },
        "phone": {
          "type": "string"
        },
        "userStatus": {
          "type": "integer",
          "format": "int32",
          "description": "User Status"
        }
      },
      "xml": {
        "name": "User"
      }
    },
    "Tag": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "name": {
          "type": "string"
        }
      },
      "xml": {
        "name": "Tag"
      }
    },
    "Pet": {
      "type": "object",
      "required": [
        "name",
        "photoUrls"
      ],
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "category": {
          "$ref": "#/definitions/Category"
        },
        "name": {
          "type": "string",
          "example": "doggie"
        },
        "photoUrls": {
          "type": "array",
          "xml": {
            "name": "photoUrl",
            "wrapped": true
          },
          "items": {
            "type": "string"
          }
        },
        "tags": {
          "type": "array",
          "xml": {
            "name": "tag",
            "wrapped": true
          },
          "items": {
            "$ref": "#/definitions/Tag"
          }
        },
        "status": {
          "type": "string",
          "description": "pet status in the store",
          "enum": [
            "available",
            "pending",
            "sold"
          ]
        }
      },
      "xml": {
        "name": "Pet"
      }
    },
    "ApiResponse": {
      "type": "object",
      "properties": {
        "code": {
          "type": "integer",
          "format": "int32"
        },
        "type": {
          "type": "string"
        },
        "message": {
          "type": "string"
        }
      }
    }
  },
  "externalDocs": {
    "description": "Find out more about Swagger",
    "url": "http://swagger.io"
  }
}
''';