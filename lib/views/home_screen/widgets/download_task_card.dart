import 'package:flash_downloader/models/download_task.dart';
import 'package:flutter/material.dart';

class DonwloadTaskCard extends StatelessWidget {
  final DownloadTask downloadTask;
  const DonwloadTaskCard({super.key, required this.downloadTask});
  //TODO: Delete Button
  //TODO: Pause Button
  //TODO: Share Link
  //TODO: Share File if downloaded
  //TODO: Open if downloaded

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListenableBuilder(
          listenable: downloadTask,
          builder: (context, child) {
            return Card(
              color: Colors.grey.shade900,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(downloadTask.fileName),
                        LinearProgressIndicator(
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          value: downloadTask.progress,
                          color: downloadTask.isCancelable ? null : Colors.red,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(downloadTask.status.name),
                            if (downloadTask.sizeInMb != null &&
                                downloadTask.recievedInMb != null)
                              Text(
                                  '${downloadTask.recievedInMb!.toStringAsFixed(2)} MB/${downloadTask.sizeInMb!.toStringAsFixed(2)} MB'),
                            if (downloadTask.progress != null)
                              Text(
                                  '${(downloadTask.progress! * 100).toStringAsFixed(2)}%'),
                            if (downloadTask.downloadSpeed != null)
                              Text(downloadTask.downloadSpeed!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: downloadTask.isCancelable
                          ? () => downloadTask.cancelDownload()
                          : null,
                      icon: Icon(
                        Icons.cancel,
                        color: downloadTask.isCancelable
                            ? Colors.red
                            : Colors.grey,
                      )),
                  IconButton(
                      onPressed:
                          downloadTask.status == DownloadTaskStatus.downloading
                              ? () => downloadTask.pauseDownload()
                              : () => downloadTask.startDownload(),
                      icon: Icon(
                        downloadTask.status == DownloadTaskStatus.downloading
                            ? Icons.pause
                            : Icons.play_arrow,
                      )),
                ]),
              ),
            );
          }),
    );
  }
}
