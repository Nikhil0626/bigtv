import 'package:flutter/material.dart';

class ChotaInfo extends StatelessWidget {
  const ChotaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 70),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ListTile(
              leading: const Card(
                color: Colors.purple,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.info_outline, color: Colors.white),
                ),
              ),
              title: const Text('About Us', style: TextStyle(fontSize: 16)),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 24,
              ),
              onTap: () {

              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.phone_outlined, color: Colors.white),
                  )),
              title: const Text('Contact Us', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.tv_outlined, color: Colors.white),
                  )),
              title: const Text('Advertise With Us',
                  style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Card(
                  color: Colors.deepOrangeAccent,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.article_outlined, color: Colors.white),
                  )),
              title: const Text('Terms & Conditions',
                  style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Card(
                  color: Colors.lightGreen,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.lock_clock_outlined, color: Colors.white),
                  )),
              title:
                  const Text('Privacy Policy', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
