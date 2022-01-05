import 'package:app/services/pr.dart';
import 'package:app/services/theme.dart';
import 'package:app/ui/colors.dart';
import 'package:app/ui/repo_card.dart';
import 'package:app/ui/skeletons/skeleton_repo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<PrService>(
            create: (_) => PrService(endpoint: "localhost"))
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'PullRequest Dashboard',
            theme: themeService.theme,
            home: const Home(title: 'PullRequest Dashboard'),
          );
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [pink, orange],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Center(
            child: Consumer<PrService>(
              builder: (context, prService, child) {
                return widgetsForPRs(prService);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () => {
              themeService.setTheme(
                  themeService.currentBrightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light)
            },
            child: Icon(themeService.currentBrightness == Brightness.light
                ? Icons.nightlight_round
                : Icons.wb_sunny),
          );
        },
      ),
    );
  }
}

Widget widgetsForPRs(PrService prService) {
  // TODO: errorHandling?
  // if (snapshot.hasError) {
  //   // TODO: show snackbar instead
  //   return Column(children: [
  //     const Icon(
  //       Icons.error_outline,
  //       color: Colors.red,
  //       size: 60,
  //     ),
  //     Padding(
  //       padding: const EdgeInsets.only(top: 16),
  //       child: Text('Error: ${snapshot.error}'),
  //     ),
  //   ]);
  // }
  if (prService.isLoading) {
    return ListView(
      children: const [RepositoryCardSkeleton(), RepositoryCardSkeleton()],
    );
  }

  List<Repository> repos = prService.repos!;
  repos.sort((a, b) => b.pullrequests.length.compareTo(a.pullrequests.length));
  return ListView(
    children: repos
        .map((repo) => RepositoryCard(
              repo: repo,
            ))
        .toList(),
  );
}
