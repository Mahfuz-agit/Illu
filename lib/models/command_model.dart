import 'dart:convert';

enum CommandType { lockDevice, blockApp, unblockApp, requestLocation, sendLocation, getScreenTime }

class CommandModel {
  final CommandType type;
  final Map<String, dynamic>? payload;

  CommandModel({required this.type, this.payload});

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'payload': payload,
    };
  }

  factory CommandModel.fromMap(Map<String, dynamic> map) {
    return CommandModel(
      type: CommandType.values.firstWhere((e) => e.name == map['type']),
      payload: map['payload'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CommandModel.fromJson(String source) => CommandModel.fromMap(json.decode(source));
}
