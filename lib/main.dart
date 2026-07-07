import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'services/artwork_cache_service.dart';
import 'services/library_service.dart';
import 'services/lyrics_service.dart';
import 'services/playlist_store.dart';
import 'services/sleep_timer_service.dart';
import 'state/library_state.dart';
import 'state/player_state.dart';
import 'state/playlist_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.raptor.raptor_player.channel.audio',
    androidNotificationChannelName: 'Raptor Player playback',
    androidNotificationOngoing: true,
  );

  final libraryService = LibraryService();
  final playlistStore = PlaylistStore();
  final artworkCache = ArtworkCacheService(libraryService);
  final sleepTimer = SleepTimerService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: libraryService),
        Provider.value(value: artworkCache),
        Provider(create: (_) => LyricsService()),
        ChangeNotifierProvider(create: (_) => LibraryState(libraryService)),
        ChangeNotifierProvider(create: (_) {
          final state = PlaylistState(playlistStore);
          state.init();
          return state;
        }),
        ChangeNotifierProvider(
          create: (_) => PlayerState(artworkCache: artworkCache, sleepTimer: sleepTimer),
        ),
      ],
      child: const RaptorPlayerApp(),
    ),
  );
}

class RaptorPlayerApp extends StatelessWidget {
  const RaptorPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raptor Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
