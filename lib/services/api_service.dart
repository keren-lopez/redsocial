import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/comment.dart';
import '../model/post.dart';
import '../model/user.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Error al cargar posts');
  }

  Future<Post> getPostDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Post.fromJson(data);
    }
    throw Exception('Error al cargar detalle');
  }

  Future<List<Comment>> getCommentsByPost(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments?postId=$postId'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Comment.fromJson(e)).toList();
    }
    throw Exception('Error al cargar comentarios');
  }

  Future<User> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    }
    throw Exception('Error al cargar usuario');
  }
}
