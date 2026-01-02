import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/live/screens/live_screen.dart';
import '../../features/text/screens/text_screen.dart';
import '../../features/saved/screens/saved_screen.dart';
import '../../features/saved/screens/flashcard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/live',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/live',
            name: 'live',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LiveScreen(),
            ),
          ),
          GoRoute(
            path: '/text',
            name: 'text',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TextScreen(),
            ),
          ),
          GoRoute(
            path: '/saved',
            name: 'saved',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SavedScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/flashcards',
        name: 'flashcards',
        builder: (context, state) {
          final phrases = state.extra as List<Map<String, dynamic>>?;
          return FlashcardScreen(phrases: phrases ?? []);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/live'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/live');
        break;
      case 1:
        context.go('/text');
        break;
      case 2:
        context.go('/saved');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update index based on current route
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/live')) {
      _currentIndex = 0;
    } else if (location.startsWith('/text')) {
      _currentIndex = 1;
    } else if (location.startsWith('/saved')) {
      _currentIndex = 2;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.text_fields_outlined),
            selectedIcon: Icon(Icons.text_fields),
            label: 'Text',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_outlined),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
