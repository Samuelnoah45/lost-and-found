import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lost_and_foud/auth/login_page.dart';
import 'package:lost_and_foud/bloc/counter_bloc.dart';
import 'package:lost_and_foud/pages/home_page.dart';
import 'package:lost_and_foud/pages/find_item.dart';
import 'package:lost_and_foud/pages/add_item.dart';
import 'package:lost_and_foud/pages/my_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageItem {
  String label;
  Icon icon;

  PageItem(this.label, this.icon);
}

var pages = [HomePage(), FindItem(), AddItem()];

var pageItems = <PageItem>[
  PageItem("Home", const Icon(Icons.home)),
  PageItem('Find', const Icon(Icons.search)),
  PageItem('Add Item', const Icon(Icons.add)),
];
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeLayout(),
  ));
}

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  PageController _pageController = PageController();
  int selectedPage = 0;
  String username = '';
  String email = '';
  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    super.initState;
    getUsername();
    getEmail();
  }

  void getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
    });
  }

  void getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  String getInitials() {
    if (username.isNotEmpty) {
      return username.split(" ").map((item) => item[0]).join("");
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(pageItems[selectedPage].label),
          // automaticallyImplyLeading: false,
        ),
        drawer: buildDrawer(),
        body: buildPageView(),
        bottomNavigationBar: buildBottomNav(),
      ),
    );
  }

  Widget buildPageView() {
    return SizedBox(
      child: PageView(
        controller: _pageController,
        children: pages,
        onPageChanged: (index) {
          onPageChange(index);
        },
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: selectedPage,
      type: BottomNavigationBarType.fixed,
      items: pageItems
          .map((item) =>
              BottomNavigationBarItem(icon: item.icon, label: item.label))
          .toList(),
      onTap: (int index) {
        _pageController.animateToPage(index,
            duration: const Duration(microseconds: 1000), curve: Curves.easeIn);
      },
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            // <-- SEE HERE
            decoration: BoxDecoration(color: const Color(0xff764abc)),
            accountName: Text(
              username.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                return Text(
                  email.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            currentAccountPicture: CircleAvatar(
              child: BlocBuilder<CounterBloc, CounterState>(
                builder: (context, state) {
                  if (state is CounterIncState) {
                    return Text(state.email);
                  }
                  
                  return Text("No email");
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
            ),
            title: const Text('My Items'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyItems(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
            ),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ));
            },
          ),
        ],
      ),
    );
  }

  onPageChange(int index) {
    setState(() {
      selectedPage = index;
    });
  }
}
