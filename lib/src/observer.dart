import 'dart:async';

import 'package:action_channel/src/components/subjects/sink.dart';
import 'package:action_channel/src/components/subjects/stream.dart';

import 'channel.dart';
import 'extensions.dart';

class ChannelObserver<In, Out, Response> {
  late final Channel<In, Out, Response> channel;
  
  /* -= Callbacks =- */

  /// Called when data is sent to the sink.
  final ChannelAddCallback<In>? onAdd;

  /// Called when data is received from the stream.
  final ChannelDataCallback<Out>? onData;

  /// Called when the output stream is listened to.
  final ChannelListenCallback<Out>? onListen;

  /// Called when the sink is closed.
  final ChannelCloseCallback? onClose;

  /* -= Constructor =- */

  factory ChannelObserver(
    ChannelTransformer<In, Out> transformer,
    {
      ChannelAction<In, Out, Response>? action,
      bool sync = false,

      ChannelAddCallback<In>? onAdd,
      ChannelDataCallback<Out>? onData,
      ChannelListenCallback<Out>? onListen,
      ChannelCloseCallback? onClose,
    }
  ) {
    final input = StreamController<In>(sync: sync);
    final output = StreamController<Out>.broadcast(sync: sync);

    input.stream.listen((data) => output.add(transformer(data)));

    return ChannelObserver.raw(
      input.sink,
      output.stream,
      action: action,
      
      onAdd: onAdd,
      onData: onData,
      onListen: onListen,
      onClose: onClose,
    );
  }

  /* -= Alternative constructors =- */

  ChannelObserver.raw(
    Sink<In> sink,
    Stream<Out> stream,
    {
      ChannelAction<In, Out, Response>? action,
      
      this.onAdd,
      this.onData,
      this.onListen,
      this.onClose,
    }
  ) {
    channel = Channel<In, Out, Response>.raw(
      sink.on(
        add: onAdd != null ? (data) => onAdd!(data) : null,
        close: onClose != null ? () => onClose!() : null,
      ),
      stream.on(
        listen: onListen != null ? (subscription) => onListen!(subscription) : null,
        data: onData != null ? (data) => onData!(data) : null,
      ),
      action: action,
    );
  }
}

/* -= Controller Callbacks =- */

typedef ChannelAddCallback<In> = void Function(In input);
typedef ChannelDataCallback<Out> = void Function(Out output);
typedef ChannelListenCallback<Out> = void Function(StreamSubscription<Out> subscription);
typedef ChannelCloseCallback = void Function();