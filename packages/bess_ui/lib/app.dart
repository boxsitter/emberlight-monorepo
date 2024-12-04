import 'package:flutter/material.dart';
import 'package:get/get.dart';

//import 'utils/constants/colors.dart';
import 'utils/constants/text_strings.dart';
import 'utils/device/web_material_scroll.dart';
import 'utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: ConstTexts.appName,
      themeMode: ThemeMode.light,
      theme: BessieAppTheme.lightTheme,
      darkTheme: BessieAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      routes: {
        '/': (context) => const FirstScreen(),
        '/second-screen': (context) => const SecondScreen(),
      },

      getPages: [
        GetPage(name: '/', page: () => const FirstScreen()),
        GetPage(name: '/second-screen', page: () => const SecondScreen()),
        GetPage(name: '/second-screen/:userId', page: () => const SecondScreen()),
      ],
      // home: const FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// SIMPLE NAVIGATION
            const Text(
              'Simple Navigation: Default Flutter Navigator VS GetX Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SecondScreen(),
                      ),
                    );
                  },
                child: const Text('Default Navigation'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  onPressed: () => Get.to(() => const SecondScreen()),
                  child: const Text('GetX Navigation'),
              ),
            ),

            /// NAMED NAVIGATION
            const SizedBox(height: 50),
            const Divider(),
            const Text(
              'Named Navigation: Flutter Navigator VS GetX Named Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/second-screen');
                },
                child: const Text('Default Named Navigation'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/second-screen');
                },
                child: const Text('GetX Named Navigation'),
              ),
            ),

            /// PASS DATA
            const SizedBox(height: 50),
            const Divider(),
            const Text(
              'Pass Data between screens - GetX',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/second-screen', arguments: 'GetX is fun');
                },
                child: const Text('GetX Pass Data'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/second-screen?device=phone&id=345&name=Leyton');
                },
                child: const Text('Pass Data in URL'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    '/second-screen?device=phone&id=345&name=Leyton',
                    arguments: 'GetX is fun!',
                  );
                },
                child: const Text('Pass Data in URL with arguments'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Get.arguments ?? ''),

            Text('Device = ${Get.parameters['device'] ?? ''}'),
            Text('ID = ${Get.parameters['id'] ?? ''}'),
            Text('Name = ${Get.parameters['name'] ?? ''}'),
          ]
        )
      )
    );
  }
}


