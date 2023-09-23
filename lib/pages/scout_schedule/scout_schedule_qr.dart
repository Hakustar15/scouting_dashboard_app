import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:frc_8033_scouting_shared/frc_8033_scouting_shared.dart';
import 'package:scouting_dashboard_app/datatypes.dart';
import 'package:scouting_dashboard_app/reusable/scrollable_page_body.dart';

class DisplayScoutScheduleQRPage extends StatefulWidget {
  const DisplayScoutScheduleQRPage({super.key});

  @override
  State<DisplayScoutScheduleQRPage> createState() =>
      _DisplayScoutScheduleQRPageState();
}

class _DisplayScoutScheduleQRPageState
    extends State<DisplayScoutScheduleQRPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Schedule Update"),
      ),
      body: FutureBuilder(
        future: getScoutSchedule(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ScrollablePageBody(
              children: [Center(child: CircularProgressIndicator())],
            );
          }

          final ScoutSchedule schedule = snapshot.data!;

          return ScrollablePageBody(children: [
            Text(
              "Without an internet connection, scouts should scan this QR code to ensure they have the latest version of the scout schedule.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth > 500
                          ? 500
                          : constraints.maxWidth,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: CustomPaint(
                            painter: QrPainter(
                              data: schedule.toCompressedJSON(),
                              options: const QrOptions(padding: 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: HSLColor.fromColor(schedule.getVersionColor())
                    .withSaturation(0.3)
                    .withLightness(0.5)
                    .toColor(),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text:
                          "If scouts have the latest version of the schedule, their home page will be this color. If not, they should scan this QR code by tapping the ",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                HSLColor.fromColor(schedule.getVersionColor())
                                    .withSaturation(0.5)
                                    .withLightness(0.12)
                                    .toColor(),
                          ),
                    ),
                    WidgetSpan(
                      child: Icon(
                        Icons.settings,
                        color: HSLColor.fromColor(schedule.getVersionColor())
                            .withSaturation(0.5)
                            .withLightness(0.12)
                            .toColor(),
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      text:
                          " in the top right of their home screen, then tapping the \"Scan Scouter Schedule QR Code\" button.",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                HSLColor.fromColor(schedule.getVersionColor())
                                    .withSaturation(0.5)
                                    .withLightness(0.12)
                                    .toColor(),
                          ),
                    ),
                  ]))),
            ),
            const SizedBox(height: 20),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "Access this code at any time by tapping the ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const WidgetSpan(
                child: Icon(Icons.qr_code),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                text: " at the top right of the match schedule.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]))
          ]);
        },
      ),
    );
  }
}
