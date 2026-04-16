String normalizeProjectId(String? projectId) {
  if (projectId == null) {
    return '';
  }

  return projectId.replaceFirst('\uFEFF', '').trim();
}

String? normalizeOptionalProjectId(String? projectId) {
  final normalized = normalizeProjectId(projectId);
  return normalized.isEmpty ? null : normalized;
}
