import 'package:flutter/material.dart';
import 'package:portal_ux/data/models/ticket.dart';
import 'package:portal_ux/data/services/ticket_service.dart';

class TicketsTable extends StatefulWidget {
  const TicketsTable({super.key});

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

    TicketService.getTicketsStream().listen(
      (ticketsList) {
        print('Stream update received: ${ticketsList.length} tickets');
        setState(() {
          // Добавляем только новые тикеты (последний элемент)
          if (ticketsList.length > tickets.length) {
            final newTickets = ticketsList.sublist(tickets.length);
            print('Adding ${newTickets.length} new tickets');
            for (final ticket in newTickets) {
              print('Adding ticket: ${ticket.ticker}');
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
          case 2: // Current Price
            aValue = a.currentPrice ?? 0;
            bValue = b.currentPrice ?? 0;
            break;
          case 3: // Shares Outstanding
            aValue = a.sharesOutstanding ?? 0;
            bValue = b.sharesOutstanding ?? 0;
            break;
          case 4: // Revenue
            aValue = a.revenue ?? 0;
            bValue = b.revenue ?? 0;
            break;
          case 5: // Net Income
            aValue = a.netIncome ?? 0;
            bValue = b.netIncome ?? 0;
            break;
          case 6: // Total Debt
            aValue = a.totalDebt ?? 0;
            bValue = b.totalDebt ?? 0;
            break;
          case 7: // SMA 10Y
            aValue = a.sma10Years ?? 0;
            bValue = b.sma10Years ?? 0;
            break;
          case 8: // Forecast DIV
            aValue = a.priceForecastDiv ?? 0;
            bValue = b.priceForecastDiv ?? 0;
            break;
          case 9: // Forecast PE
            aValue = a.priceForecastPE ?? 0;
            bValue = b.priceForecastPE ?? 0;
            break;
          case 10: // Forecast Equity
            aValue = a.priceForecastEquity ?? 0;
            bValue = b.priceForecastEquity ?? 0;
            break;
          case 11: // Profit Growth 10Y
            aValue = a.profitGrowth10Years ?? 0;
            bValue = b.profitGrowth10Years ?? 0;
            break;
          case 12: // P/E
            aValue = a.pe ?? 0;
            bValue = b.pe ?? 0;
            break;
          case 13: // FPE
            aValue = a.fpe ?? 0;
            bValue = b.fpe ?? 0;
            break;
          case 14: // Free Cash Flow per Stock
            aValue = a.freeCashFlowPerStock ?? 0;
            bValue = b.freeCashFlowPerStock ?? 0;
            break;
          case 15: // Buyback Percent
            aValue = a.buybackPercent ?? 0;
            bValue = b.buybackPercent ?? 0;
            break;
          case 16: // Dividend Yield
            aValue = a.dividendYield ?? 0;
            bValue = b.dividendYield ?? 0;
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

  String _formatNumber(double? value, {int decimals = 2, String suffix = ''}) {
    if (value == null) return 'N/A';
    return '${value.toStringAsFixed(decimals)}$suffix';
  }

  Color _getProfitGrowthColor(double? growth) {
    if (growth == null) return Colors.grey;
    if (growth > 20) return Colors.green;
    if (growth > 10) return Colors.lightGreen;
    if (growth > 0) return Colors.orange;
    return Colors.red;
  }

  Color _getProfitGrowthBorderColor(Ticket ticket) {
    final growth = ticket.profitGrowth10Years;
    final quality = ticket.dataQuality['profitGrowth10Years'] ?? 1.0;

    // Если качество низкое, возвращаем красный
    if (quality < 0.7) {
      return Colors.red;
    }

    // Иначе используем стандартную логику
    return _getProfitGrowthColor(growth);
  }

  Color _getPEColor(Ticket ticket) {
    final pe = ticket.pe;
    final quality = ticket.dataQuality['pe'] ?? 1.0;

    // Красный если ниже нуля или качество ниже 0.7
    if (pe == null || pe < 0 || quality < 0.7) {
      return Colors.red;
    }

    // Зеленый для 0-10
    if (pe >= 0 && pe <= 10) {
      return Colors.green;
    }

    // Желтый для 10-15
    if (pe > 10 && pe <= 15) {
      return Colors.orange;
    }

    // Красный для остальных случаев (>15)
    return Colors.red;
  }

  DataCell _buildDataCellWithTooltip({
    required Widget child,
    required Ticket ticket,
    required String metricName,
  }) {
    final comment = ticket.comments[metricName] ?? '';
    final quality = ticket.dataQuality[metricName] ?? 1.0;

    Widget cellChild = child;

    // Если качество ниже 0.7, добавляем красную рамку
    if (quality < 0.7) {
      cellChild = Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1),
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
                onPressed: _loadTicketsStream,
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
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
                      'FCF%',
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
                            child: Text(
                              "\$" +
                                  _formatNumber(
                                    ticket.currentPrice,
                                    decimals: 2,
                                  ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'currentPrice',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.sharesOutstanding! / 1000_000_000,
                                decimals: 2,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'sharesOutstanding',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.revenue! / 1000_000_000,
                                decimals: 2,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'revenue',
                          ),
                          DataCell(
                            Text(
                              _formatNumber(
                                ticket.netIncome! / 1000_000_000,
                                decimals: 2,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.totalDebt! / 1000_000_000,
                                decimals: 2,
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
                              _formatNumber(ticket.sma10Years, decimals: 0),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'sma10Years',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.priceForecastDiv,
                                decimals: 0,
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastDiv',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.priceForecastPE,
                                decimals: 0,
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'priceForecastPE',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(
                                ticket.priceForecastEquity,
                                decimals: 0,
                              ),
                              style: TextStyle(fontSize: 12),
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
                                color: _getProfitGrowthColor(
                                  ticket.profitGrowth10Years,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getProfitGrowthBorderColor(ticket),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatNumber(
                                  ticket.profitGrowth10Years,
                                  decimals: 0,
                                  suffix: '%',
                                ),
                                style: TextStyle(
                                  color: _getProfitGrowthColor(
                                    ticket.profitGrowth10Years,
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
                              _formatNumber(ticket.pe, decimals: 0),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPEColor(ticket),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ticket: ticket,
                            metricName: 'pe',
                          ),
                          _buildDataCellWithTooltip(
                            child: Text(
                              _formatNumber(ticket.fpe, decimals: 0),
                              style: TextStyle(fontSize: 12),
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
                                ticket.buybackPercent,
                                decimals: 1,
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
                                ticket.dividendYield,
                                decimals: 1,
                                suffix: '%',
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            ticket: ticket,
                            metricName: 'dividendYield',
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
      builder:
          (context) => AlertDialog(
            title: Text('${ticket.ticker} - ${ticket.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Ticker', ticket.ticker),
                  _buildDetailRow('Company Name', ticket.name),
                  _buildDetailRow(
                    'Current Price',
                    _formatNumber(ticket.currentPrice, suffix: '\$'),
                  ),
                  _buildDetailRow(
                    'Market Cap',
                    _formatNumber(ticket.marketCap, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'Revenue',
                    _formatNumber(ticket.revenue, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'Net Income',
                    _formatNumber(ticket.netIncome, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'EBITDA',
                    _formatNumber(ticket.ebitda, suffix: 'B'),
                  ),
                  _buildDetailRowWithColor(
                    'P/E Ratio',
                    _formatNumber(ticket.pe, decimals: 1),
                    _getPEColor(ticket),
                  ),
                  _buildDetailRow(
                    'FPE',
                    _formatNumber(ticket.fpe, decimals: 1),
                  ),
                  _buildDetailRow(
                    'Free Cash Flow per Stock',
                    _formatNumber(
                      ticket.freeCashFlowPerStock,
                      decimals: 2,
                      suffix: '%',
                    ),
                  ),
                  _buildDetailRow(
                    'Buyback',
                    _formatNumber(
                      ticket.buybackPercent,
                      decimals: 1,
                      suffix: '%',
                    ),
                  ),
                  _buildDetailRow(
                    'Dividend Yield',
                    _formatNumber(ticket.dividendYield, suffix: '%'),
                  ),
                  _buildDetailRow(
                    'P/S Ratio',
                    _formatNumber(ticket.ps, decimals: 1),
                  ),
                  _buildDetailRow(
                    'EV/EBITDA',
                    _formatNumber(ticket.evEbitda, decimals: 1),
                  ),
                  _buildDetailRow(
                    'Dividend Yield',
                    _formatNumber(ticket.dividendYield, suffix: '%'),
                  ),
                  _buildDetailRow(
                    'Shares Outstanding',
                    _formatNumber(ticket.sharesOutstanding, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'SMA 10 Years',
                    _formatNumber(ticket.sma10Years, decimals: 1),
                  ),
                  _buildDetailRow(
                    'Price Forecast (DIV)',
                    _formatNumber(ticket.priceForecastDiv, suffix: '\$'),
                  ),
                  _buildDetailRow(
                    'Price Forecast (PE)',
                    _formatNumber(ticket.priceForecastPE, suffix: '\$'),
                  ),
                  _buildDetailRow(
                    'Price Forecast (Equity)',
                    _formatNumber(ticket.priceForecastEquity, suffix: '\$'),
                  ),
                  _buildDetailRow(
                    'Profit Growth 10Y',
                    _formatNumber(ticket.profitGrowth10Years, suffix: '%'),
                  ),
                  _buildDetailRow(
                    'Free Cash Flow',
                    _formatNumber(ticket.freeCashFlow, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'Total Debt',
                    _formatNumber(ticket.totalDebt, suffix: 'B'),
                  ),
                  _buildDetailRow(
                    'Cash',
                    _formatNumber(ticket.cash, suffix: 'B'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
}
