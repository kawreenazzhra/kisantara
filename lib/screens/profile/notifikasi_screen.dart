import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/localization.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {

  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFDF1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(

              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF064E3B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.translate('notifikasi'),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                tooltip: 'Hapus Semua',
                onPressed: () => _showDeleteAllDialog(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Bagian Notifikasi Real-time
              _buildSectionHeader(AppLocalizations.translate('notifikasi_aktivitas')),
              const SizedBox(height: 12),
              _buildNotificationsStreamBuilder(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsStreamBuilder() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getUserNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(
                color: const Color(0xFF00743B),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading notifications: ${snapshot.error}',
              style: GoogleFonts.beVietnamPro(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                AppLocalizations.translate('belum_ada_notifikasi'),
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF64655C),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Column(
          children: notifications.map((notif) => _buildNotificationItem(notif)).toList(),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    IconData iconData;
    Color iconBgColor;

    if (notif.type == 'approval') {
      iconData = Icons.check_circle_rounded;
      iconBgColor = const Color(0xFF75F39C).withValues(alpha: 0.2);
    } else {
      iconData = Icons.auto_stories_rounded;
      iconBgColor = const Color(0xFF9B9EFF).withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: notif.isRead ? Colors.transparent : const Color(0xFF00743B).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: notif.type == 'approval' ? const Color(0xFF00743B) : const Color(0xFF4F46E5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF064E3B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00743B),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF64655C),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTimeAgo(notif.timestamp),
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                      Row(
                        children: [
                          if (!notif.isRead)
                            GestureDetector(
                              onTap: () => _notificationService.markAsRead(notif.id),
                              child: Text(
                                'Mark as read',
                                style: GoogleFonts.beVietnamPro(
                                  color: const Color(0xFF00743B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (!notif.isRead) const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _notificationService.deleteNotification(notif.id),
                            child: Text(
                              'Hapus',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF064E3B),
          fontSize: 16,
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFDF1),
        title: Text(
          'Hapus Semua Notifikasi?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF064E3B),
          ),
        ),
        content: Text(
          'Semua notifikasi Anda akan dihapus secara permanen.',
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF64655C),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64655C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.deleteAllNotifications();
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
