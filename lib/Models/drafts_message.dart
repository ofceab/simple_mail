
import 'dart:convert';

DraftMessages draftMessagesFromJson(String str) =>
    DraftMessages.fromJson(json.decode(str));

String draftMessagesToJson(DraftMessages data) => json.encode(data.toJson());

class DraftMessages {
  DraftMessages({
    this.drafts,
    this.resultSizeEstimate,
  });

  List<Draft>? drafts;
  int? resultSizeEstimate;

  DraftMessages copyWith({
    List<Draft>? drafts,
    int? resultSizeEstimate,
  }) =>
      DraftMessages(
        drafts: drafts ?? this.drafts,
        resultSizeEstimate: resultSizeEstimate ?? this.resultSizeEstimate,
      );

  factory DraftMessages.fromJson(Map<String, dynamic> json) => DraftMessages(
        drafts: json["drafts"] == null
            ? []
            : List<Draft>.from(json["drafts"]!.map((x) => Draft.fromJson(x))),
        resultSizeEstimate: json["resultSizeEstimate"],
      );

  Map<String, dynamic> toJson() => {
        "drafts": drafts == null
            ? []
            : List<dynamic>.from(drafts!.map((x) => x.toJson())),
        "resultSizeEstimate": resultSizeEstimate,
      };
}

class Draft {
  Draft({
    this.id,
    this.message,
  });

  String? id;
  Message? message;

  Draft copyWith({
    String? id,
    Message? message,
  }) =>
      Draft(
        id: id ?? this.id,
        message: message ?? this.message,
      );

  factory Draft.fromJson(Map<String, dynamic> json) => Draft(
        id: json["id"],
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message?.toJson(),
      };
}

class Message {
  Message({
    this.id,
    this.threadId,
  });

  String? id;
  String? threadId;

  Message copyWith({
    String? id,
    String? threadId,
  }) =>
      Message(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
      );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        threadId: json["threadId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "threadId": threadId,
      };
}
