import 'dart:async';

import 'channel.dart';
import 'others/extensions.dart';

part 'components/sink.dart';
part 'components/stream.dart';

class ChannelController<In, Out, Response> {
  late final Channel<In, Out, Response> channel;
  
  /* -= Callbacks =- */

  /// Callback executed when data is sent to the sink.
  ChannelAddedCallback<In>? onAdded;

  /// Callback executed when data is received from the stream.
  ChannelDataCallback<Out>? onData;

  /// Callback executed when the output stream is listened to.
  ChannelListenCallback<Out>? onListen;

  /// Callback executed when the sink is closed.
  ChannelCloseCallback? onClose;

  ChannelController._(
    Sink<In> sink,
    Stream<Out> stream,
    {
      ChannelAction<In, Out, Response>? action,
      
      this.onAdded,
      this.onData,
      this.onListen,
      this.onClose,
    }
  ) {
    channel = Channel<In, Out, Response>(
      ChannelSink(sink, this),
      ChannelStream(stream, this),
      action: action,
    );
  }

  factory ChannelController(
    ChannelTransformer<In, Out> transformer,
    {
      ChannelAction<In, Out, Response>? action,
      bool sync = false,

      ChannelAddedCallback<In>? onAdded,
      ChannelDataCallback<Out>? onData,
      ChannelListenCallback<Out>? onListen,
      ChannelCloseCallback? onClose,
    }
  ) {
    final input = StreamController<In>(sync: sync, onCancel: onClose);
    final output = StreamController<Out>.broadcast(sync: sync);

    input.stream.listen((data) => output.add(transformer(data)));

    return ChannelController._(
      input.sink,
      output.stream,
      action: action,
      
      onAdded: onAdded,
      onData: onData,
      onListen: onListen,
      onClose: onClose,
    );
  }

  /* -= Extending Callbacks =- */

  void append({
    ChannelAddedCallback<In>? onAdded,
    ChannelDataCallback<Out>? onData,
    ChannelListenCallback<Out>? onListen,
    ChannelCloseCallback? onClose,
  }) {
    if (onAdded != null) this.onAdded = this.onAdded?.append(onAdded) ?? onAdded;
    if (onData != null) this.onData = this.onData?.append(onData) ?? onData;
    if (onListen != null) this.onListen = this.onListen?.append(onListen) ?? onListen;
    if (onClose != null) this.onClose = this.onClose?.append(onClose) ?? onClose;
  }

  void prepend({
    ChannelAddedCallback<In>? onAdded,
    ChannelDataCallback<Out>? onData,
    ChannelListenCallback<Out>? onListen,
    ChannelCloseCallback? onClose,
  }) {
    if (onAdded != null) this.onAdded = this.onAdded?.prepend(onAdded) ?? onAdded;
    if (onData != null) this.onData = this.onData?.prepend(onData) ?? onData;
    if (onListen != null) this.onListen = this.onListen?.prepend(onListen) ?? onListen;
    if (onClose != null) this.onClose = this.onClose?.prepend(onClose) ?? onClose;
  }
}

/* -= Callbacks =- */

typedef ChannelTransformer<In, Out> = Out Function(In data);

typedef ChannelAddedCallback<In> = void Function(In input);
typedef ChannelDataCallback<Out> = void Function(Out output);
typedef ChannelListenCallback<Out> = void Function(StreamSubscription<Out> subscription);
typedef ChannelCloseCallback = void Function();