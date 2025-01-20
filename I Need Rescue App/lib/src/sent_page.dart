import 'package:flutter/material.dart';

class SentPage extends StatefulWidget {
  const SentPage({super.key});

  @override
  State<SentPage> createState() => _SentPageState();
}

class _SentPageState extends State<SentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Request Sent'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Thumbs up visual cue
            Icon(Icons.thumb_up, size: 200,),
            // Reassuring confirmation message
            const Text(
                "Your request has been sent\nResponders are on their way",
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            // Edit request button
            Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color.fromRGBO(10, 10, 50, 1),
                ),
                child: TextButton(
                  onPressed: () {
                    // Taken back to main page
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white,),
                      Text('Edit Request', style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}