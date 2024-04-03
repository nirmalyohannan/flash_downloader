import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flash_downloader/helper/extensions.dart';
import 'package:flash_downloader/models/download_task.dart';
import 'package:flash_downloader/views/home_screen/widgets/download_task_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DownloadTask> downloadTasksList = [];
  TextEditingController urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            downloadTasksList.isEmpty
                ? const Center(child: Text('No Task'))
                : Column(
                    children: List.generate(downloadTasksList.length, (index) {
                      DownloadTask downloadTask = downloadTasksList[index];
                      return DonwloadTaskCard(downloadTask: downloadTask);
                    }),
                  )
          ],
        ),
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: urlController,
        decoration: InputDecoration(
            hintText: 'Search or Paste URL',
            isDense: true,
            border: const OutlineInputBorder(),
            suffix: IconButton(
              onPressed: () {
                urlController.clear();
              },
              icon: const Icon(Icons.clear),
            )),
        onSubmitted: (value) async {
          String urlPath = value;
          String savePath;
          //TODO: Setup Path for all platforms
          if (Platform.isAndroid) {
            savePath = await ExternalPath.getExternalStoragePublicDirectory(
                ExternalPath.DIRECTORY_DOWNLOADS);
          } else {
            //For Windows
            savePath = 'C:/Users/nirma/Downloads'; //! Temporary
          }
          savePath += '/Flash Downloader';
          Directory saveDir = Directory(savePath);
          if (!saveDir.existsSync()) {
            saveDir.createSync(recursive: true);
          }
          savePath += '/${urlPath.split('/').last}';
          //TODO: Check if file already downloading(avoid collision)
          if (checkIfDownloadInProgress(urlPath)) {
            "File already downloading".showSnackbar();
          }

          if (checkIfFileExists(savePath)) {
            "File already exists".showSnackbar();
            //TODO: replace or rename file prompt
          }
          //TODO: Check if disk space is sufficient

          var downloadTask = DownloadTask(
            urlPath: urlPath,
            savePath: savePath,
            startTime: DateTime.now(),
          );

          downloadTask.startDownload();
          downloadTasksList.add(downloadTask);
          setState(() {});
        },
      ),
    );
  }

  bool checkIfDownloadInProgress(String url) {
    return downloadTasksList.any((element) => element.urlPath == url);
  }

  bool checkIfFileExists(String savePath) {
    return File(savePath).existsSync();
  }
}
