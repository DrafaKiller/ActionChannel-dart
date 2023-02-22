import 'dart:async';

import 'package:stream_channel/stream_channel.dart';

import '../channel.dart';
import '../components/raw.dart';

/* -= Converting to Channel =- */

extension StreamControllerToChannel<T> on StreamController<T> {
  SingleChannel<T> toChannel() => SingleChannel(sink, stream);
}

extension StreamChannelToChannel<InOut> on StreamChannel<InOut> {
  SingleChannel<InOut> toChannel() => SingleChannel(sink, stream);
}

extension RawChannelToChannel<In, Out> on RawChannel<In, Out> {
  Channel<In, Out, void> toChannel() =>
    this is Channel<In, Out, void>
    ? this as Channel<In, Out, void>
    : Channel(sink, stream);
}

/* -= Extending Functions/Callbacks =- */

extension ExtendableEmptyFunction<Return> on Return Function() {
  Return Function() append(Return Function() callback) => () { this(); return callback(); };
  Return Function() prepend(Return Function() callback) => () { callback(); return this(); };
}

extension ExtendableFunction<Return, Data> on Return Function(Data) {
  Return Function(Data) append(Return Function(Data) callback) => (data) { this(data); return callback(data); };
  Return Function(Data) prepend(Return Function(Data) callback) => (data) { callback(data); return this(data); };
}
