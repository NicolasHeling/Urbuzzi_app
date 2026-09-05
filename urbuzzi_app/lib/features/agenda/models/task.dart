class Task {
  final String id;
  final String title;
  final String date;
  final String time;
  final String status;
  final String clientId;
  final String? userId;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.clientId,
    this.userId,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      clientId: json['clientId'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'status': status,
      'clientId': clientId,
      'userId': userId,
    };
  }
}
