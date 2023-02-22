import 'channel.dart';

class ChannelCommunication<In, Out, Response> extends Channel<In, Out, Response> {
  final Channel<In, dynamic, dynamic> input;
  final Channel<dynamic, Out, Response> output;

  @override Sink<In> get sink => input;
  @override Stream<Out> get stream => output;

  ChannelCommunication(
    this.input,
    this.output,
    { 
      super.action
    }
  ) : super(input.sink, output.stream);
}