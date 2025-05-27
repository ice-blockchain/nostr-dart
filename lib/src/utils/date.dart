DateTime fromTimestamp(int timestamp) {
  if (timestamp.toString().length <= 10) {
    // If the timestamp is in seconds, convert to milliseconds
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  } else {
    // If the timestamp is already in microseconds, use it directly
    return DateTime.fromMicrosecondsSinceEpoch(timestamp);
  }
}
