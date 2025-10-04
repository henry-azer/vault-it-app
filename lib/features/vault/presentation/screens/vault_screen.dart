import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/core/enums/vault_enums.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/data/entities/account.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:vault_it/features/vault/presentation/widgets/vault_account_card.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
              : [Color(0xFFFAFAFA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(isDark),
          const SizedBox(height: 20),
          _buildStatsCards(isDark),
          const SizedBox(height: 20),
          _buildSearchBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.accountsVault.tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        _buildHeaderActions(isDark),
      ],
    );
  }

  Widget _buildStatsCards(bool isDark) {
    return Consumer<AccountProvider>(
      builder: (context, provider, child) {
        final accountCount = provider.accounts.length;
        final filteredCount = provider.filteredAccounts.length;
        final isSearching = provider.searchQuery.isNotEmpty;
        final weakCount = _applyFilter(provider.accounts).where((a) {
          final pwd = a.password;
          return pwd.length < 8 || pwd == pwd.toLowerCase() || pwd == pwd.toUpperCase();
        }).length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.vpn_key_rounded,
                label: AppStrings.accounts.tr,
                value: isSearching ? filteredCount.toString() : accountCount.toString(),
                color: Theme.of(context).colorScheme.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.security_rounded,
                label: AppStrings.strong.tr,
                value: '${accountCount - weakCount}',
                color: Colors.green,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning_amber_rounded,
                label: AppStrings.weak.tr,
                value: weakCount.toString(),
                color: weakCount > 0 ? AppColors.warning : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled),
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E2746) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _isSearchActive
            ? (isDark ? Color(0xFF1E2746) : Colors.white)
            : (isDark ? Color(0xFF16213E).withOpacity(0.6) : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchActive
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: _isSearchActive ? 2 : 1,
        ),
        boxShadow: _isSearchActive
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                color: isDark ? Colors.white : Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: _isSearchActive
                    ? AppStrings.searchAccountsHintActive.tr
                    : AppStrings.searchAccounts.tr,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isSearchActive
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled),
                    size: _isSearchActive ? 24 : 22,
                  ),
                ),
                suffixIcon: _isSearchActive
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          ),
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
            : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              isDark,
            ),
            _buildFilterOption(
              Icons.warning_rounded,
              AppStrings.weakPasswordsTitle.tr,
              AppStrings.weakPasswordsDesc.tr,
              AccountFilterType.weak,
              isDark,
            ),
            _buildFilterOption(
              Icons.history_rounded,
              AppStrings.stalePasswordsTitle.tr,
              AppStrings.stalePasswordsDesc.tr,
              AccountFilterType.stale,
              isDark,
            ),
            _buildFilterOption(
              Icons.star_rounded,
              AppStrings.favoritesTitle.tr,
              AppStrings.favoritesDesc.tr,
              AccountFilterType.favorites,
              isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
      IconData icon, String title, String subtitle, AccountFilterType value, bool isDark) {
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
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              isDark,
            ),
            _buildSortOption(
              Icons.sort_by_alpha_rounded,
              AppStrings.sortNameAZ.tr,
              AppStrings.sortAlphabeticalOrder.tr,
              AccountSortType.name,
              isDark,
            ),
            _buildSortOption(
              Icons.update_rounded,
              AppStrings.sortLastModified.tr,
              AppStrings.sortRecentlyUpdated.tr,
              AccountSortType.lastModified,
              isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      IconData icon, String title, String subtitle, AccountSortType value, bool isDark) {
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
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
