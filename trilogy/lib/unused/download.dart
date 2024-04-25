import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// This class is a widget that allows the user to view a pdf.
class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  const PdfViewer({super.key, required this.pdfUrl});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  PDFDocument? document;

  void initPdf() async {
    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //package
        body: document != null
            ? Column(children: [
                PDFViewer(
                  document: document!,
                ),
                IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      //code to download pdf
                    })
              ])
            : Center(child: CircularProgressIndicator()));
  }
}

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //get from firebase field
  String url = "https:idk";

  @override
  void initState() {
    super.initState();
  }

  Future<void> downloadPdf() async {
    Map<Permission, PermissionStatus> statuses = await [
      //local storage
      //Permission Hander
      Permission.storage,
    ].request();

    if (statuses[Permission.storage]!.isGranted) {
      var dir = await DownloadsPathProvider.downloadsDirectory;
      if (dir != null) {
        String saveName = "getFirebaseName.pdf";
        String savePath = dir.path + "/" + saveName;
        print(savePath);

        try {
          await Dio().download(url, savePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              print("yay");
            }
          });
          print("file downloaded yippee");
        } on DioError catch (e) {
          print(e.message);
        }
      }
    } else {
      print("no persmision, permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FloatingActionButton(
          child: const Icon(Icons.upload),
          onPressed: () async {
            // pickFile();
            Navigator.pop(context);
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
