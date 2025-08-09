import 'package:flutter_test/flutter_test.dart';
import 'package:weorbis_motion_detector_example/main.dart';

void main() {
  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(const MotionRecognitionApp());
    expect(find.text('Motion Detector Example'), findsOneWidget);
  });
}
