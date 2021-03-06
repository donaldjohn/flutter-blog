import 'dart:async';
import 'package:dio/dio.dart';

// dev | production
const env = 'dev';
const baseUrlMap = {
  'dev': 'http://localhost:3002/api/v2',
  'production': 'https://api.jooger.me'
};

final dio = new Dio();

class Api {
  final Dio client = dio;
  String env;
  String baseUrl;

  Api() {
    this.env = env;
    this.baseUrl = baseUrlMap[env];
    this._initOptions();
    this._initInterceptor();
  }

  _initOptions() {
    dio.options.baseUrl = this.baseUrl;
    dio.options.connectTimeout = 12000;
    dio.options.receiveTimeout=3000;
    dio.options.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json'
    });
    dio.options.responseType = ResponseType.JSON;
  }

  _initInterceptor() {
    dio.interceptor.request.onSend = (Options options){
        // 在请求被发送之前做一些事情
        return options; //continue
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
    };
    dio.interceptor.response.onSuccess = (Response response) {
        // 在返回响应数据之前做一些预处理
        if (response.statusCode != 200) {
          // TODO: 失败情况，可以toast弹出错误信息
          this._processError(new DioError(response: response, message: response.data.message, type: DioErrorType.RESPONSE));
        }
        return response; // continue
    };
    dio.interceptor.response.onError = (DioError err){
        // 当请求失败时做一些预处理
        this._processError(err);
        return err;//continue
    };
  }

  _processError(DioError err) {
    throw err;
  }

  /*
   *****************************************************
   * 业务接口
   *****************************************************
   */

  // 获取站点配置
  getSetting() async {
    return await this.client.get('/setting');
  }

  // 获取文章列表
  getArticleList(Map<String, dynamic> data) async {
    return await this.client.get('/articles', data: data);
  }

  // 获取文章详情
  getArticleDetail(String id) async {
    return await this.client.get('/articles/$id');
  }

  // 文章点赞
  likeArticle(String id) async {
    return await this.client.patch('/article/$id/like');
  }

  // 文章取消点赞
  unlikeArticle(String id) async {
    return await this.client.patch('/article/$id/unlike');
  }

  // 获取文章归档
  getArchives() async {
    return await this.client.get('/articles/archives');
  }

  // 获取分类列表
  getCategoryList(Map<String, dynamic> data) async {
    return await this.client.get('/categories', data: data);
  }

  // 获取分类详情
  getCategoryetail(String id) async {
    return await this.client.get('/categories/$id');
  }

  // 获取标签列表
  getTagList(Map<String, dynamic> data) async {
    return await this.client.get('/tags', data: data);
  }

  // 获取标签详情
  getTagetail(String id) async {
    return await this.client.get('/tags/$id');
  }

  // 获取评论列表
  getCommentList(Map<String, dynamic> data) async {
    return await this.client.get('/comments', data: data);
  }

  // 获取评论详情
  getCommentetail(String id) async {
    return await this.client.get('/comments/$id');
  }

  // 创建评论
  createComments(Map<String, dynamic> data) async {
    return await this.client.post('/comments', data: data)
  }

  // 评论点赞
  likeComment(String id) async {
    return await this.client.patch('/comments/$id/like');
  }

  // 评论取消点赞
  unlikeComment(String id) async {
    return await this.client.patch('/comments/$id/unlike');
  }
}
