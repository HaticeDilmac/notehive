import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class NotesService {
  NotesService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          (Platform.isAndroid
              ? 'http://10.0.2.2:8000'
              : 'http://127.0.0.1:8000');

  final http.Client _client;
  final String _baseUrl;

  //get token function
  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Failed to get ID token');
    }
    return token;
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  //fetch notes function
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final token = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/notes');
    final res = await _client.get(uri, headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to load notes: ${res.body}');
    }
    final List<dynamic> data = json.decode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  //create note function
  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
  }) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/notes');
    final res = await _client.post(
      uri,
      headers: _headers(token),
      body: json.encode({'title': title, 'content': content}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create note: ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  //update note function
  Future<Map<String, dynamic>> updateNote({
    required int id,
    required String title,
    required String content,
  }) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/notes/$id');
    final res = await _client.put(
      uri,
      headers: _headers(token),
      body: json.encode({'title': title, 'content': content}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update note: ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  //delete note function
  Future<void> deleteNote(int id) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/notes/$id');
    final res = await _client.delete(uri, headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.body}');
    }
  }
}
