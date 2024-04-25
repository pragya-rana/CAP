import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// This class is a widget that allows the user to see the PDF in real-time.
class PDFViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;
  PDFViewer({required this.pdfUrl, required this.title});

  @override
  _PDFViewer createState() => _PDFViewer();
}

class _PDFViewer extends State<PDFViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  // This method allows the PDF to be shared across a variety of apps.
  Future<void> downloadPdf(String downloadUrl) async {
    final Dio dio = Dio();
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String filePath = '$appDocPath/application.pdf';

      await dio.download(downloadUrl, filePath,
          onReceiveProgress: (received, total) {});

      await Share.shareFiles([filePath]);
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  // This builds the actual layout of the PDF Viewer
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.more_vert_sharp,
              color: Colors.black,
            ),
            onPressed: () {
              downloadPdf(widget.pdfUrl);
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
      ),
    );
  }
}
