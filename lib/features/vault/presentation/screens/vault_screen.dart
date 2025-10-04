import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/routes/app_routes.dart';
import 'package:pass_vault_it/core/enums/vault_enums.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/data/entities/account.dart';
import 'package:pass_vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:pass_vault_it/features/vault/presentation/widgets/vault_account_card.dart';
import 'package:provider/provider.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  bool _isSearchActive = false;
  AccountSortType _sortBy = AccountSortType.dateAdded;
  AccountFilterType _filterBy = AccountFilterType.all;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<AccountProvider>().searchAccounts(query);
    setState(() {});
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchActive = _searchFocusNode.hasFocus;
    });

    if (_isSearchActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: _buildContent(isDark),
              ),
            ],
          ),
        ),
        floatingActionButton: _isSearchActive ? null : _buildFAB(isDark),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Consumer<AccountProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.accountsVault.tr,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${provider.accountCount} ${AppStrings.accountsCount.tr}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildHeaderActions(isDark),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          _buildSearchBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isDark) {
    final bool isFilterActive = _filterBy != AccountFilterType.all;
    final bool isSortActive = _sortBy != AccountSortType.dateAdded;

    return Row(
      children: [
        _buildActionButton(
          icon: Icons.sort_rounded,
          onPressed: _showSortSheet,
          isDark: isDark,
          isActive: isSortActive,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.tune_rounded,
          onPressed: _showFilterSheet,
          isDark: isDark,
          isActive: isFilterActive,
        )
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : (isDark ? Colors.grey[800] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: _isSearchActive
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.primary.withOpacity(0.04),
                ],
              )
            : LinearGradient(
                colors: [
                  isDark ? Colors.grey[800]! : Colors.grey[50]!,
                  isDark ? Colors.grey[850]! : Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSearchActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
          width: _isSearchActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSearchActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : (isDark ? Colors.black26 : Colors.black.withOpacity(0.04)),
            blurRadius: _isSearchActive ? 8 : 6,
            offset: Offset(0, _isSearchActive ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: _isSearchActive
                    ? AppStrings.searchAccountsHintActive.tr
                    : AppStrings.searchAccounts.tr,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _isSearchActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400],
                  size: _isSearchActive ? 22 : 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _clearSearch,
                      )
                    : (_isSearchActive
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              _searchFocusNode.unfocus();
                              HapticFeedback.lightImpact();
                            },
                            tooltip: AppStrings.close.tr,
                          )
                        : null),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return RefreshIndicator(
      onRefresh: () => context.read<AccountProvider>().loadAccounts(),
      color: Theme.of(context).colorScheme.primary,
      child: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          if (accountProvider.isLoading && accountProvider.accounts.isEmpty) {
            return _buildLoadingState(isDark);
          }

          List<Account> accounts = accountProvider.searchQuery.isNotEmpty
              ? accountProvider.filteredAccounts
              : accountProvider.accounts;

          List<Account> filteredAccounts = _applyFilter(accounts);
          filteredAccounts = _applySort(filteredAccounts);

          if (filteredAccounts.isEmpty) {
            return _buildEmptyState(accountProvider, isDark);
          }

          return _buildAccountList(filteredAccounts, isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AccountProvider provider, bool isDark) {
    if (provider.searchQuery.isNotEmpty) {
      return _buildNoSearchResults(isDark);
    }
    if (_filterBy != AccountFilterType.all) {
      return _buildNoFilterResults(isDark);
    }
    return _buildNoAccounts(isDark);
  }

  Widget _buildNoSearchResults(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.deepOrange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(70),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 70,
                  color: Colors.orange[400],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppStrings.noMatchesFound.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.tryDifferentKeywords.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text(
                  AppStrings.clearSearch.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFilterResults(bool isDark) {
    IconData filterIcon;
    String filterDescription;

    switch (_filterBy) {
      case AccountFilterType.weak:
        filterIcon = Icons.warning_rounded;
        filterDescription = AppStrings.noWeakPasswords.tr;
        break;
      case AccountFilterType.stale:
        filterIcon = Icons.history_rounded;
        filterDescription = AppStrings.noStalePasswords.tr;
        break;
      case AccountFilterType.favorites:
        filterIcon = Icons.star_rounded;
        filterDescription = AppStrings.noFavorites.tr;
        break;
      default:
        filterIcon = Icons.filter_alt_rounded;
        filterDescription = AppStrings.noFilterResults.tr;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.deepOrange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(70),
                ),
                child: Icon(
                  filterIcon,
                  size: 70,
                  color: Colors.orange[400],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.noResults.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                filterDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterBy = AccountFilterType.all;
                  });
                  HapticFeedback.lightImpact();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text(
                  AppStrings.clearFilter.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoAccounts(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.vaultEmpty.tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.vaultEmptyDesc.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[500],
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountList(List<Account> accounts, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: accounts.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VaultAccountCard(
                    account: accounts[index],
                    isDark: isDark,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        Routes.viewAccount,
                        arguments: accounts[index],
                      );
                      if (mounted && _searchController.text.isNotEmpty) {
                        _clearSearch();
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB(bool isDark) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, Routes.account);
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AccountProvider>().clearSearch();
    _searchFocusNode.unfocus();
  }

  List<Account> _applyFilter(List<Account> accounts) {
    switch (_filterBy) {
      case AccountFilterType.weak:
        return accounts.where((p) {
          final pwd = p.password;
          return pwd.length < 8 ||
              pwd == pwd.toLowerCase() ||
              pwd == pwd.toUpperCase() ||
              !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd);
        }).toList();
      case AccountFilterType.stale:
        return accounts.where((p) {
          final daysSinceModified =
              DateTime.now().difference(p.lastModified).inDays;
          return daysSinceModified > 90;
        }).toList();
      case AccountFilterType.favorites:
        return accounts.where((p) => p.isFavorite).toList();
      case AccountFilterType.all:
      default:
        return accounts;
    }
  }

  List<Account> _applySort(List<Account> accounts) {
    final sortedList = List<Account>.from(accounts);

    switch (_sortBy) {
      case AccountSortType.name:
        sortedList.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;

      case AccountSortType.lastModified:
        sortedList.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;

      case AccountSortType.dateAdded:
      default:
        sortedList.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
    }

    return sortedList;
  }

  void _showFilterSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.filterAccounts.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              Icons.grid_view_rounded,
              AppStrings.allAccounts.tr,
              AppStrings.showAllAccounts.tr,
              AccountFilterType.all,
            ),
            _buildFilterOption(
              Icons.warning_rounded,
              AppStrings.weakPasswordsTitle.tr,
              AppStrings.weakPasswordsDesc.tr,
              AccountFilterType.weak,
            ),
            _buildFilterOption(
              Icons.history_rounded,
              AppStrings.stalePasswordsTitle.tr,
              AppStrings.stalePasswordsDesc.tr,
              AccountFilterType.stale,
            ),
            _buildFilterOption(
              Icons.star_rounded,
              AppStrings.favoritesTitle.tr,
              AppStrings.favoritesDesc.tr,
              AccountFilterType.favorites,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
      IconData icon, String title, String subtitle, AccountFilterType value) {
    final isSelected = _filterBy == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () {
          setState(() {
            _filterBy = value;
          });
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.sortAccounts.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSortOption(
              Icons.access_time_rounded,
              AppStrings.sortDateAdded.tr,
              AppStrings.sortNewestFirst.tr,
              AccountSortType.dateAdded,
            ),
            _buildSortOption(
              Icons.sort_by_alpha_rounded,
              AppStrings.sortNameAZ.tr,
              AppStrings.sortAlphabeticalOrder.tr,
              AccountSortType.name,
            ),
            _buildSortOption(
              Icons.update_rounded,
              AppStrings.sortLastModified.tr,
              AppStrings.sortRecentlyUpdated.tr,
              AccountSortType.lastModified,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      IconData icon, String title, String subtitle, AccountSortType value) {
    final isSelected = _sortBy == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () {
          setState(() {
            _sortBy = value;
          });
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
      ),
    );
  }
}
