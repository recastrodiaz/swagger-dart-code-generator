import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'example_swagger.enums.swagger.dart' as enums;
export 'example_swagger.enums.swagger.dart';

abstract class OrderSerice extends ChopperService {
    
    @Post(path: '/pet') Future<Response<PetAddPet$Response>>
    addPet(@Body() required Pet body);


@Put(path: '/pet') Future<Response> updatePet(@Body() required Pet body);
@Get(path: '/pet/findByStatus') Future<Response<List<Pet>>> findPetsByStatus(@Query() required enums.PetFindByStatus$Get$Status status, @Query() required enums.PetFindByStatus$Get$Color color);
@Get(path: '/pet/findByTags') Future<Response<List<Pet>>> findPetsByTags(@Query() required List<String> tags);
@Get(path: '/pet/{petId}') Future<Response<Pet>> getPetById(@path('petId') required int petId);
@Post(path: '/pet/{petId}') Future<Response> updatePetWithForm(@path('petId') required int petId, @Field() required String name, @Field() required String status);
@Delete(path: '/pet/{petId}') Future<Response> deletePet(@path('petId') required int petId);
@Post(path: '/pet/{petId}/uploadImage') Future<Response<ApiResponse>> uploadFile(@path('petId') required int petId, @Field() required String additionalMetadata, @Field() required List<String> file);
@Get(path: '/store/inventory') Future<Response<object>> getInventory();
@Post(path: '/store/order') Future<Response<OrderWithDash>> placeOrder(@Body() required Order body);
@Get(path: '/store/order/{orderId}') Future<Response<Order>> getOrderById(@path('orderId') required int orderId);
@Delete(path: '/store/order/{orderId}') Future<Response> deleteOrder(@path('orderId') required int orderId);
@Post(path: '/user') Future<Response> createUser(@Body() required User body);
@Post(path: '/user/createWithArray') Future<Response> createUsersWithArrayInput(@Body() required Array body);
@Post(path: '/user/createWithList') Future<Response> createUsersWithListInput(@Body() required Array body);
@Get(path: '/user/login') Future<Response<string>> loginUser(@Query() required String username, @Query() required String password);
@Get(path: '/user/logout') Future<Response> logoutUser();
@Get(path: '/user/{username}') Future<Response<User>> getUserByName(@path('username') required String username);
@Put(path: '/user/{username}') Future<Response> updateUser(@path('username') required String username, @Body() required User body);
@Delete(path: '/user/{username}') Future<Response> deleteUser(@path('username') required String username);
 }