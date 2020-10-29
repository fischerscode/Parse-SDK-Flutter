import 'dart:async';
import '../lib/example_multiple_livequeries.dart';

void main(List<String> arguments) async {
  await init();
  await listen();

  while(true){
    await Future<void>.delayed(const Duration(seconds: 1));
    createNoise();
  }
}
