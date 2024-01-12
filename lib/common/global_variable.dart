class CallGlobalVariables {
  // Singleton instance
  static final CallGlobalVariables _instance = CallGlobalVariables._internal();

  // Biến toàn cục
  String callNumber = "Hello, World!";

  // Hàm factory để tạo instance
  factory CallGlobalVariables() {
    return _instance;
  }

  // Constructor private
  CallGlobalVariables._internal();
}