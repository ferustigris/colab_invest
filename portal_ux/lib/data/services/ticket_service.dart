import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/models/ticket.dart';
import 'package:portal_ux/data/app_constants.dart';

class TicketService {
  /// Stream-based метод для progressive loading тикетов
  static Stream<List<Ticket>> getTicketsStream() async* {
    List<Ticket> currentTickets = [];

    try {
      // Получаем текущего пользователя и его токен
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Шаг 1: Получаем список тикеров
      final tickersResponse = await http.get(
        Uri.parse(AppConstants.cloudUrlTickets),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (tickersResponse.statusCode != 200) {
        throw Exception(
          'Failed to load tickers list: ${tickersResponse.statusCode}',
        );
      }

      final List<dynamic> tickersData = json.decode(tickersResponse.body);
      final List<String> tickers = tickersData.cast<String>();

      // Шаг 2: Для каждого тикера получаем полную информацию и эмитим обновление
      for (String ticker in tickers) {
        try {
          final ticket = await getTicketDetails(ticker);
          currentTickets.add(ticket);
          yield List.from(currentTickets); // Эмитим копию текущего списка
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Задержка для визуализации
        } catch (e) {
          // Пропускаем тикеры с ошибками, но продолжаем загрузку остальных
          print('Failed to load $ticker: $e');
        }
      }
    } catch (e) {
      // Если не удалось получить список тикеров, используем mock данные
      print('Failed to get tickers list, using mock data: $e');

      final List<String> mockTickers = _getMockTickers();

      for (String ticker in mockTickers) {
        try {
          final ticket = await getTicketDetails(ticker);
          currentTickets.add(ticket);
          yield List.from(currentTickets);
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Задержка для визуализации
        } catch (detailError) {
          // Используем mock данные если API недоступен
          print('Using mock data for $ticker due to error: $detailError');
          final mockTicket = _getMockTicketDetails(ticker);
          print(
            'Mock ticket created: ${mockTicket.ticker} - ${mockTicket.name}',
          );
          currentTickets.add(mockTicket);
          yield List.from(currentTickets);
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Задержка для визуализации
        }
      }
    }
  }

  static Future<List<Ticket>> getTickets() async {
    try {
      // Получаем текущего пользователя и его токен
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Шаг 1: Получаем список тикеров
      final tickersResponse = await http.get(
        Uri.parse(AppConstants.cloudUrlTickets),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (tickersResponse.statusCode != 200) {
        throw Exception(
          'Failed to load tickers list: ${tickersResponse.statusCode}',
        );
      }

      final List<dynamic> tickersData = json.decode(tickersResponse.body);
      final List<String> tickers = tickersData.cast<String>();

      // Шаг 2: Для каждого тикера получаем полную информацию
      final List<Ticket> tickets = [];

      for (String ticker in tickers) {
        try {
          final ticket = await getTicketDetails(ticker);
          tickets.add(ticket);
        } catch (e) {
          // Пропускаем тикеры с ошибками, но продолжаем загрузку остальных
          // В production можно использовать proper logging библиотеку
        }
      }

      return tickets;
    } catch (e) {
      // Если не удалось получить список тикеров, используем mock список для тестирования ticket_details
      print(
        'Failed to get tickers list, using mock tickers to test ticket_details: $e',
      );

      // Пробуем получить детальную информацию для mock тикеров
      final List<String> mockTickers = _getMockTickers();
      final List<Ticket> tickets = [];

      for (String ticker in mockTickers) {
        try {
          print('Attempting to fetch details for $ticker');
          final ticket = await getTicketDetails(ticker);
          tickets.add(ticket);
          print('Successfully loaded details for $ticker');
        } catch (detailError) {
          print('Failed to load details for $ticker: $detailError');
          // Если и детальная информация не загружается, используем mock
          final mockTicket = _getMockTicketDetails(ticker);
          tickets.add(mockTicket);
        }
      }

      return tickets;
    }
  }

  /// Получает детальную информацию о конкретном тикете
  static Future<Ticket> getTicketDetails(String ticker) async {
    print('Calling getTicketDetails for ticker: $ticker');
    print('URL: ${AppConstants.cloudUrlTicketDetails}/$ticker');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('${AppConstants.cloudUrlTicketDetails}/$ticker'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      print('Response status for $ticker: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Successfully parsed JSON for $ticker');
        return Ticket.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load ticket details for $ticker: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getTicketDetails for $ticker: $e');

      // Проверяем, не CORS ли это ошибка
      if (e.toString().contains('CORS') ||
          e.toString().contains('Access-Control-Allow-Origin')) {
        print(
          'CORS error detected for $ticker, using mock data until server CORS is configured',
        );
      }

      throw Exception('Failed to get ticket details for $ticker: $e');
    }
  }

  static List<Ticket> _getMockTickets() {
    // Симулируем получение списка тикеров и затем детальной информации для каждого
    final List<String> mockTickers = _getMockTickers();
    return mockTickers.map((ticker) => _getMockTicketDetails(ticker)).toList();
  }

  /// Возвращает mock список тикеров
  static List<String> _getMockTickers() {
    return ['AAPL', 'MSFT', 'GOOGL', 'NVDA'];
  }

  /// Возвращает mock детальную информацию для конкретного тикера
  static Ticket _getMockTicketDetails(String ticker) {
    switch (ticker) {
      case 'AAPL':
        return Ticket(
          ticker: 'AAPL',
          name: 'Apple Inc.',
          summary:
              'Leading technology company known for innovative consumer electronics',
          profitGrowth10Years: 15.2,
          currentPrice: 189.50,
          sharesOutstanding: 15.55,
          sma10Years: 165.30,
          priceForecastDiv: 195.00,
          priceForecastPE: 210.00,
          priceForecastEquity: 185.00,
          marketCap: 2950.5,
          revenue: 394.3,
          netIncome: 99.8,
          ebitda: 123.7,
          nta: 65.2,
          pe: 29.5,
          ps: 7.5,
          evEbitda: 24.8,
          totalDebt: 109.6,
          debtEbitda: 0.89,
          cash: 29.0,
          dividendYield: 0.5,
          peRatio: 29.5,
          fpe: 27.2,
          freeCashFlow: 84.7,
          buyback: 75.2,
          buybackPercent: 2.5,
          freeCashFlowPerStock: 5.45,
        );
      case 'MSFT':
        return Ticket(
          ticker: 'MSFT',
          name: 'Microsoft Corporation',
          summary:
              'Global technology leader in cloud computing, productivity software, and business solutions',
          profitGrowth10Years: 18.7,
          currentPrice: 415.20,
          sharesOutstanding: 7.43,
          sma10Years: 320.80,
          priceForecastDiv: 430.00,
          priceForecastPE: 450.00,
          priceForecastEquity: 420.00,
          marketCap: 3085.2,
          revenue: 211.9,
          netIncome: 72.4,
          ebitda: 89.7,
          nta: 156.9,
          pe: 42.6,
          ps: 14.6,
          evEbitda: 34.4,
          totalDebt: 47.0,
          debtEbitda: 0.52,
          cash: 29.5,
          dividendYield: 0.7,
          peRatio: 42.6,
          fpe: 35.8,
          freeCashFlow: 65.2,
          buyback: 22.8,
          buybackPercent: 0.7,
          freeCashFlowPerStock: 8.78,
        );
      case 'GOOGL':
        return Ticket(
          ticker: 'GOOGL',
          name: 'Alphabet Inc.',
          summary:
              'Parent company of Google, leading in search, advertising, and emerging technologies',
          profitGrowth10Years: 22.3,
          currentPrice: 142.30,
          sharesOutstanding: 12.61,
          sma10Years: 125.90,
          priceForecastDiv: 0.0, // No dividend
          priceForecastPE: 165.00,
          priceForecastEquity: 155.00,
          marketCap: 1795.4,
          revenue: 307.4,
          netIncome: 73.8,
          ebitda: 92.1,
          nta: 283.2,
          pe: 24.3,
          ps: 5.8,
          evEbitda: 19.5,
          totalDebt: 13.2,
          debtEbitda: 0.14,
          cash: 110.9,
          dividendYield: 0.0,
          peRatio: 24.3,
          fpe: 22.1,
          freeCashFlow: 69.5,
          buyback: 59.3,
          buybackPercent: 3.3,
          freeCashFlowPerStock: 5.38,
        );
      case 'NVDA':
        return Ticket(
          ticker: 'NVDA',
          name: 'NVIDIA Corporation',
          summary:
              'Leading graphics and AI computing company powering gaming, data centers, and autonomous vehicles',
          profitGrowth10Years: 45.8,
          currentPrice: 135.40,
          sharesOutstanding: 24.69,
          sma10Years: 65.20,
          priceForecastDiv: 140.00,
          priceForecastPE: 180.00,
          priceForecastEquity: 160.00,
          marketCap: 3345.7,
          revenue: 60.9,
          netIncome: 29.8,
          ebitda: 32.9,
          nta: 42.2,
          pe: 112.2,
          ps: 54.9,
          evEbitda: 101.7,
          totalDebt: 9.7,
          debtEbitda: 0.29,
          cash: 26.0,
          dividendYield: 0.03,
          peRatio: 112.2,
          fpe: 35.4,
          freeCashFlow: 23.0,
          buyback: 9.5,
          buybackPercent: 0.3,
          freeCashFlowPerStock: 0.93,
        );
      default:
        throw Exception('Unknown ticker: $ticker');
    }
  }

  static Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(AppConstants.cloudUrlTickets),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse('${AppConstants.cloudUrlTickets}/${ticket.ticker}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('${AppConstants.cloudUrlTickets}/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }
}
