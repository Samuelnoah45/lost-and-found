part of 'counter_bloc.dart';

abstract class CounterState extends Equatable {
  const CounterState();
  
  @override
  List<Object> get props => [];
}

class CounterInitial extends CounterState {
}
class CounterIncState extends CounterState {
  final String email;
  final String password ;
  const CounterIncState (this.email ,this.password);
  @override
  List<Object> get props => [email ,password];
}

