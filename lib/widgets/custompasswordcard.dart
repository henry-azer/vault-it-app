import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/entities/password.dart';
import '../features/vault/presentation/providers/password_provider.dart';
import '../config/routes/app_routes.dart';

class CustomPasswordCard extends StatelessWidget {
  final Password data;
  const CustomPasswordCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          final passwordProvider = context.read<PasswordProvider>();
          passwordProvider.selectPassword(data);
          Navigator.pushNamed(
            context,
            Routes.viewPassword,
            arguments: data,
          );
        },
        leading: _buildLeadingIcon(context),
        title: Text(
          data.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              data.username,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _getTimeAgoText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    if (data.url != null && data.url!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: _getFaviconWidget(context),
        ),
      );
    }

    // Default icon for entries without URL
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.lock_outline,
        color: Theme.of(context).primaryColor,
        size: 20,
      ),
    );
  }

  Widget _getFaviconWidget(BuildContext context) {
    try {
      if (data.url != null && data.url!.isNotEmpty) {
        final uri = Uri.parse(data.url!);
        final domain = uri.host;
        
        if (domain.isNotEmpty) {
          // Try to get the first letter of the domain for fallback
          final firstLetter = domain.isNotEmpty ? domain[0].toUpperCase() : 'W';
          
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // If URL parsing fails, use the title's first letter
    }

    // Fallback: Use first letter of title
    final firstLetter = data.title.isNotEmpty ? data.title[0].toUpperCase() : 'P';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getTimeAgoText() {
    final now = DateTime.now();
    final difference = now.difference(data.addedDate);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Added just now';
        } else {
          return 'Added ${difference.inMinutes}m ago';
        }
      } else {
        return 'Added ${difference.inHours}h ago';
      }
    } else if (difference.inDays == 1) {
      return 'Added yesterday';
    } else if (difference.inDays < 7) {
      return 'Added ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Added 1 week ago' : 'Added $weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Added 1 month ago' : 'Added $months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Added 1 year ago' : 'Added $years years ago';
    }
  }
}
