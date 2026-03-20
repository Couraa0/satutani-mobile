import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormatter = DateFormat('d MMM yyyy', 'id');
  static final _dateTimeFormatter = DateFormat('d MMM yyyy, HH:mm', 'id');
  static final _shortFormatter = DateFormat('dd/MM/yyyy', 'id');

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  static String formatShort(DateTime date) {
    return _shortFormatter.format(date);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return formatDate(dateTime);
  }
}
