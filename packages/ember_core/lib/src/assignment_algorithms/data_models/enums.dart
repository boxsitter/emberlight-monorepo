enum PreferenceType {
  /// The participant has explicitly requested this activity.
  request,

  /// The participant has vetoed this activity and should not be assigned.
  veto,

  /// The participant has no strong preference.
  flexible,
}