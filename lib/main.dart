import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snsmax/cloudbase.dart';
import 'package:snsmax/cloudbase/commands/QueryCurrentUserCommand.dart';
import 'package:snsmax/l10n/localization.dart';
import 'package:snsmax/pages/launch.dart';
import 'package:snsmax/provider/auth.dart';
import 'package:snsmax/provider/collections/users.dart';
import 'package:snsmax/provider/provider.dart';
import 'package:snsmax/routes.dart';
import 'package:snsmax/theme.dart';

void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//
//  // 强制竖屏
//  SystemChrome.setPreferredOrientations([
//    DeviceOrientation.portraitUp,
//    DeviceOrientation.portraitDown,
//  ]);
  // Run app
  App.run();
}

/// App main widget
class App extends StatefulWidget {
  /// Create the app state.
  @override
  _AppState createState() => _AppState();

  /// Run the app.
  static void run() {
    runApp(App());
  }
}

/// App main state
class _AppState extends State<App> {
  /// cache app init
  bool initialized = false;

  /// App layout bot toast builder
  TransitionBuilder botToastBuilder;

  /// Init the widget state
  @override
  void initState() {
    // create bot toast builder.
    botToastBuilder = BotToastInit();

    // run super init state function
    super.initState();

    // Add widgets rendered callback function
    postFrameCallback();
  }

  /// Widgets rendered call function
  ///
  /// [timeSramp] is rending wait time
  void postFrameCallback() async {
    try {
      // get CloudBase auth state
      CloudBaseAuthState authState = await CloudBase().auth.getAuthState();

      // If auth state is null, using anonymously login
      if (authState == null) {
        await CloudBase().auth.signInAnonymously();

        // If login user has expired, refresh access token
      } else if (await CloudBase().auth.hasExpiredAuthState()) {
        await CloudBase().auth.refreshAccessToken();
      }

      // set the widget is initialized
      setState(() {
        initialized = true;
      });
    } catch (e) {
      print(e);
    }

//    QueryCurrentUserCommand.run().then((value) {
//      AuthProvider().user = value.id;
//      UsersCollection().originInsertOrUpdate([value]);
//    });
  }

  /// Build the widget
  ///
  /// [context] is widget [BuildContext]
  @override
  Widget build(BuildContext context) {
    return RootProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: generateTitle,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        supportedLocales: AppLocalizations.locales,
        locale: AppLocalizations.defaultLocale,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        builder: layout,
        navigatorObservers: [BotToastNavigatorObserver()],
        routes: routes,
        initialRoute: R_initialRoute,
      ),
    );
  }

  /// Generate title.
  String generateTitle(BuildContext context) {
    return AppLocalizations.of(context).app.name;
  }

  /// The app layout builder
  ///
  /// [context] is widget build context.
  ///
  /// [child] is app child.
  Widget layout(BuildContext context, Widget child) {
    if (initialized != true) {
      child = const Launch();
    }

    return botToastBuilder(context, child);
  }
}
