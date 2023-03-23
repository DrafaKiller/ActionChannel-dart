import 'dart:async';

import 'observer.dart';
import 'components/raw.dart';
import 'mixins/stream.dart';
import 'extensions.dart';

class Channel<In, Out, Response> extends RawChannel<In, Out> with StreamCast<Out, Channel<In, Out, Response>> {
  /// Adds functionality to the `.on(callback)` method, given the data returned by the consumer of the channel.
  /// 
  /// Used in the `.on(callback)` method, to "reply" to the sender of the data.
  final ChannelAction<In, Out, Response>? action;

  /* -= Constructor =- */

  /// A channel groups a sink and a stream together, namely an input and an output.
  /// 
  /// The data type of the sink and stream can be different.
  /// The translation between them is done when instantiating the channel, some constructors are provided for convenience.
  /// 
  /// The channel can also be used to transform the data returned by the consumer of the channel,
  /// into the input type, for convienience and extra functionality.
  /// 
  /// This is done by providing an action function, which is used in the `.on(callback)` method,
  /// to "reply" to the data sent.
  /// 
  /// ---
  /// 
  /// **Notice:**
  /// 
  /// The channel is only a wrapper, and does not work with stream controller.
  /// 
  /// This is to say, it does not ensure the interaction between the sink and the stream.
  /// Instantiating the channel, make sure to setup the stream controller to listen to the sink,
  /// or use a suitable constructor.
  factory Channel(
    ChannelTransformer<In, Out> transformer,
    {
      ChannelAction<In, Out, Response>? action,
      bool sync = false,
    }
  ) {
    final input = StreamController<In>(sync: sync);
    final output = StreamController<Out>.broadcast(sync: sync);

    input.stream.listen((data) => output.add(transformer(data)));

    return Channel.raw(input.sink, output.stream, action: action);
  }

  factory Channel.controller(
    ChannelTransformer<In, Out> transformer,
    {
      ChannelAction<In, Out, Response>? action,
      bool sync = false,

      ChannelAddCallback<In>? onAdd,
      ChannelDataCallback<Out>? onData,
      ChannelListenCallback<Out>? onListen,
      ChannelCloseCallback? onClose,
    }
  ) => ChannelObserver<In, Out, Response>(
    transformer, 
    action: action,
    sync: sync,

    onAdd: onAdd,
    onData: onData,
    onListen: onListen,
    onClose: onClose,
  ).channel;

  /* -= Alternative constructors =- */

  Channel.raw(super.sink, super.stream, { this.action });

  static SimpleChannel<T> simple<T>() => StreamController<T>().toChannel();

  /*
  factory Channel.controller(
    ChannelTransformer<In, Out> transformer,
    {
      ChannelAction<In, Out, Response>? action,
      bool sync = false,

      ChannelAddedCallback<In>? onAdd,
      ChannelDataCallback<Out>? onData,
      ChannelListenCallback<Out>? onListen,
      ChannelCloseCallback? onClose,
    }
  ) {
    return ChannelController<In, Out, Response>(
      transformer,
      action: action,
      sync: sync,

      onAdd: onAdd,
      onData: onData,
      onListen: onListen,
      onClose: onClose,
    ).channel;
  }
  */
  
  /* -= Methods =- */

  /// Listen to the output stream, and execute a callback when data is received.
  /// 
  /// The callback can return a value, which will be passed to the action.
  /// This is useful to transform the data returned by the consumer of the channel,
  /// into the input type, for convienience and extra functionality.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final channel = Channel(
  ///   sink, 
  ///   stream,
  ///   action: (message, user, channel) => user.say(message)
  /// );
  /// 
  /// channel.where((user) => !user.muted).on((user) => 'Hello!');
  /// ```
  StreamSubscription<Out> on(ChannelActionCallback<Out, Response> callback) =>
    listen((data) async {
      final result = await callback(data);
      if (result != null) action?.call(result, data, this);
    });

  /// Same as `.on(callback)`, but only listen to the first data received.
  StreamSubscription<Out> once(ChannelActionCallback<Out, Response> callback) {
    late final StreamSubscription<Out> subscription;
    return subscription = on((data) {
      subscription.cancel();
      return callback(data);
    });
  }

  /* -= Stream =- */
  
  /// Instantiate a new channel, using the current channel as the input.
  /// 
  /// This can be used to extend the branches of the channel, narrowing or widening the data.
  @override
  Channel<In, Out, Response> using(Stream<Out> stream) => Channel<In, Out, Response>.raw(sink, stream, action: action);
}

/* -= Channels =- */

typedef SimpleChannel<InOut> = Channel<InOut, InOut, InOut>;

/* -= Definition =- */

typedef ChannelTransformer<In, Out> = Out Function(In data);

typedef ChannelActionCallback<Out, Response> = FutureOr<Response?> Function(Out data);
typedef ChannelAction<In, Out, Response> = void Function(Response data, Out output, Channel<In, Out, Response> channel);