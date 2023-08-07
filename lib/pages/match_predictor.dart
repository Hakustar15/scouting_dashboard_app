import 'package:flutter/material.dart';
import 'package:frc_8033_scouting_shared/frc_8033_scouting_shared.dart';
import 'package:scouting_dashboard_app/analysis_functions/match_predictor_analysis.dart';
import 'package:scouting_dashboard_app/color_schemes.g.dart';
import 'package:scouting_dashboard_app/datatypes.dart';
import 'package:scouting_dashboard_app/metrics.dart';
import 'package:scouting_dashboard_app/pages/alliance.dart';
import 'package:scouting_dashboard_app/reusable/navigation_drawer.dart';
import 'package:scouting_dashboard_app/reusable/page_body.dart';
import 'package:scouting_dashboard_app/reusable/scrollable_page_body.dart';

class MatchPredictorPage extends StatefulWidget {
  const MatchPredictorPage({super.key});

  @override
  State<MatchPredictorPage> createState() => _MatchPredictorPageState();
}

class _MatchPredictorPageState extends State<MatchPredictorPage> {
  MatchPredictorAnalysis? analysisFunction;

  @override
  Widget build(BuildContext context) {
    final String blue1 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['blue1'];
    final String blue2 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['blue2'];
    final String blue3 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['blue3'];
    final String red1 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['red1'];
    final String red2 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['red2'];
    final String red3 = (ModalRoute.of(context)!.settings.arguments!
        as Map<String, dynamic>)['red3'];

    return DefaultTabController(
      length: 2,
      child: FutureBuilder(
          future: MatchPredictorAnalysis(
            red1: int.parse(red1),
            red2: int.parse(red2),
            red3: int.parse(red3),
            blue1: int.parse(blue1),
            blue2: int.parse(blue2),
            blue3: int.parse(blue3),
          ).getAnalysis(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Match Predictor"),
                ),
                body: PageBody(child: Text("Error: ${snapshot.error}")),
                drawer: (ModalRoute.of(context)!.settings.arguments == null)
                    ? const GlobalNavigationDrawer()
                    : null,
              );
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Match Predictor"),
                ),
                body: const PageBody(child: LinearProgressIndicator()),
                drawer: (ModalRoute.of(context)!.settings.arguments == null)
                    ? const GlobalNavigationDrawer()
                    : null,
              );
            }

            return LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxHeight > constraints.maxWidth) {
                // Portrait
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Match Predictor"),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(85),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: WinningPrediction(
                              redWinning: snapshot.data['redWinning'],
                              blueWinning: snapshot.data['blueWinning'],
                            ),
                          ),
                          TabBar(tabs: [
                            Column(
                              children: const [
                                Text("Red"),
                                SizedBox(height: 7),
                              ],
                            ),
                            Column(
                              children: const [
                                Text("Blue"),
                                SizedBox(height: 7),
                              ],
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(children: [
                    ScrollablePageBody(children: [
                      allianceTab(0, snapshot.data),
                    ]),
                    ScrollablePageBody(children: [
                      allianceTab(1, snapshot.data),
                    ]),
                  ]),
                  drawer: (ModalRoute.of(context)!.settings.arguments == null)
                      ? const GlobalNavigationDrawer()
                      : null,
                );
              } else {
                // Landscape
                return Scaffold(
                  appBar: AppBar(title: const Text("Match Predictor")),
                  body: SafeArea(
                    child: ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WinningPrediction(
                          redWinning: snapshot.data['redWinning'],
                          blueWinning: snapshot.data['blueWinning'],
                        ),
                      ),
                      Row(children: [
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: allianceTab(0, snapshot.data),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: allianceTab(1, snapshot.data),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  drawer: (ModalRoute.of(context)!.settings.arguments == null)
                      ? const GlobalNavigationDrawer()
                      : null,
                );
              }
            });
          }),
    );
  }

  Widget allianceTab(int alliance, Map<String, dynamic> data) {
    String allianceName = alliance == 0 ? 'red' : 'blue';

    return Column(children: [
      data["${allianceName}Alliance"]['teams'] == null
          ? const Text("Not enough data")
          : Row(
              children: (data["${allianceName}Alliance"]['teams']
                      .map((e) {
                        final role = RobotRole.values[e['role']];

                        return Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pushNamed(
                                "/team_lookup",
                                arguments: <String, dynamic>{
                                  'team': int.parse(e['team'].toString())
                                }),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: [redAlliance, blueAlliance][alliance],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Tooltip(
                                            message: role.name,
                                            child: Icon(role.littleEmblem),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            e['team'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ]),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Avg score",
                                      style: TextStyle(
                                        color: [
                                          onRedAlliance,
                                          onBlueAlliance
                                        ][alliance],
                                      ),
                                    ),
                                    Text(
                                      numberVizualizationBuilder(
                                          e['averagePoints']),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                      .toList()
                      .cast<Widget>() as List<Widget>)
                  .withSpaceBetween(width: 15),
            ),
      const SizedBox(height: 15),
      Container(
        decoration: BoxDecoration(
          color: [redAlliance, blueAlliance][alliance],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Teleop points"),
              Text(
                data["${allianceName}Alliance"]['totalPoints'] == null
                    ? "--"
                    : numberVizualizationBuilder(
                        data["${allianceName}Alliance"]['totalPoints'],
                      ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 15),
      if (data['${allianceName}Alliance']['levelCargo'] != null)
        cargoStack(
          context,
          data['${allianceName}Alliance'],
          backgroundColor: [onRedAlliance, onBlueAlliance][alliance],
          foregroundColor: [redAlliance, blueAlliance][alliance],
        ),
      const SizedBox(height: 15),
      Container(
        decoration: BoxDecoration(
          color: [onRedAlliance, onBlueAlliance][alliance],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Links",
                style: TextStyle(color: [redAlliance, blueAlliance][alliance]),
              ),
              Text(
                data["${allianceName}Alliance"]['links'] == null
                    ? "--"
                    : numberVizualizationBuilder(
                        data["${allianceName}Alliance"]['links'],
                      ),
                style: TextStyle(color: [redAlliance, blueAlliance][alliance]),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class WinningPrediction extends StatelessWidget {
  const WinningPrediction({
    super.key,
    this.redWinning,
    this.blueWinning,
  });

  final num? redWinning;
  final num? blueWinning;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 30,
        child: (redWinning == null || blueWinning == null)
            ? Center(
                child: Text(
                  "Not enough data",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: (redWinning! * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(color: redAlliance),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: (blueWinning! * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(color: blueAlliance),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Red alliance",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${(redWinning! * 100).round()}%",
                                // style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                              )
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Blue alliance",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${(blueWinning! * 100).round()}%",
                                // style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                              )
                            ]),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}