import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = 'http://127.0.0.1:8000';
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? user;
  bool isLoading = false;

  bool get isAuthenticated => _accessToken != null;
  bool get isLoggedIn => isAuthenticated;
  bool get hasAccount => _accessToken != null || user != null;

  String? get token => _accessToken;
  String? get role => user?['role'];

  // Load tokens and user info from shared preferences
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      user = jsonDecode(userJson);
    } else if (_accessToken != null) {
      await fetchUserInfo();
    }
    notifyListeners();
  }

  // Save tokens to shared preferences
  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
    _accessToken = access;
    _refreshToken = refresh;
  }

  // Login
  Future<void> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _saveTokens(data['access'], data['refresh']);
      await fetchUserInfo();
    } else {
      throw Exception('Login failed: ${res.body}');
    }

    isLoading = false;
    notifyListeners();
  }

  // Register
  Future<void> register(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();

    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 201) {
      throw Exception('Register failed: ${res.body}');
    }

    isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('user');
    notifyListeners();
  }

  // Fetch current user info
  Future<void> fetchUserInfo() async {
    if (_accessToken == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/api/auth/me/'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (res.statusCode == 200) {
      user = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user));
      notifyListeners();
    } else if (_refreshToken != null) {
      await _refreshAccessToken();
    } else {
      await logout();
    }
  }

  // Refresh access token using refresh token
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) return;

    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _accessToken = data['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      await fetchUserInfo();
    } else {
      await logout();
    }
  }
}
      