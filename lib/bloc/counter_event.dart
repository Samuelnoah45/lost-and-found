part of 'counter_bloc.dart';

abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class CounterInc extends CounterEvent {
  final email;  
  final password;
  const CounterInc(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}
