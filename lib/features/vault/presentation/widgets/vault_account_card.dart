import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/core/constants/popular_websites.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/data/entities/account.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:provider/provider.dart';

class VaultAccountCard extends StatefulWidget {
  final Account account;
  final bool isDark;
  final VoidCallback? onTap;

  const VaultAccountCard({
    super.key,
    required this.account,
    required this.isDark,
    this.onTap,
  });

  @override
  State<VaultAccountCard> createState() => _VaultAccountCardState();
}

class _VaultAccountCardState extends State<VaultAccountCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    final accountProvider = context.read<AccountProvider>();
    accountProvider.selectAccount(widget.account);

    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.pushNamed(
        context,
        Routes.viewAccount,
        arguments: widget.account,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed
                ? Theme.of(context).colorScheme.primary
                : (widget.isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : (widget.isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.08)),
              blurRadius: _isPressed ? 4 : 2,
              offset: Offset(0, _isPressed ? 4 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.width * 0.015,
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.002),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: widget.isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.account.username,
                            style: TextStyle(
                              color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.004),
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
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final provider = context.read<AccountProvider>();
        final success = await provider.toggleFavorite(widget.account.id);

        if (!success && mounted) {
          SnackBarHelper.showError(
            context,
            AppStrings.failedToFavorite.tr,
            duration: const Duration(seconds: 1),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.account.isFavorite
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : (widget.isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          widget.account.isFavorite ? Icons.star : Icons.star_border,
          size: 18,
          color: widget.account.isFavorite
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: widget.account.id,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildFaviconOrFallback(),
        ),
      ),
    );
  }

  Widget _buildFaviconOrFallback() {
    String? faviconUrl;

    if (widget.account.url != null && widget.account.url!.isNotEmpty) {
      faviconUrl = PopularWebsites.getFaviconUrl(widget.account.url!);
    }

    if (faviconUrl != null) {
      return CachedNetworkImage(
        imageUrl: faviconUrl,
        fit: BoxFit.cover,
        width: 45,
        height: 45,
        placeholder: (context, url) => _buildSkeletonLoader(),
        errorWidget: (context, url, error) => _buildFallbackIcon(),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildSkeletonLoader() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.darkCardBorder,
                  AppColors.darkSurface,
                ]
              : [
                  AppColors.lightCardBorder,
                  AppColors.lightSurface,
                  AppColors.lightCardBorder,
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: widget.isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_rounded,
          size: 24,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }

  Widget _buildTrailingActions() {
    return GestureDetector(
        onTap: () async {
          HapticFeedback.selectionClick();
          await Navigator.pushNamed(context, Routes.account,
              arguments: widget.account);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
          ),
        ));
  }
}
