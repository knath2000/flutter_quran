import 'package:flutter/material.dart'; // For IconData, Color

// Represents an unlockable badge/achievement
class Badge {
  final String
  id; // Unique identifier (e.g., 'completed_surah_1', 'first_week_streak')
  final String name;
  final String description;
  final IconData icon; // Icon to display for the badge
  final Color iconColor; // Color for the icon

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.iconColor = Colors.amber, // Default color
  });

  // Define a list of all available badges
  // This could later be moved to a separate configuration file or service
  static final List<Badge> allBadges = [
    const Badge(
      id: 'first_verse',
      name: 'First Step',
      description: 'Listened to your first verse!',
      icon: Icons.looks_one,
      iconColor: Colors.lightBlueAccent,
    ),
    const Badge(
      id: 'surah_fatiha_complete',
      name: 'The Opener',
      description: 'Completed Surah Al-Fatiha!',
      icon: Icons.book_online, // Example icon
      iconColor: Colors.greenAccent,
    ),
    const Badge(
      id: 'ten_verses',
      name: 'Verse Explorer',
      description: 'Listened to 10 verses!',
      icon: Icons.explore,
      iconColor: Colors.orangeAccent,
    ),
    // Add more badges here based on gamification design
  ];

  // Helper to get a badge by its ID
  static Badge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
  }
}
