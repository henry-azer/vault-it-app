import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/routes/app_routes.dart';
import 'package:pass_vault_it/core/utils/app_colors.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/data/entities/account.dart';
import 'package:pass_vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:provider/provider.dart';

class VaultAccountCard extends StatefulWidget {
  final Account data;
  final bool isDark;
  final VoidCallback? onTap;

  const VaultAccountCard({
    super.key,
    required this.data,
    required this.isDark,
    this.onTap,
  });

  @override
  State<VaultAccountCard> createState() => _VaultAccountCardState();
}

class _VaultAccountCardState extends State<VaultAccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    final accountProvider = context.read<AccountProvider>();
    accountProvider.selectAccount(widget.data);

    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.pushNamed(
        context,
        Routes.viewAccount,
        arguments: widget.data,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [Colors.grey[850]!, Colors.grey[900]!]
                  : [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? Theme.of(context).colorScheme.primary
                  : (widget.isDark ? Colors.grey[800]! : Colors.grey[200]!),
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : (widget.isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.08)),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 4 : 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.data.username,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgoText(),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildFavoriteButton(),
                    const SizedBox(height: 8),
                    _buildTrailingActions(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final provider = context.read<AccountProvider>();
        final success = await provider.toggleFavorite(widget.data.id);

        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.failedToFavorite.tr),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.snackbarError,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.data.isFavorite
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : (widget.isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          widget.data.isFavorite ? Icons.star : Icons.star_border,
          size: 18,
          color: widget.data.isFavorite
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: '${widget.data.id}',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _getIconOrLetter(),
        ),
      ),
    );
  }

  Widget _getIconOrLetter() {
    if (widget.data.url != null && widget.data.url!.isNotEmpty) {
      final uri = Uri.parse(widget.data.url!);
      final domain = uri.host;

      if (domain.isNotEmpty) {
        final firstLetter = domain[0].toUpperCase();
        return Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    final firstLetter =
        widget.data.title.isNotEmpty ? widget.data.title[0].toUpperCase() : 'P';
    return Text(
      firstLetter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrailingActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[600],
      ),
    );
  }

  String _getTimeAgoText() {
    final now = DateTime.now();
    final difference = now.difference(widget.data.addedDate);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return AppStrings.justNow.tr;
        }
        return '${difference.inMinutes}${AppStrings.minutesAgo.tr}';
      }
      return '${difference.inHours}${AppStrings.hoursAgo.tr}';
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday.tr;
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${AppStrings.daysAgo.tr}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks${AppStrings.weeksAgo.tr}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months${AppStrings.monthsAgo.tr}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years${AppStrings.yearsAgo.tr}';
    }
  }
}
