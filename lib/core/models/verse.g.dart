// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VerseAdapter extends TypeAdapter<Verse> {
  @override
  final int typeId = 1;

  @override
  Verse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Verse(
      numberInSurah: fields[0] as int,
      text: fields[1] as String,
      audioUrl: fields[2] as String?,
      translationText: fields[3] as String?,
      transliterationText: fields[4] as String?,
      juz: fields[5] as int,
      manzil: fields[6] as int,
      page: fields[7] as int,
      ruku: fields[8] as int,
      hizbQuarter: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Verse obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.numberInSurah)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.audioUrl)
      ..writeByte(3)
      ..write(obj.translationText)
      ..writeByte(4)
      ..write(obj.transliterationText)
      ..writeByte(5)
      ..write(obj.juz)
      ..writeByte(6)
      ..write(obj.manzil)
      ..writeByte(7)
      ..write(obj.page)
      ..writeByte(8)
      ..write(obj.ruku)
      ..writeByte(9)
      ..write(obj.hizbQuarter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
