class SinkSubject<T> extends Sink<T> {
  final Sink<T> _instance;

  final SinkAddCallback<T>? _onAdd;
  final SinkCloseCallback? _onClose;

  SinkSubject(this._instance, { 
    SinkAddCallback<T>? onAdd,
    SinkCloseCallback? onClose,
  }) :
    _onAdd = onAdd,
    _onClose = onClose;

  /* -= Sink - Input =- */
  
  @override
  void add(T data) {
    _instance.add(data);
    _onAdd?.call(data);
  }
  
  @override
  void close() {
    _instance.close();
    _onClose?.call();
  }
}

/* -= Extension =- */

extension SinkSubjectExtension<T> on Sink<T> {
  SinkSubject<T> on({
    SinkAddCallback<T>? add,
    SinkCloseCallback? close,
  }) => SinkSubject<T>(this, onAdd: add, onClose: close);
}

/* -= Callback Definitions =- */

typedef SinkAddCallback<T> = void Function(T data);
typedef SinkCloseCallback = void Function();