import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flash_downloader/models/download_task.dart';

class NetworkManager {
  static Dio dio = Dio();

  static Future<void> download(DownloadTask downloadTask) async {
    int? recievedInBytes = downloadTask.recievedInBytes;
    Options options = Options(
      responseType: ResponseType.bytes,
      followRedirects: true,
      headers: recievedInBytes == null
          ? null
          : {
              'Range': 'bytes=${downloadTask.recievedInBytes}-',
            },
    );
    try {
      //TODO: Check if resume worked else it is a download from scratch
      //TODO: If it is a resume, continue writing data from where it left instead of from scratch
      await dio.download(
        downloadTask.urlPath,
        downloadTask.tempSavePath,
        deleteOnError: false,
        options: options,
        cancelToken: downloadTask.cancelToken,
        onReceiveProgress: (received, total) {
          downloadTask.status = DownloadTaskStatus.downloading;
          if (recievedInBytes != null) {
            //This is a resume download
            //Progress will continue from where it left
            downloadTask.recievedInBytes = recievedInBytes + received;
            downloadTask.sizeInBytes = recievedInBytes + total;
          } else {
            downloadTask.sizeInBytes = total;
            downloadTask.recievedInBytes = received;
          }
        },
      );
      downloadTask.status = DownloadTaskStatus.merging;
      downloadTask.mergeParts();
    } on DioException catch (e) {
      if (e.type.name == DioExceptionType.cancel.name) {
        log('Either download cancelled or paused',
            name: 'NetworkManager download');
      } else {
        downloadTask.status = DownloadTaskStatus.error;
        log(e.toString(), name: 'NetworkManager.download');
      }
    }
  }
}
