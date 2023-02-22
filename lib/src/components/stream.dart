part of '../controller.dart';

class ChannelStream<Out> extends Stream<Out> {
  final Stream<Out> _instance;
  final ChannelController<dynamic, Out, dynamic> _controller;

  late final StreamSubscription<Out> _subscription;

  ChannelStream(this._instance, this._controller) {
    _subscription = _instance.listen(_controller.onData);
  }

  /* -= Stream - Output =- */

  @override
  StreamSubscription<Out> listen(
    void Function(Out event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _instance.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    _controller.onListen?.call(subscription);
    return subscription;
  }

  void close() => _subscription.cancel();
}
