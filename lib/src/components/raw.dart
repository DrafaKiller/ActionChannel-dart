import 'dart:async';

class RawChannel<In, Out> extends Stream<Out> implements Sink<In> {
  late final Sink<In> sink;
  late final Stream<Out> stream;

  RawChannel(this.sink, this.stream);

  /* -= Sink - Input =- */

  @override void add(In data) => sink.add(data);
  @override void close() => sink.close();

  /* -= Stream - Output =- */

  @override
  StreamSubscription<Out> listen(
    void Function(Out event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError
  }) => stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}