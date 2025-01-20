import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/request.dart';
import 'src/geoposition.dart';
import 'src/sent_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for Supabase to initialize before running app
  await Supabase.initialize(
      url: "https://xqoogfxwothtjpskdbdc.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxb29nZnh3b3RodGpwc2tkYmRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyMjc3MDQsImV4cCI6MjA1MjgwMzcwNH0.YQj8wT2rbTkesNJbSfv41zBK-AuUU64Ccs5CdKt-CQc"
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I Need Rescue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Request Rescue'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Controllers to track entered info
  TextEditingController peopleCountController = TextEditingController();
  TextEditingController injuryCountController = TextEditingController();
  int dangerLevel = 1;

  // Can be used to edit sent request
  String requestID = '';

  void navigateSentPage(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => SentPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
                "Please be as honest as you can. A lie can cost someone else's life.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[900],
              ),
            ),
          ),
          const Spacer(),

          // Size of citizen's group
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Number of people with you:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: peopleCountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "#",
                    hintStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Number of people requiring urgent rescue
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Number of critically injured people:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: injuryCountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "#",
                    hintStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          // Explanation of critically injured
          const Text(
            "(needs immediate care; e.g. bleeding out, unconscious)",
            style: TextStyle(
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Level of imminent danger facing the group
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Danger Level:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 150,
                child: Slider(
                  value: dangerLevel.toDouble(),
                  divisions: 9,
                  min: 1,
                  max: 10,
                  onChanged: (value) {
                    setState(() {
                      dangerLevel = value.toInt();
                    });
                  },
                ),
              ),
              Text(
                dangerLevel.toInt().toString(),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          // Explanation of danger level
          const Text(
            "(1 - No danger | 10 - Imminent Life Threat)",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          const Spacer(),

          // Send request button
          Padding(
            padding: const EdgeInsets.all(20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Color.fromRGBO(10, 10, 50, 1),
              ),
              child: TextButton(
                onPressed: () async {

                  try {
                    int peopleCount = int.parse(peopleCountController.value.text);
                    int injuryCount = int.parse(injuryCountController.value.text);
                    // If descrepancy in injuryCount and peopleCount, activate AlertDialog
                    if(injuryCount > peopleCount) {
                      throw Exception("Number of critically injured people exceeds reported total number of people");
                    }

                    // Try getting GPS location
                    Map<String, double> location = await getGPSLocation();
                    // Generate unique request id, else reuse current one
                    bool isUpdate = true;
                    if(requestID == '') {
                      requestID = "${DateTime.timestamp().toString()}"
                          "|${location['latitude']}"
                          "|${location['longitude']}";
                      isUpdate = false;
                    }
                    // Try sending request to Supabase
                    await sendRequest(requestID, peopleCount, injuryCount, dangerLevel, location, isUpdate);

                    // If everything successful, navigate to confirmation screen
                    navigateSentPage(context);
                  } catch(identifier, st) {
                    // GPS or Supabase access failed, display error popup
                    showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: const Text("Couldn't send request, try again"),
                            content: Text(identifier.toString()),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'))
                            ],
                          );
                        });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, color: Colors.white,),
                      Text('Send Request', style: TextStyle(color: Colors.white, fontSize: 20))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
