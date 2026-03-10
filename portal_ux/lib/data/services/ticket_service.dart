import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const Duration _firebaseTickerFreshDuration = Duration(hours: 4);
  static final Set<String> _refreshingTickerKeys = <String>{};

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userId = user.uid;
    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ticket_lists')
        .doc(category)
        .collection('tickets')
        .orderBy('ticker');

    await for (final snapshot in query.snapshots()) {
      final loadedTickets =
          snapshot.docs
              .map((doc) => Ticket.fromJson(doc.data()))
              .where((ticket) => ticket.ticker.trim().isNotEmpty)
              .toList();

      _ticketsCache[category] = List.from(loadedTickets);
      _cacheTimestamps[category] = DateTime.now();

      _refreshStaleTicketsInBackground(
        userId: userId,
        category: category,
        docs: snapshot.docs,
      );

      yield loadedTickets;
    }
  }

  static Future<List<Ticket>> getTickets({String category = 'stocks'}) async {
    try {
      return await getTicketsStream(category: category).first;
    } catch (e) {
      debugPrint('Failed to get tickets: $e');
      throw Exception('Unable to load tickets from Firebase: $e');
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Try Firestore-first lookup across user lists.
      final userId = user.uid;
      final listSnapshots =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('ticket_lists')
              .get();

      for (final listDoc in listSnapshots.docs) {
        final ticketDoc =
            await listDoc.reference
                .collection('tickets')
                .doc(ticker.toUpperCase())
                .get();
        if (ticketDoc.exists) {
          final data = ticketDoc.data();
          if (data != null) {
            final ticket = Ticket.fromJson(data);
            _ticketDetailsCache[ticker] = ticket;
            _detailsCacheTimestamps[ticker] = DateTime.now();
            _saveCacheToStorage();
            return ticket;
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore lookup for $ticker failed: $e');
    }

    try {
      final ticket = await _fetchTicketDetailsFromApi(ticker);
      _ticketDetailsCache[ticker] = ticket;
      _detailsCacheTimestamps[ticker] = DateTime.now();
      await _saveCacheToStorage();
      return ticket;
    } catch (e) {
      debugPrint('Error in getTicketDetails for $ticker: $e');
      throw Exception('Failed to get ticket details for $ticker: $e');
    }
  }

  static Future<Ticket> _fetchTicketDetailsFromApi(
    String ticker, {
    String? idToken,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = idToken ?? await user.getIdToken();

    final response = await http.get(
      Uri.parse('${AppConstants.cloudUrlTicketDetails}/$ticker'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load ticket details for $ticker: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> jsonData = json.decode(response.body);
    return Ticket.fromJson(jsonData);
  }

  static bool _isFirebaseTicketStale(Map<String, dynamic> data) {
    final updatedAtRaw = data['updatedAt'];
    if (updatedAtRaw is! Timestamp) return true;

    final updatedAt = updatedAtRaw.toDate();
    return DateTime.now().difference(updatedAt) > _firebaseTickerFreshDuration;
  }

  static void _refreshStaleTicketsInBackground({
    required String userId,
    required String category,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) {
    for (final doc in docs) {
      final data = doc.data();
      final ticker = (data['ticker'] as String?)?.trim();
      if (ticker == null || ticker.isEmpty) {
        continue;
      }

      if (!_isFirebaseTicketStale(data)) {
        continue;
      }

      final refreshKey = '$category:${ticker.toUpperCase()}';
      if (_refreshingTickerKeys.contains(refreshKey)) {
        continue;
      }

      _refreshingTickerKeys.add(refreshKey);
      _refreshSingleTicker(
        userId: userId,
        category: category,
        ticker: ticker,
      ).whenComplete(() => _refreshingTickerKeys.remove(refreshKey));
    }
  }

  static Future<void> _refreshSingleTicker({
    required String userId,
    required String category,
    required String ticker,
  }) async {
    try {
      final ticket = await _fetchTicketDetailsFromApi(ticker);
      final payload = ticket.toJson();
      payload['ticker'] = ticket.ticker;
      payload['category'] = category;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ticket_lists')
          .doc(category)
          .collection('tickets')
          .doc(ticket.ticker.toUpperCase())
          .set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Background refresh failed for $ticker in $category: $e');
    }
  }

  static Future<void> refreshTickerFromApi({
    required String category,
    required String ticker,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final normalizedTicker = ticker.trim().toUpperCase();
    if (normalizedTicker.isEmpty) {
      throw Exception('Ticker is empty');
    }

    final refreshKey = '$category:$normalizedTicker';
    if (_refreshingTickerKeys.contains(refreshKey)) {
      return;
    }

    _refreshingTickerKeys.add(refreshKey);
    try {
      await _refreshSingleTicker(
        userId: user.uid,
        category: category,
        ticker: normalizedTicker,
      );
    } finally {
      _refreshingTickerKeys.remove(refreshKey);
    }
  }

  static Future<int> importListFromApiToFirebase({
    required String sourceCategory,
    String? targetCategory,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userId = user.uid;
    final target = (targetCategory ?? sourceCategory).trim();
    if (target.isEmpty) {
      throw Exception('Target category is empty');
    }

    final idToken = await user.getIdToken();
    final tickersResponse = await http.get(
      Uri.parse('${AppConstants.cloudUrlTickets}/$sourceCategory'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (tickersResponse.statusCode != 200) {
      throw Exception(
        'Failed to load source tickers for $sourceCategory: ${tickersResponse.statusCode}',
      );
    }

    final List<dynamic> tickersData = json.decode(tickersResponse.body);
    final tickers = tickersData.cast<String>();

    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(userId)
        .collection('ticket_categories')
        .doc(target)
        .set({
          'value': target,
          'label': target.toUpperCase(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': userId,
        }, SetOptions(merge: true));

    await firestore
        .collection('users')
        .doc(userId)
        .collection('ticket_lists')
        .doc(target)
        .set({
          'category': target,
          'sourceCategory': sourceCategory,
          'importedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': userId,
          'itemsCount': tickers.length,
        }, SetOptions(merge: true));

    var imported = 0;
    const chunkSize = 250;
    for (var i = 0; i < tickers.length; i += chunkSize) {
      final end =
          (i + chunkSize > tickers.length) ? tickers.length : i + chunkSize;
      final chunk = tickers.sublist(i, end);

      final batch = firestore.batch();
      for (final ticker in chunk) {
        try {
          final ticket = await _fetchTicketDetailsFromApi(
            ticker,
            idToken: idToken,
          );
          final payload = ticket.toJson();
          payload['ticker'] = ticket.ticker;
          payload['category'] = target;
          payload['sourceCategory'] = sourceCategory;
          payload['updatedAt'] = FieldValue.serverTimestamp();

          final docRef = firestore
              .collection('users')
              .doc(userId)
              .collection('ticket_lists')
              .doc(target)
              .collection('tickets')
              .doc(ticket.ticker.toUpperCase());
          batch.set(docRef, payload, SetOptions(merge: true));
          imported += 1;
        } catch (e) {
          debugPrint('Import skipped for ticker $ticker: $e');
        }
      }

      await batch.commit();
    }

    await firestore
        .collection('users')
        .doc(userId)
        .collection('ticket_lists')
        .doc(target)
        .set({
          'itemsCount': imported,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    return imported;
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
