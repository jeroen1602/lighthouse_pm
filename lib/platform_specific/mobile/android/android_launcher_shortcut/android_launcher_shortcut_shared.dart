///
/// Types of shortcuts that exist
///
class ShortcutTypes {
  static const macType = ShortcutTypes._("mac");

  final String part;

  const ShortcutTypes._(this.part);
}

///
/// Data class with all the information for a shortcut type.
///
class ShortcutHandle {
  final ShortcutTypes type;
  final String data;

  const ShortcutHandle(this.type, this.data);

  @override
  bool operator ==(Object other) {
    if (other is ShortcutHandle) {
      return other.type == type && other.data == data;
    }
    return false;
  }

  @override
  int get hashCode => type.part.hashCode + data.hashCode;

  @override
  String toString() {
    return 'ShortcutHandle: {"type": "${type.part}", "data": "$data"}';
  }
}
