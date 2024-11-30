import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OAuth2WebView extends StatefulWidget {
  final String url;
  final String redirectUrl;

  const OAuth2WebView({
    super.key,
    required this.url,
    required this.redirectUrl,
  });

  @override
  State<OAuth2WebView> createState() => _OAuth2WebViewState();
}

class _OAuth2WebViewState extends State<OAuth2WebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.redirectUrl)) {
              // 토큰 추출 및 처리
              final uri = Uri.parse(request.url);
              final token = uri.queryParameters['token'];
              Navigator.pop(context, token);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signInWithGoogle),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
} 