// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 0;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      points: (fields[0] as Map).cast<String, Color>(),
      player1: fields[1] as Player,
      player2: fields[2] as Player,
      currentPlayerId: fields[3] as int,
      gridSize: fields[4] as int,
      isGameOver: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.points)
      ..writeByte(1)
      ..write(obj.player1)
      ..writeByte(2)
      ..write(obj.player2)
      ..writeByte(3)
      ..write(obj.currentPlayerId)
      ..writeByte(4)
      ..write(obj.gridSize)
      ..writeByte(5)
      ..write(obj.isGameOver);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
