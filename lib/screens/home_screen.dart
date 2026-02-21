import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/providers/inventory_provider.dart';
import 'package:ammas_kitchen/screens/add_item_screen.dart';
import 'package:ammas_kitchen/screens/item_detail_screen.dart';
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
    // Delay slightly so the UI renders first
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
                  hintText: 'Search items...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🍳',
              style: TextStyle(fontSize: 80),
            ),
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
        // Expiring soon banner
        if (provider.expiringCount > 0) _buildExpiringBanner(provider),

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

  Widget _buildExpiringBanner(InventoryProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setShowExpiringOnly(!provider.showExpiringOnly);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.orange[50],
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${provider.expiringCount} item${provider.expiringCount > 1 ? 's' : ''} expiring soon!',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              provider.showExpiringOnly ? 'Show all' : 'View',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(InventoryProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Location filters
          ...['fridge', 'freezer', 'pantry', 'countertop'].map((location) {
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
          // Clear filters
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
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.green,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Used', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      confirmDismiss: (_) async => true,
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
                // Expiry indicator
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
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${locationIcons[item.storageLocation] ?? ''} ${item.storageLocation}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expiry info
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
                  ],
                ),

                // Quantity controls
                const SizedBox(width: 8),
                Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        padding: EdgeInsets.zero,
                        onPressed: () => provider.updateQuantity(
                          item.id!,
                          item.quantity + 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        padding: EdgeInsets.zero,
                        onPressed: () => provider.updateQuantity(
                          item.id!,
                          item.quantity - 1,
                        ),
                      ),
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

  void _navigateToDetail(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
  }
}
