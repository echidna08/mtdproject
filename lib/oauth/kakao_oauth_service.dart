import 'dart:convert';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class KakaoOAuthService {
  final String _authorizationEndpoint = 'https://kauth.kakao.com/oauth/authorize';
  final String _tokenEndpoint = 'https://kauth.kakao.com/oauth/token';
  final String _clientId = '5e02af0aab7c259abc19a427f4f2bc9d';
  final String _redirectUri = 'kakao5e02af0aab7c259abc19a427f4f2bc9d://oauth';

  // 로그인 메서드
  Future<void> login(BuildContext context) async {
    try {
      print('========== 카카오 로그인 시작');
      final authCode = await _getAuthorizationCode();
      if (authCode != null) {
        print('========== 인증 코드 획득: $authCode');
        await _requestToken(authCode, context);
      } else {
        throw '========== 인증 코드가 없습니다';
      }
    } catch (e) {
      print('========== 로그인 오류: $e');
    }
  }

  Future<String?> _getAuthorizationCode() async {
    final authorizationUrl = Uri.parse(
        '$_authorizationEndpoint?client_id=$_clientId&redirect_uri=$_redirectUri&response_type=code'
    );

    try {
      // FlutterWebAuth를 사용하여 인증 처리
      final result = await FlutterWebAuth.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: "kakao5e02af0aab7c259abc19a427f4f2bc9d",  // 리다이렉트 스킴 설정
      );

      // result에는 리다이렉트된 URL이 포함되어 있음
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      return code;
    } catch (e) {
      print('========== 인증 실패: $e');
      return null;
    }
  }


  Future<void> _requestToken(String authCode, BuildContext context) async {
    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'redirect_uri': _redirectUri,
        'code': authCode,
      },
    );

    print('Token request status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      print('========== 액세스 토큰: $accessToken');
      _onLoginSuccess(context, accessToken); // 성공 시 추가 작업 수행
    } else {
      throw '========== 액세스 토큰 요청 실패: ${response.body}';
    }
  }

  void _onLoginSuccess(BuildContext context, String accessToken) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('로그인에 성공했습니다'),
        duration: Duration(seconds: 2),
      ),
    );

    print('========== 로그인 성공! 액세스 토큰: $accessToken');

    // MainScreen으로 이동
    Navigator.of(context).pushReplacementNamed('/main');
  }
}
