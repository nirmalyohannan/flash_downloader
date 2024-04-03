import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flash_downloader/helper/network_manager.dart';
import 'package:flutter/material.dart';

class DownloadTask extends ChangeNotifier {
  final String urlPath;
  final String savePath;
  String? tempSavePath;
  int? sizeInBytes;
  final DateTime startTime;
  final bool isTorrent;
  final int? seeders;
  final int? leechers;
  int? _receivedBytes;
  CancelToken cancelToken = CancelToken();
  DownloadTaskStatus _status = DownloadTaskStatus.waiting;
  List<File> parts = [];
  //--------Download Speed Variables--------//
  DateTime? _prevTimeSpeedCalculated;
  int? _prevBytesSpeedCalculated;
  int? speedInBytesPerMilliSec;
  final Debouncer _downloadSpeedDebouncer = Debouncer(milliseconds: 50);

  DownloadTask({
    required this.urlPath,
    required this.savePath,
    required this.startTime,
    this.isTorrent = false,
    this.sizeInBytes,
    this.seeders,
    this.leechers,
  });
  //TODO: Check if parts exists when re-starting application
  //TODO: If parts does not exist, 'show error data missing'. Resume button starts download from scratch
// <<<<---------Setters and Getters--------->>>>
  int? get recievedInBytes => _receivedBytes;
  set recievedInBytes(int? newBytes) {
    _downloadSpeedDebouncer.run(() => _calculateDownloadSpeed(newBytes));
    _receivedBytes = newBytes;
    notifyListeners();
  }

  String? get downloadSpeed {
    if (speedInBytesPerMilliSec == null) {
      return null;
    }
    //convert to kb perSecond
    var speedInKbPerSecond = (speedInBytesPerMilliSec! * 1000 / 1024);
    if (speedInKbPerSecond > 1000) {
      //convert to mb perSecond
      return '${(speedInKbPerSecond / 1000).toStringAsFixed(2)} MB/s';
    } else {
      //return kb perSecond
      return '${speedInKbPerSecond.toStringAsFixed(2)} KB/s';
    }
  }

  DownloadTaskStatus get status => _status;
  set status(DownloadTaskStatus value) {
    _status = value;
    notifyListeners();
  }

  bool get isCancelable =>
      status != DownloadTaskStatus.canceled &&
      status != DownloadTaskStatus.error;

  double? get progress => recievedInBytes != null && sizeInBytes != null
      ? recievedInBytes! / sizeInBytes!
      : null;

  double? get recievedInMb =>
      recievedInBytes != null ? recievedInBytes! / 1024 / 1024 : null;

  String get fileName => savePath.split('/').last;

  double? get sizeInMb =>
      sizeInBytes != null ? (sizeInBytes! / 1024 / 1024) : null;
  //<<<<<---------------------------->>>>
  //<<<<------------------Methods------------------->>>

  Future<void> mergeParts() async {
    // add last part which was downloading to the parts
    parts.add(File(tempSavePath!));
    File finalFile = File(savePath);
    //delete if a file with the same name already exists
    if (finalFile.existsSync()) {
      finalFile.deleteSync();
    }
    for (var part in parts) {
      await finalFile.writeAsBytes(await part.readAsBytes(),
          mode: FileMode.append);
      part.deleteSync();
    }
    status = DownloadTaskStatus.completed;
  }

  void _calculateDownloadSpeed(
    int? newBytes,
  ) {
    if (newBytes != null) {
      _prevBytesSpeedCalculated ??= 0;
      _prevTimeSpeedCalculated ??= DateTime.now();

      var byteDiff = newBytes - _prevBytesSpeedCalculated!;
      var timeDiff = DateTime.now().difference(_prevTimeSpeedCalculated!);
      var timeDiffMillis = timeDiff.inMilliseconds;
      if (timeDiffMillis != 0) {
        speedInBytesPerMilliSec = byteDiff ~/ timeDiff.inMilliseconds;
      }

      _prevBytesSpeedCalculated = newBytes;
      _prevTimeSpeedCalculated = DateTime.now();
    }
  }

  void startDownload() {
    cancelToken = CancelToken();
    status = DownloadTaskStatus.waiting;
    //TODO: Block parts from being deleted through file manager
    if (tempSavePath != null) {
      //This is a resume download
      //Adding the downloaded part to the list
      File downloadedPart = File(tempSavePath!);
      parts.add(downloadedPart);
      // Setting new tempSavePath to for the next part where resume will be written
      tempSavePath = '$savePath.part${parts.length}';

      calcRecievedBytes();
    } else {
      //This is a download from scratch
      tempSavePath = '$savePath.part${parts.length}';
    }
    NetworkManager.download(this);
  }

  void pauseDownload() async {
    cancelToken.cancel();
    status = DownloadTaskStatus.paused;
  }

  void cancelDownload() {
    cancelToken.cancel();
    status = DownloadTaskStatus.canceled;
    // if the file in savePathUrl exists, it will be removed
    if (File(savePath).existsSync()) {
      File(savePath).deleteSync();
    }
  }

  void calcRecievedBytes() {
    int bytes = 0;
    for (var part in parts) {
      if (part.existsSync()) {
        bytes += part.lengthSync();
      } else {
        //TODO: Part missing! download again from scratch
      }
    }
    recievedInBytes = bytes;
  }
}

enum DownloadTaskStatus {
  waiting,
  downloading,
  canceled,
  paused,
  completed,
  merging,
  error
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;
  Debouncer({this.milliseconds = 500});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
