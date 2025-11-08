import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/models/ticket.dart';
import 'package:portal_ux/data/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketService {
  // Cache for storing tickets data
  static final Map<String, List<Ticket>> _ticketsCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static final Map<String, Ticket> _ticketDetailsCache = {};
  static final Map<String, DateTime> _detailsCacheTimestamps = {};

  // Cache duration: 12 hours
  static const Duration _cacheDuration = Duration(hours: 12);

  // LocalStorage keys
  static const String _ticketsCacheKey = 'tickets_cache';
  static const String _ticketsTimestampKey = 'tickets_timestamp';
  static const String _detailsCacheKey = 'details_cache';
  static const String _detailsTimestampKey = 'details_timestamp';

  /// Check if cache is valid for given key
  static bool _isCacheValid(String key, Map<String, DateTime> timestamps) {
    final timestamp = timestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Load cache from SharedPreferences
  static Future<void> _loadCacheFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load tickets cache
      final ticketsCacheData = prefs.getString(_ticketsCacheKey);
      final ticketsTimestampData = prefs.getString(_ticketsTimestampKey);

      if (ticketsCacheData != null && ticketsTimestampData != null) {
        final cacheMap = json.decode(ticketsCacheData) as Map<String, dynamic>;
        final timestampMap =
            json.decode(ticketsTimestampData) as Map<String, dynamic>;

        for (final entry in cacheMap.entries) {
          final ticketsList =
              (entry.value as List)
                  .map((json) => Ticket.fromJson(json))
                  .toList();
          _ticketsCache[entry.key] = ticketsList;
        }

        for (final entry in timestampMap.entries) {
          _cacheTimestamps[entry.key] = DateTime.parse(entry.value);
        }
      }

      // Load details cache
      final detailsCacheData = prefs.getString(_detailsCacheKey);
      final detailsTimestampData = prefs.getString(_detailsTimestampKey);

      if (detailsCacheData != null && detailsTimestampData != null) {
        final cacheMap = json.decode(detailsCacheData) as Map<String, dynamic>;
        final timestampMap =
            json.decode(detailsTimestampData) as Map<String, dynamic>;

        for (final entry in cacheMap.entries) {
          _ticketDetailsCache[entry.key] = Ticket.fromJson(entry.value);
        }

        for (final entry in timestampMap.entries) {
          _detailsCacheTimestamps[entry.key] = DateTime.parse(entry.value);
        }
      }

      debugPrint(
        'Cache loaded from SharedPreferences: ${_ticketsCache.length} ticket lists, ${_ticketDetailsCache.length} details',
      );
    } catch (e) {
      debugPrint('Error loading cache from SharedPreferences: $e');
      // Clear corrupted cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ticketsCacheKey);
      await prefs.remove(_ticketsTimestampKey);
      await prefs.remove(_detailsCacheKey);
      await prefs.remove(_detailsTimestampKey);
    }
  }

  /// Save cache to SharedPreferences
  static Future<void> _saveCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save tickets cache
      final ticketsCacheJson = <String, dynamic>{};
      for (final entry in _ticketsCache.entries) {
        ticketsCacheJson[entry.key] =
            entry.value.map((ticket) => ticket.toJson()).toList();
      }

      final ticketsTimestampJson = <String, String>{};
      for (final entry in _cacheTimestamps.entries) {
        ticketsTimestampJson[entry.key] = entry.value.toIso8601String();
      }

      await prefs.setString(_ticketsCacheKey, json.encode(ticketsCacheJson));
      await prefs.setString(
        _ticketsTimestampKey,
        json.encode(ticketsTimestampJson),
      );

      // Save details cache
      final detailsCacheJson = <String, dynamic>{};
      for (final entry in _ticketDetailsCache.entries) {
        detailsCacheJson[entry.key] = entry.value.toJson();
      }

      final detailsTimestampJson = <String, String>{};
      for (final entry in _detailsCacheTimestamps.entries) {
        detailsTimestampJson[entry.key] = entry.value.toIso8601String();
      }

      await prefs.setString(_detailsCacheKey, json.encode(detailsCacheJson));
      await prefs.setString(
        _detailsTimestampKey,
        json.encode(detailsTimestampJson),
      );

      debugPrint('Cache saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving cache to SharedPreferences: $e');
    }
  }

  /// Clear expired cache entries
  static void _clearExpiredCache() {
    final now = DateTime.now();

    // Clear expired tickets cache
    final expiredTicketsKeys =
        _cacheTimestamps.entries
            .where((entry) => now.difference(entry.value) >= _cacheDuration)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredTicketsKeys) {
      _ticketsCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // Clear expired details cache
    final expiredDetailsKeys =
        _detailsCacheTimestamps.entries
            .where((entry) => now.difference(entry.value) >= _cacheDuration)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredDetailsKeys) {
      _ticketDetailsCache.remove(key);
      _detailsCacheTimestamps.remove(key);
    }

    // Update SharedPreferences after cleanup
    if (expiredTicketsKeys.isNotEmpty || expiredDetailsKeys.isNotEmpty) {
      _saveCacheToStorage().catchError(
        (e) => debugPrint('Error saving cache after cleanup: $e'),
      );
    }
  }

  /// Clear all cache (useful for debugging or forced refresh)
  static Future<void> clearAllCache() async {
    _ticketsCache.clear();
    _cacheTimestamps.clear();
    _ticketDetailsCache.clear();
    _detailsCacheTimestamps.clear();

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ticketsCacheKey);
    await prefs.remove(_ticketsTimestampKey);
    await prefs.remove(_detailsCacheKey);
    await prefs.remove(_detailsTimestampKey);

    debugPrint('All cache cleared (including SharedPreferences)');
  }

  /// Get cache status information
  static Map<String, dynamic> getCacheStatus() {
    return {
      'ticketsCache': _ticketsCache.length,
      'detailsCache': _ticketDetailsCache.length,
      'cacheDuration': _cacheDuration.inMinutes,
    };
  }

  /// Stream-based method for progressive loading of tickets
  static Stream<List<Ticket>> getTicketsStream({
    String category = 'stocks',
  }) async* {
    // Load cache from SharedPreferences on first access
    if (_ticketsCache.isEmpty && _ticketDetailsCache.isEmpty) {
      await _loadCacheFromStorage();
    }

    _clearExpiredCache();

    // Check if we have valid cached data
    if (_isCacheValid(category, _cacheTimestamps)) {
      debugPrint(
        'Using cached tickets for category: $category (from SharedPreferences)',
      );
      yield _ticketsCache[category]!;
      return;
    }

    List<Ticket> currentTickets = [];

    try {
      // Get current user and their token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Step 1: Get list of tickers
      final tickersResponse = await http.get(
        Uri.parse('${AppConstants.cloudUrlTickets}/$category'),
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

      // Step 2: For each ticker get full information and emit update
      for (String ticker in tickers) {
        try {
          final ticket = await getTicketDetails(ticker);
          currentTickets.add(ticket);
          yield List.from(currentTickets); // Emit copy of current list
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Delay for visualization
        } catch (e) {
          // Skip tickers with errors, but continue loading others
          debugPrint('Failed to load $ticker: $e');
        }
      }

      // Cache the results
      _ticketsCache[category] = List.from(currentTickets);
      _cacheTimestamps[category] = DateTime.now();
      await _saveCacheToStorage();
      debugPrint(
        'Cached ${currentTickets.length} tickets for category: $category',
      );
    } catch (e) {
      debugPrint('Failed to get tickers list: $e');
      // Return empty stream if API is unavailable and no cache exists
      if (currentTickets.isEmpty) {
        throw Exception(
          'Unable to load tickets: API unavailable and no cached data',
        );
      }
    }
  }

  static Future<List<Ticket>> getTickets() async {
    try {
      // Get current user and their token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Step 1: Get list of tickers
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

      // Step 2: For each ticker get full information
      final List<Ticket> tickets = [];

      for (String ticker in tickers) {
        try {
          final ticket = await getTicketDetails(ticker);
          tickets.add(ticket);
        } catch (e) {
          // Skip tickers with errors, but continue loading others
          // In production can use proper logging library
        }
      }

      return tickets;
    } catch (e) {
      debugPrint('Failed to get tickets: $e');
      throw Exception('Unable to load tickets: $e');
    }
  }

  /// Gets detailed information about a specific ticket
  static Future<Ticket> getTicketDetails(String ticker) async {
    // Load cache from SharedPreferences on first access
    if (_ticketsCache.isEmpty && _ticketDetailsCache.isEmpty) {
      await _loadCacheFromStorage();
    }

    _clearExpiredCache();

    // Check if we have valid cached data
    if (_isCacheValid(ticker, _detailsCacheTimestamps)) {
      debugPrint(
        'Using cached ticket details for: $ticker (from SharedPreferences)',
      );
      return _ticketDetailsCache[ticker]!;
    }

    debugPrint('Calling getTicketDetails for ticker: $ticker');
    debugPrint('URL: ${AppConstants.cloudUrlTicketDetails}/$ticker');

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

      debugPrint('Response status for $ticker: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('Successfully parsed JSON for $ticker');
        final ticket = Ticket.fromJson(jsonData);

        // Cache the result
        _ticketDetailsCache[ticker] = ticket;
        _detailsCacheTimestamps[ticker] = DateTime.now();
        await _saveCacheToStorage();
        debugPrint('Cached ticket details for: $ticker');

        return ticket;
      } else {
        throw Exception(
          'Failed to load ticket details for $ticker: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getTicketDetails for $ticker: $e');
      throw Exception('Failed to get ticket details for $ticker: $e');
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
