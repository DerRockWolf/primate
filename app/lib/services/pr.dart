import 'package:app/pb/dashboard/v1/dashboard.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc_or_grpcweb.dart';

// TODO: reload on pull down/ reload button
class PrService extends ChangeNotifier {
  late DashboardServiceClient client;

  bool _loading = true;
  List<Repository>? _repos;

  PrService({required endpoint}) {
    GrpcOrGrpcWebClientChannel channel =
        GrpcOrGrpcWebClientChannel.toSeparatePorts(
            host: endpoint,
            grpcPort: 8081,
            grpcTransportSecure: false,
            grpcWebPort: 8080,
            grpcWebTransportSecure: false);
    client = DashboardServiceClient(channel);
    loadPRs();
  }

  bool get isLoading => _loading;
  List<Repository>? get repos => _repos;

  void loadPRs() async {
    _loading = true;
    _repos = [
      Repository(
          name: "testing-repo",
          url: "https://google.com",
          pullrequests: [
            PR(
                title: "Test this awesome tool",
                url: "https://google.com",
                user: "Mr Pink",
                sourceBranch: "feature/test",
                targetBranch: "main",
                created: DateTime.now(),
                status: "open"),
            PR(
                title: "Add feature x to this insane tool",
                url: "https://google.com",
                user: "Big Baby",
                sourceBranch: "feature/x",
                targetBranch: "main",
                created: DateTime.now().subtract(const Duration(hours: 3)),
                status: "draft"),
          ]),
      Repository(
          name: "empty repo", url: "dev.azure.com/awa", pullrequests: []),
      Repository(name: "smd-tutorial", url: "github.com/awdawd", pullrequests: [
        PR(
            title: "Test this awesome tool",
            url: "github.com/awdawd",
            user: "Mr Pink",
            sourceBranch: "feature/test",
            targetBranch: "main",
            created: DateTime.now().subtract(const Duration(days: 5)),
            status: "open"),
        PR(
            title: "Add feature x to this insane tool",
            url: "dev.azure.com/awa",
            user: "Big Baby",
            sourceBranch: "feature/x",
            targetBranch: "main",
            created: DateTime.now().subtract(const Duration(hours: 3)),
            status: "draft"),
        PR(
            title: "Add feature x to this insane tool",
            url: "https://google.com",
            user: "Big Baby",
            sourceBranch: "feature/x",
            targetBranch: "main",
            created: DateTime.now().subtract(const Duration(days: 3)),
            status: "closed"),
        PR(
            title: "Add feature x to this insane tool",
            url: "https://google.com",
            user: "Big Baby",
            sourceBranch: "feature/x",
            targetBranch: "main",
            created: DateTime.now().subtract(const Duration(days: 4)),
            status: "approved"),
      ]),
    ];
    // var repos = await client.listPullRequests(ListPullRequestsRequest());
    // return repos.items
    //     .map((repo) => Repository(
    //         name: repo.name,
    //         pullrequests: repo.pullrequests
    //             .map((pr) => PR(title: pr.title, url: pr.url))
    //             .toList()))
    //     .toList();
    _loading = false;
    notifyListeners();
  }
}

class PR {
  String title;
  String url;
  String user;
  String sourceBranch;
  String targetBranch;
  DateTime created;
  String status;

  PR(
      {required this.title,
      required this.url,
      required this.user,
      required this.sourceBranch,
      required this.targetBranch,
      required this.created,
      required this.status});
}

class Repository {
  String name;
  String url;
  List<PR> pullrequests;

  Repository(
      {required this.name, required this.url, required this.pullrequests});
}
