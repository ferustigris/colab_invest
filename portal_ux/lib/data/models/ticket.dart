class Ticket {
  final String id;
  final String title;
  final String status;
  final String priority;
  final DateTime createdAt;
  final String assignedTo;
  final String description;

  Ticket({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.assignedTo,
    required this.description,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      assignedTo: json['assignedTo'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'assignedTo': assignedTo,
      'description': description,
    };
  }
}
