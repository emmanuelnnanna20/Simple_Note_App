import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_note_app/main.dart';

void main() {
  testWidgets('Add and delete note test', (WidgetTester tester) async {
    // Build the NoteApp widget.
    await tester.pumpWidget(NoteApp());

    // Verify no notes initially (no ListTile found).
    expect(find.byType(ListTile), findsNothing);

    // Enter text into the TextField.
    await tester.enterText(find.byType(TextField), 'Test note');

    // Tap the 'Add Note' button.
    await tester.tap(find.text('Add Note'));
    await tester.pump();

    // Verify the note appears in the list.
    expect(find.text('Test note'), findsOneWidget);

    // Tap the delete icon to remove the note.
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Verify the note is removed.
    expect(find.text('Test note'), findsNothing);
  });
}
