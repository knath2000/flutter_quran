import 'package:flutter/material.dart' hide Badge; // Hide Material's Badge
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/models/badge.dart'
    as models; // Use our Badge model
import 'package:quran_flutter/features/gamification/application/user_progress_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the set of earned badge IDs from the user progress
    final earnedBadgeIds = ref.watch(
      userProgressProvider.select((progress) => progress.earnedBadgeIds),
    );
    // Get the full badge details for the earned IDs
    final earnedBadges =
        earnedBadgeIds
            .map(
              (id) => models.Badge.getBadgeById(id),
            ) // Use the qualified name
            .where(
              (badge) => badge != null,
            ) // Filter out any nulls if an ID is invalid
            .cast<models.Badge>() // Use the qualified name
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body:
          earnedBadges.isEmpty
              ? const Center(
                child: Text(
                  'Keep learning to earn badges!',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust columns as needed
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: earnedBadges.length,
                itemBuilder: (context, index) {
                  final models.Badge badge =
                      earnedBadges[index]; // Use the qualified name
                  // Simple badge display - can be enhanced later
                  return Tooltip(
                    message: '${badge.name}\n${badge.description}',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: badge.iconColor.withOpacity(0.2),
                          child: Icon(
                            badge.icon,
                            size: 30,
                            color: badge.iconColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
