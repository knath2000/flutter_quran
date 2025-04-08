// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      points: fields[0] as int,
      earnedBadgeIds:
          (fields[1] as List).cast<String>().toSet(), // Convert List to Set
      completedVerseKeys:
          (fields[4] as List).cast<String>().toSet(), // Convert List to Set
      currentStreak: fields[2] as int,
      lastSessionDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.completedVerseKeys.toList())
      ..writeByte(1)
      ..write(obj.earnedBadgeIds.toList())
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.lastSessionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
