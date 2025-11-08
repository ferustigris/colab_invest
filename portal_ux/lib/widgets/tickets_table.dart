import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:portal_ux/data/models/ticket.dart';
import 'package:portal_ux/data/services/ticket_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TicketsTable extends StatefulWidget {
  final String category;
  const TicketsTable({super.key, this.category = 'stocks'});

  @override
  State<TicketsTable> createState() => _TicketsTableState();
}

class _TicketsTableState extends State<TicketsTable> {
  List<Ticket> tickets = [];
  bool isLoading = true;
  String? errorMessage;
  int? sortColumnIndex;
  bool isAscending = true;
  String searchQuery = '';
  int loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTicketsStream();
  }

  void _loadTicketsStream() {
    setState(() {
      isLoading = true;
      errorMessage = null;
      tickets.clear();
      loadedCount = 0;
    });

    TicketService.getTicketsStream(category: widget.category).listen(
      (ticketsList) {
        debugPrint('Stream update received: ${ticketsList.length} tickets');
        setState(() {
          // Add only new tickets (last element)
          if (ticketsList.length > tickets.length) {
            final newTickets = ticketsList.sublist(tickets.length);
            debugPrint('Adding ${newTickets.length} new tickets');
            for (final ticket in newTickets) {
              debugPrint('Adding ticket: ${ticket.ticker}');
            }
            tickets.addAll(newTickets);
            loadedCount = tickets.length;
          }
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = error.toString();
          isLoading = false;
        });
      },
      onDone: () {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  Future<void> _loadTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedTickets = await TicketService.getTickets();
      setState(() {
        tickets = loadedTickets;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;

      tickets.sort((a, b) {
        dynamic aValue, bValue;

        switch (columnIndex) {
          case 0: // Ticker
            aValue = a.ticker;
            bValue = b.ticker;
            break;
          case 1: // Name
            aValue = a.name;
            bValue = b.name;
            break;
          case 2: // Growth
            aValue = a.profitGrowth10Years ?? 0;
            bValue = b.profitGrowth10Years ?? 0;
            break;
          case 3: // Price
            aValue = a.currentPrice ?? 0;
            bValue = b.currentPrice ?? 0;
            break;
          case 4: // SMA 10Y
            aValue = a.sma10Years ?? 0;
            bValue = b.sma10Years ?? 0;
            break;
          case 5: // Shares Outstanding
            aValue = a.shares ?? 0;
            bValue = b.shares ?? 0;
            break;
          case 6: // Revenue
            aValue = a.revenue ?? 0;
            bValue = b.revenue ?? 0;
            break;
          case 7: // Net Income
            aValue = a.netIncome ?? 0;
            bValue = b.netIncome ?? 0;
            break;
          case 8: // Total Debt
            aValue = a.totalDebt ?? 0;
            bValue = b.totalDebt ?? 0;
            break;
          case 9: // NTA
            aValue = a.nta ?? 0;
            bValue = b.nta ?? 0;
            break;
          case 10: // Forecast DIV
            aValue = a.currentPrice! / (a.priceForecastDiv ?? 1);
            bValue = b.currentPrice! / (b.priceForecastDiv ?? 1);
            break;
          case 11: // Forecast PE
            aValue = a.currentPrice! / (a.priceForecastPE ?? 1);
            bValue = b.currentPrice! / (b.priceForecastPE ?? 1);
            break;
          case 12: // Forecast FPE
            aValue = a.currentPrice! / (a.priceForecastFPE ?? 1);
            bValue = b.currentPrice! / (b.priceForecastFPE ?? 1);
            break;
          case 13: // Forecast Equity
            aValue = a.currentPrice! / (a.priceForecastEquity ?? 1);
            bValue = b.currentPrice! / (b.priceForecastEquity ?? 1);
            break;
          case 14: // Forecast DivBuyback
            aValue = a.currentPrice! / (a.priceForecastDivBuyback ?? 1);
            bValue = b.currentPrice! / (b.priceForecastDivBuyback ?? 1);
            break;
          case 15: // P/E
            aValue = a.pe ?? 0;
            bValue = b.pe ?? 0;
            break;
          case 16: // FPE
            aValue = a.fpe ?? 0;
            bValue = b.fpe ?? 0;
            break;
          case 17: // Free Cash Flow per Stock
            aValue = a.freeCashFlowPerStock ?? 0;
            bValue = b.freeCashFlowPerStock ?? 0;
            break;
          case 18: // Buyback Percent
            aValue = a.buybackPercent ?? 0;
            bValue = b.buybackPercent ?? 0;
            break;
          case 19: // Dividend
            aValue = a.dividend ?? 0;
            bValue = b.dividend ?? 0;
            break;
          default:
            return 0;
        }

        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  List<Ticket> get filteredTickets {
    if (searchQuery.isEmpty) return tickets;

    return tickets.where((ticket) {
      return ticket.ticker.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  String _formatNumber(
    double? value, {
    int decimals = 2,
    String postfix = '',
    String suffix = '',
  }) {
    if (value == null) return 'N/A';
    return '$suffix${value.toStringAsFixed(decimals)}$postfix';
  }

  Color _getProfitGrowthColor(double? growth) {
    if (growth == null) return Colors.grey;
    if (growth > 15) return Colors.green;
    if (growth > 8) return Colors.lightGreen;
    if (growth > 0) return Colors.orange;
    return Colors.red;
  }

  Color _getProfitGrowthBorderColor(Ticket ticket) {
    final growth = ticket.profitGrowth10Years! * 100;
    // Otherwise use standard logic
    return _getProfitGrowthColor(growth);
  }

  Color _getPEColor(double? pe) {
    // Red if below zero or quality below 0.7
    if (pe == null || pe < 0) {
      return Colors.red;
    }

    // Green for 0-10
    if (pe >= 0 && pe <= 10) {
      return Colors.green;
    }

    // Yellow for 10-15
    if (pe > 10 && pe <= 15) {
      return Colors.orange;
    }

    // Red for other cases (>15)
    return Colors.red;
  }

  Color _getForecastColor(double? forecast, double? currentPrice) {
    if (forecast == null || currentPrice == null || currentPrice <= 0) {
      return Colors.grey;
    }

    final ratio = currentPrice / forecast;

    // Green: value less than current price by 20% (less than 80%)
    if (ratio < 0.9 && ratio > 0) {
      return Colors.green;
    }

    // Yellow: value between 80% and 150% of current price
    if (ratio >= 0.9 && ratio <= 1.2) {
      return Colors.orange;
    }

    // Red in other cases (more than 150%)
    return Colors.red;
  }

  Color _getForecastBorderColor(
    Ticket ticket,
    String metricName,
    double? forecast,
  ) {
    // Otherwise use forecast logic
    return _getForecastColor(forecast, ticket.currentPrice);
  }

  DataCell _buildDataCellWithTooltip({
    required Widget child,
    required Ticket ticket,
    required String metricName,
  }) {
    final comment = ticket.comments[metricName] ?? '';
    final quality = ticket.dataQuality[metricName] ?? 1.0;

    Widget cellChild = child;

    // If quality below 0.7, add red border
    if (quality < 0.7) {
      cellChild = Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(
            color: quality < 0.5 ? Colors.red : Colors.yellow,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    }

    if (comment.isNotEmpty) {
      return DataCell(Tooltip(message: comment, child: cellChild));
    } else {
      return DataCell(cellChild);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTickets, child: Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                  style: TextStyle(fontSize: 12),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          await TicketService.clearAllCache();
                          _loadTicketsStream();
                        },
                icon:
                    isLoading
                        ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(Icons.refresh, size: 16),
                label: Text(
                  isLoading && tickets.isNotEmpty
                      ? 'Loading $loadedCount...'
                      : 'Refresh',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ),

        // Cache status info
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 12, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                _getCacheStatusText(),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: sortColumnIndex,
                sortAscending: isAscending,
                showCheckboxColumn: false,
                columnSpacing: 12.0,
                dataRowMinHeight: 35,
                dataRowMaxHeight: 50,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Text(
                      'Ticker',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'Growth',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'SMA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Shares',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Revenue',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Net Inc',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Debt',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'NTA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'F.DIV',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'F.PE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'F.FPE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'F.Eq',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'F.DivBB',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'P/E',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'FPE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Cash%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Buy%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Div%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSort: _onSort,
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Act',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows:
                    filteredTickets.map((ticket) {
                      return DataRow(
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            _showTicketDetails(ticket);
                          }
                        },
                        cells: [
                          DataCell(
                            Text(
                              ticket.ticker,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(maxWidth: 80),
                              child: Text(
                                ticket.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getProfitGrowthColor(
                                  ticket.profitGrowth10Years! * 100,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getProfitGrowthBorderColor(ticket),
                                  width: 0,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.profitGrowth10Years! * 100,
                                  decimals: 0,
                                  suffix: '%',
                                ),
                                style: TextStyle(
                                  color: _getProfitGrowthColor(
                                    ticket.profitGrowth10Years! * 100,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'profitGrowth10Years',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.currentPrice,
                                decimals: 2,
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'currentPrice',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.sma10Years,
                                decimals: 0,
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'sma10Years',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.shares! / 1000_000_000,
                                decimals: 2,
                                postfix: 'B',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'shares',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.revenue! / 1000_000_000,
                                decimals: 2,
                                postfix: 'B',
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'revenue',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.netIncome! / 1000_000_000,
                                decimals: 2,
                                postfix: 'B',
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'netIncome',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.totalDebt! / 1000_000_000,
                                decimals: 2,
                                postfix: 'B',
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'totalDebt',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.nta! / 1000_000_000,
                                decimals: 2,
                                postfix: 'B',
                                suffix: ticket.currency == "USD" ? '\$' : '',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'nta',
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getForecastColor(
                                  ticket.priceForecastDiv,
                                  ticket.currentPrice,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getForecastBorderColor(
                                    ticket,
                                    'priceForecastDiv',
                                    ticket.priceForecastDiv,
                                  ),
                                  width: 0,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.priceForecastDiv,
                                  decimals: 0,
                                  suffix: ticket.currency == "USD" ? '\$' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getForecastColor(
                                    ticket.priceForecastDiv,
                                    ticket.currentPrice,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastDiv',
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getForecastColor(
                                  ticket.priceForecastPE,
                                  ticket.currentPrice,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getForecastBorderColor(
                                    ticket,
                                    'priceForecastPE',
                                    ticket.priceForecastPE,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.priceForecastPE,
                                  decimals: 0,
                                  suffix: ticket.currency == "USD" ? '\$' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getForecastColor(
                                    ticket.priceForecastPE,
                                    ticket.currentPrice,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastPE',
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getForecastColor(
                                  ticket.priceForecastFPE,
                                  ticket.currentPrice,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getForecastBorderColor(
                                    ticket,
                                    'priceForecastFPE',
                                    ticket.priceForecastFPE,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.priceForecastFPE,
                                  decimals: 0,
                                  suffix: ticket.currency == "USD" ? '\$' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getForecastColor(
                                    ticket.priceForecastFPE,
                                    ticket.currentPrice,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastFPE',
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getForecastColor(
                                  ticket.priceForecastEquity,
                                  ticket.currentPrice,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getForecastBorderColor(
                                    ticket,
                                    'priceForecastEquity',
                                    ticket.priceForecastEquity,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.priceForecastEquity,
                                  decimals: 0,
                                  suffix: ticket.currency == "USD" ? '\$' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getForecastColor(
                                    ticket.priceForecastEquity,
                                    ticket.currentPrice,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastEquity',
                          ),
                          _buildDataCellWithTooltip(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getForecastColor(
                                  ticket.priceForecastDivBuyback,
                                  ticket.currentPrice,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getForecastBorderColor(
                                    ticket,
                                    'priceForecastDivBuyback',
                                    ticket.priceForecastDivBuyback,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.priceForecastDivBuyback,
                                  decimals: 0,
                                  suffix: ticket.currency == "USD" ? '\$' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getForecastColor(
                                    ticket.priceForecastDivBuyback,
                                    ticket.currentPrice,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastDivBuyback',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(ticket.pe, decimals: 0),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPEColor(ticket.pe),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'pe',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(ticket.fpe, decimals: 0),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPEColor(ticket.fpe),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'fpe',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.freeCashFlowPerStock,
                                decimals: 1,
                                suffix: '%',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'freeCashFlowPerStock',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.buybackPercent! * 100,
                                decimals: 2,
                                suffix: '%',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'buybackPercent',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.dividend! * 100,
                                decimals: 1,
                                suffix: '%',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'dividend',
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.analytics,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showAnalytics(ticket),
                                  tooltip: 'Analytics',
                                  padding: EdgeInsets.all(2),
                                  constraints: BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _addToWatchlist(ticket),
                                  tooltip: 'Watchlist',
                                  padding: EdgeInsets.all(2),
                                  constraints: BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTicketDetails(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => _FinanceAssistantDialog(ticket: ticket),
    );
  }

  void _showAnalytics(Ticket ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analytics for ${ticket.ticker} coming soon...')),
    );
  }

  void _addToWatchlist(Ticket ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ticket.ticker} added to watchlist!')),
    );
  }

  String _getCacheStatusText() {
    final status = TicketService.getCacheStatus();
    return 'Cache: ${status['ticketsCache']} lists, ${status['detailsCache']} details (${status['cacheDuration']}min TTL)';
  }
}

class _FinanceAssistantDialog extends StatefulWidget {
  final Ticket ticket;

  const _FinanceAssistantDialog({required this.ticket});

  @override
  State<_FinanceAssistantDialog> createState() =>
      _FinanceAssistantDialogState();
}

class _FinanceAssistantDialogState extends State<_FinanceAssistantDialog> {
  bool _isLoading = true;
  String _response = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _callFinanceAssistant();
  }

  Future<void> _callFinanceAssistant() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user and token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Prepare the request
      final url =
          'https://europe-west1-colab-invest-helper.cloudfunctions.net/ask_finance_assistent_chat';

      // Create a comprehensive question about the stock
      final question =
          'Provide a detailed financial analysis of company ${widget.ticket.ticker} (${widget.ticket.name})';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'chat_history': [
            {
              "role": "user",
              "content": question,
              "timestamp": DateFormat(
                'yyyy-MM-dd HH:mm:ss.SSS',
              ).format(DateTime.now()),
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body.toString();
          _isLoading = false;
        });
      } else {
        throw Exception(
          'API call failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to get analysis: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.analytics, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${widget.ticket.ticker} - AI Analysis',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing ${widget.ticket.ticker}...'),
                    ],
                  ),
                )
                : _error != null
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(_error!),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _callFinanceAssistant,
                      child: Text('Retry'),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Header
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ticket.ticker,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  widget.ticket.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${widget.ticket.currentPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'P/E: ${widget.ticket.pe?.toStringAsFixed(1) ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // AI Analysis Response
                      Text(
                        'AI Financial Analysis:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _response,
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(
            onPressed: _callFinanceAssistant,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 16),
                SizedBox(width: 4),
                Text('Refresh Analysis'),
              ],
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
