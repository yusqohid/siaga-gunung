import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tidak tersedia';
    // Laporan MAGMA berzona WIB (UTC+7). Hitung secara eksplisit dari UTC agar jujur di seluruh timezone.
    final wibDateTime = dateTime.toUtc().add(const Duration(hours: 7));
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id');
    return '${formatter.format(wibDateTime)} WIB';
  }

  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tidak tersedia';
    final diff = DateTime.now().difference(dateTime.toLocal());
    
    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }
}
