import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:provider/provider.dart';

import 'src/adaptive_login.dart';
import 'src/adaptive_playlists.dart';
import 'src/app_state.dart';
import 'src/playlist_details.dart';

// From https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw
const flutterDevAccountId = 'UCwXdFgeE9KYzlDdR7TG9cMw';

// TODO: Replace with your YouTube API Key
const youTubeApiKey = 'AIzaSyCClmhpIer7Lm1Fi-xcZ-gYvSr6KS2-8GM';
// Add from this line
// From https://developers.google.com/youtube/v3/guides/auth/installed-apps#identify-access-scopes
final scopes = [
  'https://www.googleapis.com/auth/youtube.readonly',
];

// TODO: Replace with your Client ID and Client Secret for Desktop configuration
final clientId = ClientId(
  '901705061554-mi6453idmsep2kntas697pltib780qie.apps.googleusercontent.com',
  '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',
);
final clientIdWeb = ClientId(
    '901705061554-7hhhrj0vojp7f4lrl2h75ru40ebus0ah.apps.googleusercontent.com',
    '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');
final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const AdaptivePlaylists();
      },
      redirect: (context, state) {
        if (!context.read<AuthedUserPlaylists>().isLoggedIn) {
          return '/login';
        } else {
          return null;
        }
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          builder: (context, state) {
            return AdaptiveLogin(
              clientId: clientIdWeb,
              scopes: scopes,
              loginButtonChild: const Text('Login to YouTube'),
            );
          },
        ),
        GoRoute(
          path: 'playlist/:id',
          builder: (context, state) {
            final title = state.uri.queryParameters['title']!;
            final id = state.pathParameters['id']!;
            return Scaffold(
              appBar: AppBar(title: Text(title)),
              body: PlaylistDetails(
                playlistId: id,
                playlistName: title,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

void main() {
  if (youTubeApiKey == 'AIzaNotAnApiKey') {
    print('youTubeApiKey has not been configured.');
    exit(1);
  }

  runApp(ChangeNotifierProvider<AuthedUserPlaylists>(
    create: (context) => AuthedUserPlaylists(),
    child: const PlaylistsApp(),
  ));
}

class PlaylistsApp extends StatelessWidget {
  const PlaylistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Your Playlists',
      theme: FlexColorScheme.light(
        scheme: FlexScheme.red,
        useMaterial3: true,
      ).toTheme,
      darkTheme: FlexColorScheme.dark(
        scheme: FlexScheme.red,
        useMaterial3: true,
      ).toTheme,
      themeMode: ThemeMode.system, // Or ThemeMode.System if you'd prefer
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
