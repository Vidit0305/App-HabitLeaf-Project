import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryEmerald.withOpacity(0.2)
                    : AppColors.primaryGreenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 20,
                color: AppColors.primaryGreenAccent,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : AppColors.textDarkNavy,
                  ),
                ),
                Text(
                  'Alerts & Reminders',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          notificationsState.maybeWhen(
            data: (data) {
              final unread = (data['unreadCount'] as int? ?? 0);
              final list = (data['notifications'] as List<NotificationModel>? ?? []);
              return Row(
                children: [
                  if (unread > 0)
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedbackHelper.selection();
                        ref.read(notificationsProvider.notifier).markAllAsRead();
                      },
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Mark all read'),
                    ),
                  if (list.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear All Notifications',
                      onPressed: () async {
                        HapticFeedbackHelper.light();
                        final confirmed = await ConfirmationDialog.show(
                          context: context,
                          title: 'Clear Notifications?',
                          message: 'Are you sure you want to clear your notification history?',
                          confirmText: 'Clear All',
                          isDestructive: true,
                        );
                        if (confirmed == true) {
                          HapticFeedbackHelper.heavy();
                          ref.read(notificationsProvider.notifier).clearAll();
                        }
                      },
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryEmerald,
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
        },
        child: notificationsState.when(
          loading: () => _buildLoading(),
          error: (err, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 48, color: AppColors.primaryEmerald),
                    const SizedBox(height: 12),
                    const Text('Tap to refresh notifications', style: AppTypography.titleMedium),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedbackHelper.light();
                        ref.invalidate(notificationsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (data) {
            final notifications = data['notifications'] as List<NotificationModel>;

            if (notifications.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'You\'re All Caught Up',
                    message:
                        'No notifications right now. Daily reminders, habit alerts, and streak achievements will appear here.',
                    buttonText: 'Test Local Reminder',
                    onAction: () async {
                      HapticFeedbackHelper.medium();
                      await LocalNotificationsService.showInstantNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: 'Consistency Reminder 🌟',
                        body: 'A quick reminder to keep up your daily habits and maintain your streak!',
                        type: 'reminder',
                      );
                    },
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(context, ref, notif, isDark);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
    bool isDark,
  ) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'streak_milestone':
        icon = Icons.local_fire_department_rounded;
        iconColor = AppColors.primaryGreenAccent;
        break;
      case 'summary':
        icon = Icons.summarize_rounded;
        iconColor = AppColors.primaryEmerald;
        break;
      case 'missed':
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.errorRed;
        break;
      default:
        icon = Icons.alarm_rounded;
        iconColor = AppColors.primaryGreenAccent;
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedbackHelper.light();
        ref.read(notificationsProvider.notifier).deleteNotification(notif.id);
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        backgroundColor: notif.isRead
            ? (isDark ? AppColors.surfaceDark.withOpacity(0.6) : Colors.white)
            : (isDark ? AppColors.surfaceDarkElevated : AppColors.primaryGreenUltraSoft),
        onTap: () {
          HapticFeedbackHelper.selection();
          if (!notif.isRead) {
            ref.read(notificationsProvider.notifier).markAsRead(notif.id);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormatter.formatShortDate(notif.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 76, borderRadius: 16),
      ),
    );
  }
}
