import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/providers/inventory_provider.dart';
import 'package:ammas_kitchen/screens/add_item_screen.dart';
import 'package:ammas_kitchen/screens/item_detail_screen.dart';
import 'package:ammas_kitchen/screens/settings_screen.dart';
import 'package:ammas_kitchen/services/update_service.dart';
import 'package:ammas_kitchen/data/shelf_life_data.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final updateInfo = await UpdateService.instance.checkForUpdate();
    if (updateInfo != null && mounted) {
      await UpdateService.instance.showUpdateDialog(context, updateInfo);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items, brands...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (query) {
                  context.read<InventoryProvider>().search(query);
                },
              )
            : const Text("Amma's Kitchen"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<InventoryProvider>().search('');
                }
              });
            },
          ),
          // Sort button
          Consumer<InventoryProvider>(
            builder: (context, provider, _) => PopupMenuButton<SortMode>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onSelected: (mode) => provider.setSortMode(mode),
              itemBuilder: (_) => [
                _sortMenuItem(SortMode.byExpiry, 'By expiry date', Icons.timer_outlined, provider),
                _sortMenuItem(SortMode.byName, 'By name', Icons.sort_by_alpha, provider),
                _sortMenuItem(SortMode.byDateAdded, 'By date added', Icons.calendar_today, provider),
                _sortMenuItem(SortMode.byCategory, 'By category', Icons.category_outlined, provider),
              ],
            ),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.totalItems == 0) {
            return _buildEmptyState();
          }
          return _buildInventoryList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddItem(),
        icon: const Icon(Icons.camera_alt, size: 28),
        label: const Text('Add Item', style: TextStyle(fontSize: 16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PopupMenuEntry<SortMode> _sortMenuItem(
      SortMode mode, String text, IconData icon, InventoryProvider provider) {
    final isSelected = provider.sortMode == mode;
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: 8),
          Text(text, style: isSelected ? TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ) : null),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍳', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Your kitchen inventory is empty!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button below to add your first item.\nJust snap a photo!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList(InventoryProvider provider) {
    return Column(
      children: [
        // Expiring this week card (replaces old banner)
        _buildExpiringThisWeekCard(provider),

        // Filter chips
        _buildFilterChips(provider),

        // Items list
        Expanded(
          child: provider.items.isEmpty
              ? Center(
                  child: Text(
                    'No items match your filters',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(provider.items[index], provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExpiringThisWeekCard(InventoryProvider provider) {
    final thisWeek = provider.items.where((item) {
      final days = item.daysUntilExpiry;
      return days != null && days >= 0 && days <= 7;
    }).toList();

    if (thisWeek.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => provider.setShowExpiringOnly(!provider.showExpiringOnly),
      child: Card(
        color: Colors.orange[50],
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Expiring this week (${thisWeek.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    provider.showExpiringOnly ? 'Show all' : 'View',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...thisWeek.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${categoryIcons[item.category] ?? ''} ${item.name} — ${_getExpiryText(item)}',
                      style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (thisWeek.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+${thisWeek.length - 3} more',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(InventoryProvider provider) {
    // Only show locations that have items
    final activeLocations = <String>{};
    for (final item in provider.items) {
      activeLocations.add(item.storageLocation);
    }
    final locations = ['fridge', 'freezer', 'pantry', 'shelf', 'countertop']
        .where((loc) => activeLocations.contains(loc))
        .toList();

    if (locations.isEmpty && provider.filterLocation == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...locations.map((location) {
            final isSelected = provider.filterLocation == location;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${locationIcons[location] ?? ''} ${location[0].toUpperCase()}${location.substring(1)}',
                ),
                selected: isSelected,
                onSelected: (_) {
                  provider.setLocationFilter(isSelected ? null : location);
                },
              ),
            );
          }),
          if (provider.filterLocation != null ||
              provider.filterCategory != null ||
              provider.showExpiringOnly)
            ActionChip(
              label: const Text('Clear'),
              avatar: const Icon(Icons.clear, size: 16),
              onPressed: () => provider.clearFilters(),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item, InventoryProvider provider) {
    final expiryColor = _getExpiryColor(item.expiryStatus);

    return Dismissible(
      key: Key('item_${item.id}'),
      direction: DismissDirection.horizontal,
      // Swipe right = Edit
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      // Swipe left = Used
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.green,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Used', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right = navigate to edit, don't dismiss
          _navigateToDetail(item, editMode: true);
          return false;
        }
        return true; // Allow swipe-to-used
      },
      onDismissed: (_) async {
        final removed = await provider.markUsed(item.id!);
        if (removed != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} marked as used'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => provider.undoMarkUsed(removed),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Expiry indicator bar
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: expiryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Category icon
                Text(
                  categoryIcons[item.category] ?? '🏷️',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),

                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit} · ${locationIcons[item.storageLocation] ?? ''} ${item.storageLocation}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Expiry info + quantity controls (horizontal)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getExpiryText(item),
                      style: TextStyle(
                        color: expiryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (item.expiryDate != null)
                      Text(
                        DateFormat('dd MMM').format(item.expiryDate!),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Horizontal quantity controls (fixed overlap issue)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                size: 18, color: Colors.grey[600]),
                            padding: EdgeInsets.zero,
                            onPressed: () => provider.updateQuantity(
                              item.id!,
                              item.quantity - 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                size: 18, color: Colors.grey[600]),
                            padding: EdgeInsets.zero,
                            onPressed: () => provider.updateQuantity(
                              item.id!,
                              item.quantity + 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getExpiryColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.fresh:
        return Colors.green;
      case ExpiryStatus.soon:
        return Colors.orange;
      case ExpiryStatus.today:
        return Colors.red;
      case ExpiryStatus.expired:
        return Colors.red[900]!;
      case ExpiryStatus.none:
        return Colors.grey;
    }
  }

  String _getExpiryText(InventoryItem item) {
    final days = item.daysUntilExpiry;
    if (days == null) return 'No expiry';
    if (days < 0) return 'Expired ${-days}d ago';
    if (days == 0) return 'Expires today!';
    if (days == 1) return 'Tomorrow';
    if (days <= 7) return '$days days left';
    return '$days days';
  }

  Future<void> _navigateToAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  void _navigateToDetail(InventoryItem item, {bool editMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item, editMode: editMode)),
    );
  }
}
