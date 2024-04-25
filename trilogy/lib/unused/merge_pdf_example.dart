import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';

// This class attempts to merge two pdfs together, but was unsuccessful/
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Multiple Files'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Click the button to share files',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final List<String> filePaths = await createSampleFiles();
                if (filePaths.isNotEmpty) {
                  await shareMultipleFiles(filePaths);
                } else {
                  print('Failed to create sample files');
                }
              },
              child: Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> createSampleFiles() async {
    final List<String> filePaths = [];
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      for (int i = 1; i <= 2; i++) {
        final File newFile = File('${appDocDir.path}/file$i.txt');
        await newFile.writeAsString('Sample content for file $i');
        filePaths.add(newFile.path);
      }
    } catch (e) {
      print('Error creating files: $e');
    }
    return filePaths;
  }

  Future<void> shareMultipleFiles(List<String> filePaths) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String zipPath = '${appDocDir.path}/files.zip';

      final archive = Archive();
      for (final filePath in filePaths) {
        final file = File(filePath);
        final fileName = filePath.split('/').last;

        final fileContent = await file.readAsBytes();
        archive.addFile(ArchiveFile(fileName, fileContent.length, fileContent));
      }

      final zipFile = File(zipPath);
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      await zipFile.writeAsBytes(zipData!);

      await Share.shareFiles([zipPath]);
    } catch (e) {
      print('Error sharing files: $e');
    }
  }
}
