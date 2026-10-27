import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CertificateWebViewScreen extends StatefulWidget {
  final String url;

  const CertificateWebViewScreen({super.key, required this.url});

  @override
  State<CertificateWebViewScreen> createState() =>
      _CertificateWebViewScreenState();
}

class _CertificateWebViewScreenState extends State<CertificateWebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BBDE4), // matches your app's header
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'View Certificate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnLoadResource: true,
              mediaPlaybackRequiresUserGesture: false,
              // Allow mixed content (http inside https) if needed
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              if (mounted) setState(() => _isLoading = false);
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                  if (progress == 100) _isLoading = false;
                });
              }
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
            onLoadError: (controller, url, code, message) {
              debugPrint('WebView load error [$code]: $message');
              if (mounted) setState(() => _isLoading = false);
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              debugPrint('WebView HTTP error [$statusCode]: $description');
              if (mounted) setState(() => _isLoading = false);
            },
          ),

          // ── Progress / loading overlay ──────────────────────────────────
          if (_isLoading)
            Column(
              children: [
                LinearProgressIndicator(
                  value:
                      _loadingProgress < 100 ? _loadingProgress / 100.0 : null,
                  backgroundColor: const Color(0xFFDDE4EE),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF3A9BDC)),
                  minHeight: 3,
                ),
                // Full-screen dimmed loader while first paint happens
                if (_loadingProgress < 20)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3A9BDC)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
