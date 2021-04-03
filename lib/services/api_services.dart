import 'package:dio/dio.dart';
/// using dio for Api to use method like , get, put, post, delete update
class APIService {
  Dio _dio;
  String BASE_URL = 'https://reqres.in/';

  APIService() {
    _dio = Dio(BaseOptions(baseUrl: BASE_URL));
    initializeInterceptors();
  }

  Future<Response> getRequest(String endPoint) async {
    Response response;

    try {
      response = await _dio.get(endPoint);
    } on DioError catch (e) {
      print(e.message);
      throw Exception(e.message);
    }

    return response;
  }

  Future delete(String endPoint) async {
    Response response;
    try {
      response = await _dio.delete(endPoint);
    } on DioError catch (e) {
      // TODO
      print(e.message);
      throw Exception(e.message);
    }
  }

  initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onError: (error) {
      print(error.message);
    }, onRequest: (request) {
      print("${request.method} ${request.path}");
    }, onResponse: (response) {
      print(response.data);
    }));
  }
}
