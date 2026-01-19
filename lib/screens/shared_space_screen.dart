import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';

class SharedSpaceScreen extends StatelessWidget {
  const SharedSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.people_alt_outlined),
            SizedBox(width: 5),
            Text(strings.sharedSpaceText),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Text(
              strings.sharedSpaceLargeDescriptionText,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              
              style: ButtonStyle(
                maximumSize: WidgetStatePropertyAll(Size.infinite),
                elevation: WidgetStatePropertyAll(5)
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded),
                  SizedBox(width: 5,),
                  Text(strings.inviteSomeoneText, style: TextStyle(fontSize: 16),),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              strings.inviteSomeoneDescriptionText,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 50),
            
          ],
        ),
      ),
    );
  }
}
