part of '../controller.dart';

class ChannelSink<In> extends Sink<In> {
  final Sink<In> _instance;
  final ChannelController<In, dynamic, dynamic> _controller;

  ChannelSink(this._instance, this._controller);

  /* -= Sink - Input =- */
  
  @override
  void add(In data) {
    _controller.onAdded?.call(data);
    _instance.add(data);
  }
  
  @override
  void close() {
    _instance.close();
    _controller.onClose?.call();
  }
}
