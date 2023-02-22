import 'dart:async';

mixin StreamCast<T, Using extends Stream<T>> on Stream<T> {
  Using using(Stream<T> stream);

  /* -= Stream Method Overriding =- */

  @override
  Using asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel
  })
    => using(super.asBroadcastStream(onListen: onListen, onCancel: onCancel));

  @override
  Using distinct([ bool Function(T previous, T next)? equals ])
    => using(super.distinct(equals));

  @override
  Using handleError(Function onError, { bool Function(dynamic error)? test }) 
    => using(super.handleError(onError, test: test));

  @override
  Using skip(int count) 
    => using(super.skip(count));

  @override
  Using skipWhile(bool Function(T element) test)
    => using(super.skipWhile(test));

  @override
  Using take(int count) 
    => using(super.take(count));

  @override
  Using takeWhile(bool Function(T element) test) 
    => using(super.takeWhile(test));

  @override
  Using timeout(Duration timeLimit, { void Function(EventSink<T> sink)? onTimeout }) 
    => using(super.timeout(timeLimit, onTimeout: onTimeout));

  @override
  Using where(bool Function(T event) test) 
    => using(super.where(test));
}
