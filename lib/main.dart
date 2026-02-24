import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/firebase_service.dart';
import 'core/auth_bloc.dart';
import 'features/map/bloc/property_bloc.dart';
import 'features/map/bloc/property_event.dart';
import 'features/home/main_navigation.dart';
import 'features/auth/login_screen.dart';
import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';

import 'core/notification_service.dart';
import 'core/home_widget_service.dart';
import 'features/property_details/property_detail_screen.dart';
import 'features/chat/chat_screen.dart';
import 'models/property.dart';
import 'models/chat_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Notification Service (handles background/foreground)
  await NotificationService().initialize();

  // Initialize Home Widget Service
  await HomeWidgetService.initialize();

  runApp(const RealEstateApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RealEstateApp extends StatefulWidget {
  const RealEstateApp({super.key});

  @override
  State<RealEstateApp> createState() => _RealEstateAppState();
}

class _RealEstateAppState extends State<RealEstateApp> {
  @override
  void initState() {
    super.initState();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null && uri.scheme == 'realestate') {
      debugPrint('Launched from widget with URI: $uri');

      if (uri.host == 'property') {
        final pathSegments = uri.pathSegments; // e.g., ['123']
        final action = uri.queryParameters['action'];

        if (pathSegments.isNotEmpty) {
          final propertyId = pathSegments.first;
          _handlePropertyDeepLink(propertyId, action);
        }
      } else if (uri.host == 'home') {
        // Just open the app, which happens implicitly
      }
    }
  }

  void _handlePropertyDeepLink(String propertyId, String? action) async {
    // Wait for the context to become available (app rendering first frame)
    BuildContext? context;
    int retries = 0;
    while (navigatorKey.currentContext == null && retries < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }
    context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('DeepLink: Context is still null, aborting');
      return;
    }

    // Wait for properties to load if app is cold starting
    final propertyBloc = context.read<PropertyBloc>();

    if (propertyBloc.state.properties.isEmpty) {
      try {
        await propertyBloc.stream
            .firstWhere((state) => state.properties.isNotEmpty)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('DeepLink: Timeout waiting for properties');
      }
    }

    // Find the requested property
    Property? targetProperty;

    // Check if properties are already loaded in state
    if (propertyBloc.state.properties.isNotEmpty) {
      targetProperty = propertyBloc.state.properties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => propertyBloc.state.properties.first,
      );
    }

    if (targetProperty == null) {
      debugPrint('Could not find property with ID: $propertyId');
      return;
    }

    if (action == 'view') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PropertyDetailScreen(property: targetProperty!),
        ),
      );
    } else if (action == 'chat') {
      if (targetProperty.ownerId ==
          context.read<FirebaseService>().currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is your own property')),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: '', // Generate or find ID for existing chat
            currentUserId: context.read<FirebaseService>().currentUserId ?? '',
            otherUserId: targetProperty!.ownerId ?? '',
            otherUserName: 'Dealer', // TODO: Fetch real dealer name
            currentUserName: 'User', // TODO: Fetch real user name
            otherUserProfileImage: null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseService()),
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
        BlocProvider(
          create: (context) =>
              PropertyBloc(firebaseService: context.read<FirebaseService>())
                ..add(LoadProperties()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print("RootListener: Auth State Changed. User: ${state.user?.uid}");
          if (state.user == null) {
            print("RootListener: User is null, expecting navigation...");
            // Use the global navigator key to clear the stack
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Oberoi Realty',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF673AB7),
              primary: const Color(0xFF673AB7),
              secondary: const Color(0xFFFFC107),
              surface: Colors.white,
              error: const Color(0xFFD32F2F),
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Color(0xFF1A237E),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF673AB7),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.user != null) {
                return const MainNavigation();
              }
              return const LoginScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
