import 'package:stack_trace/stack_trace.dart';

StackTrace wrapStackTrace(StackTrace? trace) {
  if (trace != null && trace.toString().isNotEmpty) {
    return Trace.from(trace);
  }
  return Trace.from(StackTrace.current);
}
