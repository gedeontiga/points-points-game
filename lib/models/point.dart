class Point {
  final int row;
  final int col;

  Point(this.row, this.col);

  String get key => '$row,$col';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
