import 'dart:async';

class StreamSubject<T> extends Stream<T> {
  final Stream<T> _instance;

  final StreamListenCallback<T>? _onListen;

  StreamSubject(
    this._instance,
    {
      StreamListenCallback<T>? onListen,
      StreamDataCallback<T>? onData,
      StreamErrorCallback? onError,
      StreamDoneCallback? onDone,
    }
  ) : _onListen = onListen
  {
    if (onData != null || onError != null || onDone != null) {
      _instance.listen(onData, onError: onError, onDone: onDone);
    }
  }

  /* -= Stream - Output =- */

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _instance.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    _onListen?.call(subscription);
    return subscription;
  }
}

/* -= Extension =- */

extension StreamSubjectExtension<T> on Stream<T> {
  StreamSubject<T> on({
    StreamListenCallback<T>? listen,
    StreamDataCallback<T>? data,
    StreamErrorCallback? error,
    StreamDoneCallback? done,
  }) => StreamSubject<T>(this, onListen: listen, onData: data, onError: error, onDone: done);
}

/* -= Callback Definitions =- */

typedef StreamListenCallback<T> = void Function(StreamSubscription<T> subscription);
typedef StreamDataCallback<T> = void Function(T data);
typedef StreamErrorCallback = void Function(Object error);
typedef StreamDoneCallback = void Function();