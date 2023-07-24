import 'dart:convert';

GmailMessage gmailMessageFromJson(String str) =>
    GmailMessage.fromJson(json.decode(str));

String gmailMessageToJson(GmailMessage data) => json.encode(data.toJson());

class GmailMessage {
  GmailMessage({
    this.id,
    this.threadId,
    this.labelIds,
    this.snippet,
    this.payload,
    this.sizeEstimate,
    this.historyId,
    this.internalDate,
    String? contentType,
  });

  String? id;
  String? threadId;
  List<String>? labelIds;
  String? snippet;
  Payload? payload;
  int? sizeEstimate;
  String? historyId;
  String? internalDate;
  String? contentType;

  GmailMessage copyWith({
    String? id,
    String? threadId,
    List<String>? labelIds,
    String? snippet,
    Payload? payload,
    int? sizeEstimate,
    String? historyId,
    String? internalDate,
  }) =>
      GmailMessage(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
        labelIds: labelIds ?? this.labelIds,
        snippet: snippet ?? this.snippet,
        payload: payload ?? this.payload,
        sizeEstimate: sizeEstimate ?? this.sizeEstimate,
        historyId: historyId ?? this.historyId,
        internalDate: internalDate ?? this.internalDate,
      );

  factory GmailMessage.fromJson(Map<String, dynamic> json) => GmailMessage(
        id: json["id"],
        threadId: json["threadId"],
        labelIds: json["labelIds"] == null
            ? []
            : List<String>.from(json["labelIds"]!.map((x) => x)),
        snippet: json["snippet"],
        payload:
            json["payload"] == null ? null : Payload.fromJson(json["payload"]),
        sizeEstimate: json["sizeEstimate"],
        historyId: json["historyId"],
        internalDate: json["internalDate"],
        contentType: getContentType(
            json["payload"] == null ? null : Payload.fromJson(json["payload"])),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "threadId": threadId,
        "labelIds":
            labelIds == null ? [] : List<dynamic>.from(labelIds!.map((x) => x)),
        "snippet": snippet,
        "payload": payload?.toJson(),
        "sizeEstimate": sizeEstimate,
        "historyId": historyId,
        "internalDate": internalDate,
      };
}

String? getContentType(Payload? payload) {
  final parts = payload?.parts;

  if (parts != null) {
    for (final part in parts) {
      if (part.mimeType == 'text/plain') {
        return 'plain';
      } else if (part.mimeType == 'text/html') {
        return 'html';
      }
    }
  }
  return 'plain';
}

class Payload {
  Payload({
    this.partId,
    this.mimeType,
    this.filename,
    this.headers,
    this.body,
    this.parts,
  });

  String? partId;
  String? mimeType;
  String? filename;
  List<Header>? headers;
  PayloadBody? body;
  List<Part>? parts;

  Payload copyWith({
    String? partId,
    String? mimeType,
    String? filename,
    List<Header>? headers,
    PayloadBody? body,
    List<Part>? parts,
  }) =>
      Payload(
        partId: partId ?? this.partId,
        mimeType: mimeType ?? this.mimeType,
        filename: filename ?? this.filename,
        headers: headers ?? this.headers,
        body: body ?? this.body,
        parts: parts ?? this.parts,
      );

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        partId: json["partId"],
        mimeType: json["mimeType"],
        filename: json["filename"],
        headers: json["headers"] == null
            ? []
            : List<Header>.from(
                json["headers"]!.map((x) => Header.fromJson(x))),
        body: json["body"] == null ? null : PayloadBody.fromJson(json["body"]),
        parts: json["parts"] == null
            ? []
            : List<Part>.from(json["parts"]!.map((x) => Part.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "partId": partId,
        "mimeType": mimeType,
        "filename": filename,
        "headers": headers == null
            ? []
            : List<dynamic>.from(headers!.map((x) => x.toJson())),
        "body": body?.toJson(),
        "parts": parts == null
            ? []
            : List<dynamic>.from(parts!.map((x) => x.toJson())),
      };
}

class PayloadBody {
  PayloadBody({this.size, this.data});

  int? size;
  String? data;
  PayloadBody copyWith({
    int? size,
  }) =>
      PayloadBody(
        size: size ?? this.size,
      );

  factory PayloadBody.fromJson(Map<String, dynamic> json) =>
      PayloadBody(size: json["size"], data: json["data"]);

  Map<String, dynamic> toJson() => {"size": size, "data": data};
}

class Header {
  Header({
    this.name,
    this.value,
  });

  String? name;
  String? value;

  Header copyWith({
    String? name,
    String? value,
  }) =>
      Header(
        name: name ?? this.name,
        value: value ?? this.value,
      );

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
      };
}

class Part {
  var parts;

  Part({
    this.partId,
    this.mimeType,
    this.filename,
    this.headers,
    this.body,
  });

  String? partId;
  String? mimeType;
  String? filename;
  List<Header>? headers;
  PartBody? body;

  Part copyWith({
    String? partId,
    String? mimeType,
    String? filename,
    List<Header>? headers,
    PartBody? body,
  }) =>
      Part(
        partId: partId ?? this.partId,
        mimeType: mimeType ?? this.mimeType,
        filename: filename ?? this.filename,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );

  factory Part.fromJson(Map<String, dynamic> json) => Part(
        partId: json["partId"],
        mimeType: json["mimeType"],
        filename: json["filename"],
        headers: json["headers"] == null
            ? []
            : List<Header>.from(
                json["headers"]!.map((x) => Header.fromJson(x))),
        body: json["body"] == null ? null : PartBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "partId": partId,
        "mimeType": mimeType,
        "filename": filename,
        "headers": headers == null
            ? []
            : List<dynamic>.from(headers!.map((x) => x.toJson())),
        "body": body?.toJson(),
      };
}

class PartBody {
  PartBody({
    this.size,
    this.data,
  });

  int? size;
  String? data;

  get attachmentId => null;

  PartBody copyWith({
    int? size,
    String? data,
  }) =>
      PartBody(
        size: size ?? this.size,
        data: data ?? this.data,
      );

  factory PartBody.fromJson(Map<String, dynamic> json) => PartBody(
        size: json["size"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "size": size,
        "data": data,
      };
}

class EmailPart {
  final String mimeType;
  final String? content;
  final String? filename;
  final String? contentId;

  EmailPart({
    required this.mimeType,
    this.content,
    this.filename,
    this.contentId,
  });
}
// class UserAccount {
//   final String email;
//   final String token;

//   UserAccount({required this.email, required this.token});
// }
class Account {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  Account({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
    );
  }
}
