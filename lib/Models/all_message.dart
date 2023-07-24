import 'dart:convert';

Allmessages allmessagesFromJson(String str) =>
    Allmessages.fromJson(json.decode(str));

String allmessagesToJson(Allmessages data) => json.encode(data.toJson());

class Allmessages {
  Allmessages({
    this.messages,
    this.nextPageToken,
    this.resultSizeEstimate,
  });

  List<Message>? messages;
  String? nextPageToken;
  int? resultSizeEstimate;

  Allmessages copyWith({
    List<Message>? messages,
    String? nextPageToken,
    int? resultSizeEstimate,
  }) =>
      Allmessages(
        messages: messages ?? this.messages,
        nextPageToken: nextPageToken ?? this.nextPageToken,
        resultSizeEstimate: resultSizeEstimate ?? this.resultSizeEstimate,
      );

  factory Allmessages.fromJson(Map<String, dynamic> json) => Allmessages(
        messages: json["messages"] == null
            ? []
            : List<Message>.from(
                json["messages"]!.map((x) => Message.fromJson(x))),
        nextPageToken: json["nextPageToken"],
        resultSizeEstimate: json["resultSizeEstimate"],
      );

  Map<String, dynamic> toJson() => {
        "messages": messages == null
            ? []
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
        "nextPageToken": nextPageToken,
        "resultSizeEstimate": resultSizeEstimate,
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

String base64ToText(String base64Text) {
  return utf8.decode(base64.decode(base64Text));
}
