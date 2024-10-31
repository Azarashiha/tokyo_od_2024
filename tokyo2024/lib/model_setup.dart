import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter/foundation.dart';

bool _isModelPrepared = false;

Future<String> copyModelToDocuments() async {
  debugPrint('モデルのコピーを開始...');
  final ByteData data = await rootBundle.load('assets/gemma-2b-it-cpu-int4.bin');
  debugPrint('Asset loaded, size: ${data.lengthInBytes} bytes');
  
  final String documentsPath = (await getApplicationDocumentsDirectory()).path;
  final String modelPath = '$documentsPath/gemma-2b-it-cpu-int4.bin';
  
  final File modelFile = File(modelPath);
  if (!await modelFile.exists()) {
    debugPrint('Writing model file...');
    await modelFile.writeAsBytes(data.buffer.asUint8List());
    debugPrint('Model file written successfully');
  } else {
    debugPrint('Model file already exists');
  }
  
  return modelPath;
}

Future<void> initializeModel(String modelPath, String expectedHash) async {
  try {
    debugPrint('Starting initialization process...');
    
    final gemma = FlutterGemmaPlugin.instance;
    
    if (!await gemma.isLoaded) {
      debugPrint('Loading model...');
      try {
        await for (int progress in gemma.loadNetworkModelWithProgress(
          url: 'file://$modelPath'
        )) {
          debugPrint('Loading progress: $progress%');
        }
      } catch (e) {
        debugPrint('Error during model loading: $e');
        rethrow;
      }
    }
    
    if (!await gemma.isInitialized) {
      debugPrint('Initializing model...');
      try {
        await gemma.init(
          maxTokens: 512,
          temperature: 1.0,
          topK: 1,
          randomSeed: 1,
        );
        
        debugPrint('Model initialization completed');
      } catch (e) {
        debugPrint('Error during initialization: $e');
        rethrow;
      }
    }
    
    _isModelPrepared = true;
    debugPrint('Model setup completed successfully');
    
  } catch (e) {
    debugPrint('Error in initialization process: $e');
    throw Exception('Failed to setup model: $e');
  }
}