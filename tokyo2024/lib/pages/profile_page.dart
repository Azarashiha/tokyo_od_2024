// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'calendar_page.dart'; // パスを確認
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

// 追加：チャットページをインポート
import 'chat_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<List<Event>> _getAllEvents() async {
    // SharedPreferencesからイベントを取得
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(eventsJson);
      List<Event> allEvents = [];
      decoded.forEach((key, value) {
        final eventsList = (value as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
        allEvents.addAll(eventsList);
      });
      return allEvents;
    }
    return [];
  }

  Future<void> _exportEvents(BuildContext context) async {
    try {
      List<Event> events = await _getAllEvents();
      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エクスポートするイベントがありません')),
        );
        return;
      }

      // イベントをCSVに変換
      String csvData = 'Title,Memo,Start,End\n';
      for (var event in events) {
        String title = event.title.replaceAll('"', '""');
        String memo = event.memo.replaceAll('"', '""');
        String start = event.start.toIso8601String();
        String end = event.end.toIso8601String();
        csvData +=
            '"$title","$memo","$start","$end"\n'; // カンマを含む場合に対応
      }

      // 一時ディレクトリを作成
      final directory = await getTemporaryDirectory();
      final csvPath = '${directory.path}/events.csv';
      final zipPath = '${directory.path}/events.zip';

      // CSVファイルに書き込み
      final csvFile = File(csvPath);
      await csvFile.writeAsString(csvData);

      // ZIPアーカイブを作成
      final archive = Archive();
      final csvBytes = await csvFile.readAsBytes();
      archive.addFile(ArchiveFile('events.csv', csvBytes.length, csvBytes));

      final zipData = ZipEncoder().encode(archive)!;
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);

      // ZIPファイルを共有
      await Share.shareXFiles([XFile(zipPath)], text: 'Here are your exported events.');

      // オプション：共有後に一時ファイルを削除
      // await csvFile.delete();
      // await zipFile.delete();
    } catch (e) {
      print('エクスポートエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エクスポートに失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('イベントをエクスポート'),
            onTap: () => _exportEvents(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('チャット'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
