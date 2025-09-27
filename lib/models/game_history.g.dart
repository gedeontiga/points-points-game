part of 'game_history.dart';

class GameHistoryEntryAdapter extends TypeAdapter<GameHistoryEntry> {
  @override
  final int typeId = 2;

  @override
  GameHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameHistoryEntry(
      winnerId: fields[0] as int,
      player1Color: fields[1] as Color,
      player2Color: fields[2] as Color,
      player1Score: fields[3] as int,
      player2Score: fields[4] as int,
      gridSize: fields[5] as int,
      finishedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameHistoryEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.winnerId)
      ..writeByte(1)
      ..write(obj.player1Color)
      ..writeByte(2)
      ..write(obj.player2Color)
      ..writeByte(3)
      ..write(obj.player1Score)
      ..writeByte(4)
      ..write(obj.player2Score)
      ..writeByte(5)
      ..write(obj.gridSize)
      ..writeByte(6)
      ..write(obj.finishedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
