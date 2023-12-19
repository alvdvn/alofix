import 'dart:async';
import 'dart:collection';

class FunctionQueue {
  final Queue<Function> _queue = Queue<Function>();
  bool _isProcessing = false;

  void enqueue(void Function() function) {
    _queue.add(function);
    _processQueue();
  }

  void enqueueAsync(Future<void> Function() asyncFunction) {
    _queue.add(() async {
      await asyncFunction();
    });
    _processQueue();
  }

  void enqueueAsyncWithParameters(Future<void> Function(dynamic) asyncFunction, dynamic param1) {
    _queue.add(() async {
      await asyncFunction(param1);
    });
    _processQueue();
  }

  void _processQueue() {
    if (!_isProcessing) {
      _isProcessing = true;
      _executeNextFunction();
    }
  }

  void _executeNextFunction() {
    if (_queue.isNotEmpty) {
      final nextFunction = _queue.removeFirst();
      nextFunction().then((_) {
        _executeNextFunction();
      });
    } else {
      _isProcessing = false;
    }
  }
}