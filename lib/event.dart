import 'dart:async';

class EventManager {

  final _controllers = <int, dynamic>{};

  StreamController<T> _getStreamController<T> () {
    int typeCode = T.hashCode;
    if (_controllers.containsKey(typeCode)) {
      return _controllers[typeCode];
    }
    StreamController<T> streamController = StreamController<T>.broadcast(sync: true);
    _controllers[typeCode] = streamController;
    return streamController;
  }

  emit<T> (T event) {
    _getStreamController<T>().add(event);
  }

  StreamSubscription listen<T> (Function callback) {
    var streamController = _getStreamController<T>();
    var subscription = streamController.stream.listen((T event) {
      
      Function.apply(callback, [event]);
    });
    return subscription;
  }
}

class CursorClickEvent {}

class CursorDraggingEvent {
  int posX;
  int posY;
  CursorDraggingEvent({required this.posX, required this.posY});
}

class SelectionCancelEvent {
  int posX;
  int posY;
  SelectionCancelEvent({required this.posX, required this.posY});
}

class SelectionEndEvent {}

class DocumentReadyEvent {}

class ProfileOpenEvent {
  bool isDefault;
  String profileKey;
  ProfileOpenEvent({required this.isDefault, required this.profileKey});
}