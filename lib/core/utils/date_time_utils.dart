import 'package:intl/intl.dart';

/// Comprehensive date and time utilities for the application
class DateTimeUtils {
  // Date format patterns
  static const String _isoDatePattern = 'yyyy-MM-dd';

  static const String _isoTimePattern = 'HH:mm:ss';
  static const String _isoDateTimePattern = 'yyyy-MM-ddTHH:mm:ss';
  static const String _displayDatePattern = 'MMM dd, yyyy';
  static const String _displayTimePattern = 'h:mm a';
  static const String _displayDateTimePattern = 'MMM dd, yyyy h:mm a';
  static const String _compactDatePattern = 'MMM dd';
  static const String _compactTimePattern = 'h:mm a';
  // Formatters
  static final DateFormat _isoDateFormatter = DateFormat(_isoDatePattern);

  static final DateFormat _isoTimeFormatter = DateFormat(_isoTimePattern);
  static final DateFormat _isoDateTimeFormatter =
      DateFormat(_isoDateTimePattern);
  static final DateFormat _displayDateFormatter =
      DateFormat(_displayDatePattern);
  static final DateFormat _displayTimeFormatter =
      DateFormat(_displayTimePattern);
  static final DateFormat _displayDateTimeFormatter =
      DateFormat(_displayDateTimePattern);
  static final DateFormat _compactDateFormatter =
      DateFormat(_compactDatePattern);
  static final DateFormat _compactTimeFormatter =
      DateFormat(_compactTimePattern);
  // Prevent instantiation
  DateTimeUtils._();

  /// Get age from birthdate
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get current timestamp in milliseconds since epoch
  static int currentTimestampMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Get current timestamp in seconds since epoch
  static int currentTimestampSeconds() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).round();
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime date1, DateTime date2) {
    final startDate = startOfDay(date1);
    final endDate = startOfDay(date2);
    return endDate.difference(startDate).inDays;
  }

  /// Get the number of days in a month
  static int daysInMonth(int year, int month) {
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  /// Get the end of day for a given DateTime
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(
        dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Get the end of month for a given DateTime
  static DateTime endOfMonth(DateTime dateTime) {
    final nextMonth = dateTime.month == 12
        ? DateTime(dateTime.year + 1, 1, 1)
        : DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }

  /// Get the end of week for a given DateTime (Sunday)
  static DateTime endOfWeek(DateTime dateTime) {
    final daysToSunday = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: daysToSunday)));
  }

  /// Format a DateTime for display date only (e.g., "March 15, 2024")
  static String formatDisplayDate(DateTime dateTime) {
    return _displayDateFormatter.format(dateTime);
  }

  /// Format a DateTime for display purposes (e.g., "March 15, 2024 2:30 PM")
  static String formatDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormatter.format(dateTime);
  }

  /// Format a DateTime for display time only (e.g., "2:30 PM")
  static String formatDisplayTime(DateTime dateTime) {
    return _displayTimeFormatter.format(dateTime);
  }

  /// Format duration as human readable string (e.g., "2h 30m", "45s")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${days}d ${hours}h';
      }
      return '${days}d';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      }
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format a DateTime as ISO date string (e.g., "2024-03-15")
  static String formatIsoDate(DateTime dateTime) {
    return _isoDateFormatter.format(dateTime);
  }

  /// Format a DateTime as ISO datetime string (e.g., "2024-03-15T14:30:45")
  static String formatIsoDateTime(DateTime dateTime) {
    return _isoDateTimeFormatter.format(dateTime);
  }

  /// Format a DateTime as ISO time string (e.g., "14:30:45")
  static String formatIsoTime(DateTime dateTime) {
    return _isoTimeFormatter.format(dateTime);
  }

  /// Format a DateTime as a timestamp for messages (e.g., "2:30 PM", "Yesterday 2:30 PM")
  static String formatMessageTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDate).inDays;

    final timeString = _compactTimeFormatter.format(dateTime);

    if (difference == 0) {
      // Today - just show time
      return timeString;
    } else if (difference == 1) {
      // Yesterday
      return 'Yesterday $timeString';
    } else if (difference < 7) {
      // This week - show day name
      return '${DateFormat('EEEE').format(dateTime)} $timeString';
    } else if (dateTime.year == now.year) {
      // This year - show month and day
      return '${_compactDateFormatter.format(dateTime)} $timeString';
    } else {
      // Different year - show full date
      return _displayDateTimeFormatter.format(dateTime);
    }
  }

  /// Format a DateTime as a relative time string (e.g., "2 hours ago", "Just now")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'In the future'; // Handle edge case
    }

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Create DateTime from timestamp in milliseconds
  static DateTime fromMilliseconds(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Create DateTime from timestamp in seconds
  static DateTime fromSeconds(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  /// Get the number of hours between two DateTime objects
  static int hoursBetween(DateTime date1, DateTime date2) {
    return date2.difference(date1).inHours;
  }

  /// Check if a year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  /// Check if two DateTime objects are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if a DateTime is in the current month
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// Check if a DateTime is in the current week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final weekStart = startOfWeek(now);
    final weekEnd = endOfWeek(now);
    return dateTime
            .isAfter(weekStart.subtract(const Duration(microseconds: 1))) &&
        dateTime.isBefore(weekEnd.add(const Duration(microseconds: 1)));
  }

  /// Check if a DateTime is in the current year
  static bool isThisYear(DateTime dateTime) {
    return dateTime.year == DateTime.now().year;
  }

  /// Check if a DateTime is today
  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  /// Check if a DateTime is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(dateTime, yesterday);
  }

  /// Convert local DateTime to UTC
  static DateTime localToUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  /// Get the number of minutes between two DateTime objects
  static int minutesBetween(DateTime date1, DateTime date2) {
    return date2.difference(date1).inMinutes;
  }

  /// Parse an ISO date string to DateTime
  static DateTime? parseIsoDate(String dateString) {
    try {
      return _isoDateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse an ISO datetime string to DateTime
  static DateTime? parseIsoDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Get the start of day for a given DateTime
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get the start of month for a given DateTime
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Get the start of week for a given DateTime (Monday)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysFromMonday = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysFromMonday)));
  }

  /// Convert UTC DateTime to local time
  static DateTime utcToLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }
}
