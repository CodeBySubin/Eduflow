import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_project/model/video_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoId,
    required this.platform,
  });

  final String videoId;
  final VideoType platform;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final WebViewController _controller;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(_videoPage(widget.videoId, widget.platform));

    if (WebViewPlatform.instance != null) {
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true; 
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false; 
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              errorMessage = error.description;
              isLoading = false; 
            });
          },
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _controller.loadRequest(_videoPage(widget.videoId, widget.platform));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage == null
        ? WebViewWidget(controller: _controller)
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text(
                'Error: $errorMessage',
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }

  /// Generates the appropriate video player page (Vimeo or YouTube)
  Uri _videoPage(String videoId, VideoType platform) {
    String htmlContent;

    if (platform == VideoType.VIMEO) {
      htmlContent = '''
        <html>
          <head>
            <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
            <style>
              body { margin: 0px; background-color: lightgray; }
            </style>
          </head>
          <body>
            <iframe 
              src="https://player.vimeo.com/video/$videoId?loop=0&autoplay=0" 
              width="100%" height="100%" frameborder="0" allow="fullscreen" 
              allowfullscreen></iframe>
          </body>
        </html>
      ''';
    } else {
      htmlContent = '''
        <html>
          <head>
            <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
            <style>
              body { margin: 0px; background-color: lightgray; }
            </style>
          </head>
          <body>
            <iframe 
              src="https://www.youtube.com/embed/$videoId?autoplay=0" 
              width="100%" height="100%" frameborder="0" allow="fullscreen" 
              allowfullscreen></iframe>
          </body>
        </html>
      ''';
    }

    final String contentBase64 = base64Encode(
      const Utf8Encoder().convert(htmlContent),
    );
    return Uri.parse('data:text/html;base64,$contentBase64');
  }
}
