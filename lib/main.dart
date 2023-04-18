import 'package:flutter/material.dart';
import 'package:img_syncer/global.dart';
import 'package:provider/provider.dart';
import 'package:img_syncer/state_model.dart';
import 'gallery_body.dart';
import 'setting_body.dart';
import 'sync_body.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:img_syncer/logger.dart';

const seedThemeColor = Color.fromARGB(255, 18, 159, 135);

void main() {
  Global.init().then((e) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => settingModel),
            ChangeNotifierProvider(create: (context) => assetModel),
            ChangeNotifierProvider(create: (context) => stateModel),
          ],
          child: const MyApp(),
        ),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'PHO';
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        late ColorScheme lightColorScheme;
        late ColorScheme darkColorScheme;
        if (lightDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
        } else {
          logger.i("lightDynamic is null");
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedThemeColor,
            brightness: Brightness.light,
          );
        }
        if (darkDynamic != null) {
          darkColorScheme = darkDynamic.harmonized();
        } else {
          logger.i("darkDynamic is null");
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedThemeColor,
            brightness: Brightness.dark,
          );
        }

        return AdaptiveTheme(
            light: ThemeData.from(
                colorScheme: lightColorScheme, useMaterial3: true),
            dark: ThemeData.from(
                colorScheme: darkColorScheme, useMaterial3: true),
            initial: AdaptiveThemeMode.system,
            builder: (theme, darkTheme) {
              return MaterialApp(
                title: _title,
                debugShowCheckedModeBanner: false,
                home: const MyHomePage(title: _title),
                theme: theme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
              );
            });
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final localFolder = prefs.getString("localFolder");
      if (localFolder != null) {
        Provider.of<SettingModel>(context, listen: false)
            .setLocalFolder(localFolder);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        appBar = AppBar(
          centerTitle: true,
          title: Text(
            'Setting',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
        break;
    }
    return Consumer<StateModel>(
      builder: (context, model, child) => Scaffold(
        appBar: appBar,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const GalleryBody(
              useLocal: true,
            ),
            const GalleryBody(useLocal: false),
            Consumer<SettingModel>(
              builder: (context, model, child) {
                return SyncBody(
                  localFolder: model.localFolder,
                );
              },
            ),
            const SettingBody(),
          ],
        ),
        bottomNavigationBar: model.isSelectionMode
            ? null
            : NavigationBar(
                onDestinationSelected: _onItemTapped,
                selectedIndex: _selectedIndex,
                destinations: <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.phone_android,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Local',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Cloud',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud_sync,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Sync',
                  ),
                  // NavigationDestination(
                  //   icon: Icon(Icons.settings,
                  //       color: Theme.of(context).iconTheme.color),
                  //   label: 'Setting',
                  // ),
                ],
              ),
      ),
    );
  }
}
