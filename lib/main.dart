import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'services/artwork_cache_service.dart';
import 'services/library_service.dart';
import 'services/lyrics_service.dart';
import 'services/playlist_store.dart';
import 'services/recent_plays_service.dart';
import 'services/sleep_timer_service.dart';
import 'state/app_nav_state.dart';
import 'state/library_state.dart';
import 'state/player_state.dart';
import 'state/playlist_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Android 13+ hides the media/lock-screen notification (and the transport
  // controls it hosts) unless this is granted at runtime - declaring it in
  // the manifest alone isn't enough.
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Manufacturer battery managers (Samsung One UI in particular) kill the
  // background playback service - and with it, lock-screen controls - unless
  // the app is exempted from battery optimization.
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.lyd.sonicaudioplayer.channel.audio',
    androidNotificationChannelName: 'Lyd playback',
    androidNotificationOngoing: true,
  );

  final libraryService = LibraryService();
  final playlistStore = PlaylistStore();
  final artworkCache = ArtworkCacheService(libraryService);
  final sleepTimer = SleepTimerService();
  final recentPlays = RecentPlaysService();
  recentPlays.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: libraryService),
        Provider.value(value: artworkCache),
        Provider.value(value: recentPlays),
        Provider(create: (_) => LyricsService()),
        ChangeNotifierProvider(create: (_) => AppNavState()),
        ChangeNotifierProvider(create: (_) => LibraryState(libraryService)),
        ChangeNotifierProvider(create: (_) {
          final state = PlaylistState(playlistStore);
          state.init();
          return state;
        }),
        ChangeNotifierProvider(
          create: (_) => PlayerState(
            artworkCache: artworkCache,
            sleepTimer: sleepTimer,
            recentPlays: recentPlays,
          ),
        ),
      ],
      child: const LydApp(),
    ),
  );
}

class LydApp extends StatelessWidget {
  const LydApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
