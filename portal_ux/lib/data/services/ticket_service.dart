import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:portal_ux/data/models/ticket.dart';

class TicketService {
  // Замените на ваш реальный API endpoint
  static const String baseUrl = 'https://your-api-endpoint.com/api';

  static Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Content-Type': 'application/json',
          // Добавьте авторизацию если нужно
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      // Возвращаем mock данные для демонстрации
      return _getMockTickets();
    }
  }

  static List<Ticket> _getMockTickets() {
    return [
      Ticket(
        id: 'TKT-001',
        title: 'Fix login issue',
        status: 'Open',
        priority: 'High',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        assignedTo: 'John Doe',
        description: 'Users cannot login with their credentials',
      ),
      Ticket(
        id: 'TKT-002',
        title: 'Update documentation',
        status: 'In Progress',
        priority: 'Medium',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        assignedTo: 'Jane Smith',
        description: 'Need to update API documentation',
      ),
      Ticket(
        id: 'TKT-003',
        title: 'Database optimization',
        status: 'Closed',
        priority: 'Low',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        assignedTo: 'Bob Johnson',
        description: 'Optimize database queries for better performance',
      ),
      Ticket(
        id: 'TKT-004',
        title: 'Security vulnerability fix',
        status: 'Open',
        priority: 'Critical',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        assignedTo: 'Alice Brown',
        description: 'Fix security vulnerability in authentication',
      ),
    ];
  }

  static Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        return Ticket.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create ticket: $e');
    }
  }

  static Future<Ticket> updateTicket(Ticket ticket) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/${ticket.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  static Future<void> deleteTicket(String ticketId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }
}
