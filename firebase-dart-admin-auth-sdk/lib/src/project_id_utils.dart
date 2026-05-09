/// Normalizes a Firebase project ID by removing a leading BOM and whitespace.
String normalizeProjectId(String? projectId) {
  if (projectId == null) {
    return '';
  }

  return projectId.replaceFirst('\uFEFF', '').trim();
}

/// Normalizes an optional Firebase project ID, returning `null` when empty.
String? normalizeOptionalProjectId(String? projectId) {
  final normalized = normalizeProjectId(projectId);
  return normalized.isEmpty ? null : normalized;
}
