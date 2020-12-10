import 'package:get/get.dart';
import 'package:model_help/generated/models/model_model.dart';

class ModelProvider extends GetConnect {
	@override
	void onInit() {
		httpClient.defaultDecoder = (map) => Model.fromJson(map);
		httpClient.baseUrl = 'YOUR-API-URL';
	}
	Future<Response<Model>> getModel(int id) async => 
		await get('model/$id');
	Future<Response<Model>> postModel(Model model) async => 
		await post('model', model);
	Future<Response> deleteModel(int id) async => 
		await delete('model/$id');
}
