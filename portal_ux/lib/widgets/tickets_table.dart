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

  @override
  void initState() {
    super.initState();
    _loadTickets();
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
          case 0:
            aValue = a.id;
            bValue = b.id;
            break;
          case 1:
            aValue = a.title;
            bValue = b.title;
            break;
          case 2:
            aValue = a.status;
            bValue = b.status;
            break;
          case 3:
            aValue = a.priority;
            bValue = b.priority;
            break;
          case 4:
            aValue = a.createdAt;
            bValue = b.createdAt;
            break;
          case 5:
            aValue = a.assignedTo;
            bValue = b.assignedTo;
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
      return ticket.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.status.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.assignedTo.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search tickets...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadTickets,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
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
                columns: [
                  DataColumn(label: Text('Ticket ID'), onSort: _onSort),
                  DataColumn(label: Text('Title'), onSort: _onSort),
                  DataColumn(label: Text('Status'), onSort: _onSort),
                  DataColumn(label: Text('Priority'), onSort: _onSort),
                  DataColumn(label: Text('Created'), onSort: _onSort),
                  DataColumn(label: Text('Assigned To'), onSort: _onSort),
                  DataColumn(label: Text('Actions')),
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
                              ticket.id,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Text(
                                ticket.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  ticket.status,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(ticket.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                ticket.status,
                                style: TextStyle(
                                  color: _getStatusColor(ticket.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  ticket.priority,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getPriorityColor(ticket.priority),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                ticket.priority,
                                style: TextStyle(
                                  color: _getPriorityColor(ticket.priority),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                            ),
                          ),
                          DataCell(Text(ticket.assignedTo)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 18),
                                  onPressed: () => _editTicket(ticket),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteTicket(ticket),
                                  tooltip: 'Delete',
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

        // Add Ticket Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addTicket,
            icon: Icon(Icons.add),
            label: Text('Add New Ticket'),
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
            title: Text('Ticket Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: ${ticket.id}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Title: ${ticket.title}'),
                SizedBox(height: 8),
                Text('Status: ${ticket.status}'),
                SizedBox(height: 8),
                Text('Priority: ${ticket.priority}'),
                SizedBox(height: 8),
                Text('Assigned to: ${ticket.assignedTo}'),
                SizedBox(height: 8),
                Text('Created: ${ticket.createdAt.toString()}'),
                SizedBox(height: 8),
                Text('Description:'),
                SizedBox(height: 4),
                Text(ticket.description),
              ],
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

  void _editTicket(Ticket ticket) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality coming soon...')),
    );
  }

  void _deleteTicket(Ticket ticket) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Ticket'),
            content: Text(
              'Are you sure you want to delete ticket ${ticket.id}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    tickets.removeWhere((t) => t.id == ticket.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ticket ${ticket.id} deleted')),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _addTicket() {
    // TODO: Implement add functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add ticket functionality coming soon...')),
    );
  }
}
