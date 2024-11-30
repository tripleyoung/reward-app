class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      success: json['success'] ?? false,
    );
  }
} 