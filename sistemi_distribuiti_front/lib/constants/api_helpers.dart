Map<String, String> authHeaders(String token) => {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};

