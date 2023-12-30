// ignore_for_file: avoid_print

import 'package:fftea/fftea.dart';
void fft() {
  final data = [1.0, 2.0, 3.0, 4.0, 50.0, 44.0,];
  final fft = FFT(data.length);
  final transformedData = fft.realFft(data);
  final magnitudes = transformedData.magnitudes();

  print('Original data: $data');
  print('FFT magnitudes: $magnitudes');
}
