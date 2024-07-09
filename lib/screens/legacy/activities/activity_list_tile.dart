import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripedia/screens/legacy/activities/activity.dart';

import '../common/themes/text_styles.dart';

class ActivityTile extends StatefulWidget {
  const ActivityTile({required this.activity, super.key});

  final LegacyActivity activity;

  @override
  State<ActivityTile> createState() => _ActivityTileState();
}

Widget buildLearnMoreButton(BuildContext context, LegacyActivity activity) {
  return TextButton(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: Colors.grey[300]!),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    onPressed: () {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                        activity.imageUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              8, 16, 8, 0),
                          child: Text(
                            activity.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              8, 8, 8, 16),
                          child: Text(
                            activity.description,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              label: Text(
                                'Close',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
                                ),
                              ),
                              style: ButtonStyle(
                                iconColor:
                                WidgetStatePropertyAll(
                                  Theme.of(context)
                                      .colorScheme
                                      .outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
    },
    child: const Text(
      'Learn more',
      style: TextStyle(
        fontSize: 12,
      ),
    ),
  );
}

class _ActivityTileState extends State<ActivityTile> {
  bool checked = false;


  @override
  Widget build(BuildContext context) {
    var duration = widget.activity.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(widget.activity.imageUrl),
              ), // b
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.activity.name),
                  Row(children: [
                    buildLearnMoreButton(context, widget.activity),
                    const SizedBox.square(
                      dimension: 24,
                    ),
                    Text(
                      '$duration ${duration <= 1 ? 'hour' : 'hours'}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: Colors.grey[600]!, width: 1),
            value: checked,
            onChanged: (val) {
              context.read<TravelPlan>().toggleActivity(widget.activity);
              setState(() {
                checked = !checked;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  const ActivityCard({required this.activity, super.key});

  final LegacyActivity activity;

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool checked = false;

  Widget _buildCheck(BuildContext context) {
    checked = context.read<TravelPlan>().activities.contains(widget.activity);
    var colorScheme = Theme.of(context).colorScheme;
    if (checked) {
      return Container(width: 36, height: 36, decoration:
      BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(24)),
          child:
           Icon(Icons.check, color: colorScheme.onSurface,)
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    var duration = widget.activity.duration;
    //var width = MediaQuery.sizeOf(context).width;
    var colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
        onTap: (){
          context.read<TravelPlan>().toggleActivity(widget.activity);
        setState(() {
          checked = !checked;
        });
        },
        child:
      ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      // TODO: Improve image loading and caching
      child:
      SizedBox(width: 400, height: 400, child:
      Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.activity.imageUrl,
              fit: BoxFit.fitHeight,
            ),
            Positioned(
          right: 24,
          top:24,
          child: _buildCheck(context)),
        Positioned(
            bottom: 32.0,
            left: 16.0,
            right: 24.0,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.name,
                    style: TextStyles.cardTitleStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(
                    '$duration ${duration <= 1 ? 'hour' : 'hours'}',
                    style: TextStyles.cardTitleStyle.copyWith(fontSize: 18),
                  ),
                  Container(color: Colors.transparent, child:
                  const OutlinedButton(onPressed: null, child: Text("Learn More"))),
                  ],)
            ])),
            ]))));
  }
}

class ActivityDetailTile extends StatelessWidget {
  const ActivityDetailTile({required this.activity, super.key});

  final LegacyActivity activity;

  @override
  Widget build(BuildContext context) {
    var duration = activity.duration;

    return ExpansionTile(
      tilePadding: const EdgeInsets.all(0),
      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      maintainState: true,
      minTileHeight: 100,
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(activity.imageUrl),
          ), // b
        ),
      ),
      title: Text(activity.name),
      subtitle: Text(
        '$duration ${duration <= 1 ? 'hour' : 'hours'}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      children: [
        Text(
          activity.description,
        ),
      ],
    );
  }
}
